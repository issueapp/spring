$: << File.expand_path("../", __FILE__)

require 'sinatra/base'
require 'sinatra/content_for'

require 'bourbon'
require 'hashie/mash'
require 'local_issue'
require 'local_issue/page'
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
    erb :"issue/_cover.html", layout: issue_layout, locals: { issue: current_issue }
  end

  get "/:magazine/:issue/?" do
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

  # /official/great-escape/assets/custom.css
  # assets/custom.scss
  #
  # params:
  #   splat: [custom.scss]
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

    mime_type = MIME::Types.type_for(file).first.content_type

    if mime_type == "application/mp4"
      return send_file current_issue.path.join('assets').join(file), type: "video/mp4"
    end
    content_type mime_type

    asset.to_s
  end

  # Page and subpage
  get %r{/(?<magazine>[^\/]+)/(?<issue>[^\/]+)/(?<page>[^\/]+)(?:\/(?<subpage>[^\/]+))?} do
    issue = current_issue
    path = File.join(params.values_at('page', 'subpage').compact)
    page = LocalIssue::Page.find(path, issue: issue)
    page = Issue::PageView.new(page, self)

    layout = request.xhr? ? nil : :"/layouts/_app.html"

    erb page_template(page), locals: {issue: issue, page: page}, layout: layout
  end

  # usage:
  #   issue level    asset_path('custom.js')
  #   app level      asset_path('issue.js', global: true)
  def asset_path path, options={}
    return path if path.nil? || path.start_with?('http:', 'https:')

    global = options[:global] || options['global']

    path = path.sub('assets/', '') # Sub page has incorrect asset path "../assets/assets/logo.png"

    if defined? Rails
      if global_online = (!Rails.application.config.offline_assets && global)
        return ActionController::Base.helpers.asset_path(path)
      end

      prefix = params[:subpage] ? "../" : ""
      path = File.join("#{prefix}assets", path) unless path.include?("#{prefix}assets/")

      return path
    end

    asset_host = ENV["ASSET_HOST"] || request.base_url
    asset_path = global ? "assets/#{path}" : issue_path(path)
    asset_path = asset_path.sub('assets/assets', 'assets')

    File.join(asset_host, asset_path)
  end

  private

  def current_issue
    @issue = LocalIssue.find("#{params[:magazine]}/#{params[:issue]}")

    apply_asset_path!(@issue, :thumb_url, :cover_url)
    @issue
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
    (defined?(Rails) && Rails.application.config.offline_assets) || params[:offline]
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
    if page.layout.type == "cover"
      :"issue/_cover.html"
    elsif page.layout.type == "toc"
      :"issue/_toc.html"
    else
      :"issue/_page.html"
    end
  end

  def sprockets
    @sprockets ||= Sprockets::Environment.new
  end
end
