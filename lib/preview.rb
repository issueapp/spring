$: << File.expand_path("../", __FILE__)

require 'sinatra/base'
require 'sinatra/content_for'

require 'bourbon'
require 'hashie/mash'
require 'local_issue'
require 'local_issue/page'
require 'local_issue/custom_css'
require 'issue/page_view'

class IssuePreview < Sinatra::Base

  unless defined?(Rails)
    require 'sinatra/asset_pipeline'
    register Sinatra::AssetPipeline
  end

  helpers Sinatra::ContentFor

  set :root, File.expand_path("../../", __FILE__)
  set :protection, :except => :frame_options

  helpers do
    def render(*args)
      if args.first.is_a?(Hash) && args.first.keys.include?(:partial)
        return erb "#{args.first[:partial]}".to_sym, :layout => false, locals: { issue: current_issue }
      else
        super
      end
    end
  end

  get '/magazines.json' do
    @issues = LocalIssue.all.each do |i|
      i.cover_url = "/issues/#{issue_path}/#{i.cover_url}"
      i.url = "/issues/#{issue_path}/"
    end

    if params[:q]
      pattern = Regexp.compile(params[:q], Regexp::IGNORECASE)

      @issues.select! do |issue|
        if params[:filter] == "featured"
          issue.featured
        else
          pattern.match("#{issue.edition_title} #{issue.title}")
        end
      end
    end

    @issues.to_json
  end

  get '/:magazine/:issue/products.json' do
    current_issue.pages.map(&:products).flatten.compact
  end

  get "/:magazine/:issue/index/?" do
    is_json = params['format'] == 'json'
    html = erb :"issue/_cover.html", layout: issue_layout, locals: { issue: current_issue }

    if is_json
      {'html' => html}.to_json
    else
      html
    end
  end

  get "/:magazine/:issue/?" do
    ensure_trailing_slash

    erb :"issue/_cover.html", layout: issue_layout, locals: { issue: current_issue }
  end

  get "/:magazine/:issue/_menu" do
    erb :"issue/_menu.html", locals: { issue: current_issue }, layout: issue_layout
  end

  get "/:magazine/:issue/issue.json" do
    if params[:callback]
      "#{params[:callback]}(#{current_issue.to_json})";
    else
      current_issue.to_json
    end
  end

  get "/:magazine/:issue/assets/custom.css" do
    custom_css = LocalIssue::CustomCss.new(current_issue)

    if custom_css.fresh?
      Rails.logger.debug '----> custom.css still fresh'
    else
      scss = custom_css.to_scss
      custom_css.write scss
    end

    content_type 'text/css'
    custom_css.to_css
  end

  # /official/great-escape/assets/custom.js
  #
  # params:
  #   splat: [custom.css]
  #
  # search paths:
  #
  #  app/assets/images,
  #  app/assets/spreadsheets,
  #  app/assets/javascripts,
  #  issues/music/assets
  #  issues/great-escape/assets
  #
  # Cache assets for 1H (cloudfront)
  get "/:magazine/:issue/assets/*" do
    require 'mime/types'

    # response.headers['Cache-Control'] = 'public, max-age=3600'
    #

    # Append issue asset path and remember current search paths
    preview_paths = sprockets.paths
    sprockets.append_path(current_issue.path.join('assets'))
    sprockets.append_path Rails.root.join('app/assets/stylesheets/')

    # Serve asset via sprockets
    file = params[:splat].first

    asset = sprockets[file]

    # Restore previous asset path
    sprockets.clear_paths
    preview_paths.each do |path|
      sprockets.append_path path
    end


    # asset_path = request.path_info.gsub(/^\/#{params[:magazine]}/, "issues")
    # file = File.expand_path("../../#{CGI.unescape(asset_path)}", __FILE__)

    mime_type = asset ? asset.content_type : MIME::Types.type_for(file).first.content_type

    if mime_type == "application/mp4"
      return send_file current_issue.path.join('assets').join(file), type: "video/mp4"
    elsif mime_type.include?('css')
      source = AutoprefixerRails.process(asset.to_s, from: file, browsers: ['> 1%', 'ie 10']).css
    else
      source = asset.to_s
    end

    content_type mime_type
    source
  end

  # Page and subpage
  get %r{/(?<magazine>[^\/]+)/(?<issue>[^\/]+)/(?<page>[^\/\.]+)(?:\/(?<subpage>[^\/\.]+))?\.?(?<format>json)?} do

    issue = current_issue
    path = File.join(params.values_at('page', 'subpage').compact)
    page = LocalIssue::Page.find(path, issue: issue)
    page = Issue::PageView.new(page, context: self)

    is_json = params['format'] == 'json'

    layout = request.xhr? || is_json ? nil : :"/layouts/_app.html"
    html = erb(
      page_template(page),
      locals: {issue: issue, page: page}, layout: layout
    )

    if is_json
      hash = page.json
      hash['html'] = html
      hash.to_json
    else
      html
    end
  end

  # usage:
  #   issue level    asset_path('custom.js')
  #   app level      asset_path('issue.js', global: true)
  def asset_path path, options={}
    return path if path.nil? || path.start_with?('http:', 'https:')

    global = options[:global] || options['global']
    embed = request.env['SCRIPT_NAME'] == '/embed'
    json = params['format'] == 'json'

    path = "assets/#{path}" unless path.start_with? 'assets/'

    if defined? Rails
      if global
        ActionController::Base.helpers.asset_path(path)
      elsif embed && json
        path
      elsif params[:subpage]
        File.join('..', '..', path)
      elsif params[:page]
        File.join('..', path)
      else
        path
      end

    else
      asset_host = ENV["ASSET_HOST"] || request.base_url
      asset_path = global ? "assets/#{path}" : issue_path(path)
      asset_path = asset_path.sub('assets/assets', 'assets')

      File.join(asset_host, asset_path)
    end
  end

  private

  def current_issue
    @issue ||= begin
      issue = LocalIssue.find("#{params[:magazine]}/#{params[:issue]}")
      apply_asset_path!(issue, :thumb_url, :cover_url, :brand_logo_url, :title_image_url)
      issue
    end
  end

  def apply_asset_path!(issue, *attrs)
    attrs.each do |attribute|
      issue.send("#{attribute}=", asset_path(issue.send(attribute)))
    end
  end

  def page_ext
    offline? ? ".html" : ""
  end

  def offline?
    params[:offline]
  end

  def webview?
    params[:webview] == "1" # || %r{issue://} === request.original_url
  end

  def issue_path path=nil
    asset = File.expand_path("../../issues/#{params[:issue]}/assets#{path}", __FILE__)

    if add_cache_buster = (File.exist?(asset) && !path.nil? && !path.empty?)
      path << "?#{File.mtime(asset).to_i}"
    end

    "#{request.script_name}/#{params[:magazine]}/#{params[:issue]}/assets/#{path}".squeeze('/')
  end

  def issue_url(path = "")
    "#{request.base_url}#{request.script_name}/#{params[:magazine]}/#{params[:issue]}"
  end

  def issue_layout
    !request.xhr? && :"/layouts/_app.html"
  end

  def page_template page
    if page.style.type == "cover"
      :"issue/_cover.html"
    elsif page.style.type == "toc"
      :"issue/_toc.html"
    else
      :"issue/_page.html"
    end
  end

  def sprockets
    @sprockets ||= Sprockets::Environment.new
  end

  def ensure_trailing_slash
    # ensure path ends with trailing slash
    # so that relative paths inside css reference to assets

    original_fullpath = env['ORIGINAL_FULLPATH']

    parts = original_fullpath.partition('?')
    fullpath = parts[0]

    unless fullpath.end_with?('/')
      fullpath << '/'
      redirect parts.join
    end
  end
end
