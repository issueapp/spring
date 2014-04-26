$: << File.expand_path("../", __FILE__)

require 'mime/types'
require 'rdiscount'
require 'hashie/mash'
require 'sinatra/base'
require 'sinatra/content_for'
require 'local_issue'
require 'local_issue/page'

require 'nokogiri'

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
    current_issue.items.map(&:products).flatten.compact
  end

  get "/:magazine/:issue/index/?" do
    erb :"issue/_cover.html", layout: :"/layouts/_app.html", locals: { issue: current_issue }
  end

  get "/:magazine/:issue/?" do
    erb :"issue/_cover.html", layout: :"/layouts/_app.html", locals: { issue: current_issue }
  end

  get "/:magazine/:issue/_menu" do    
    erb :"issue/_menu.html", locals: { issue: current_issue }, layout: !request.xhr? && :"/layouts/_app.html"
  end

  get "/:magazine/:issue/issue.json" do
    if params[:callback]
      "#{params[:callback]}(#{current_issue.to_json})";
    else
      current_issue.to_json
    end
  end

  # Cache assets for 1H (cloudfront)
  get "/:magazine/:issue/assets/*" do
    response.headers['Cache-Control'] = 'public, max-age=3600'

    asset_path = request.path_info.gsub(/^\/#{params[:magazine]}/, "issues")
    file = File.expand_path("../../#{CGI.unescape(asset_path)}", __FILE__)

    content_type MIME::Types.type_for(file).first.content_type

    send_file file
  end

  # Page and subpage
  get %r{/(?<magazine>[^\/]+)/(?<issue>[^\/]+)/(?<page>[^\/]+)(?:\/(?<subpage>[^\/]+))?} do
    issue = current_issue
    path = [params["page"], params["subpage"]].compact.join('/')
    
    asset_formatter = lambda do |asset|
      asset.each{|key, value| asset[key] = asset_path(value) if key =~ /url$/ }
    end
    page = LocalIssue::Page.find(path, issue_path: issue.path, format_asset: asset_formatter)
    
    erb page_template(page), locals: { issue: issue, page: page }, layout: !request.xhr? && :"/layouts/_app.html"
  end

  private

  def current_issue
    @issue = LocalIssue.find("#{params[:magazine]}/#{params[:issue]}")

    apply_asset_path! @issue, :thumb_url, :cover_url
    @issue
  end
  
  def apply_asset_path!(issue, *attrs)
    attrs.each do |attribute|
      issue.send("#{attribute}=", asset_path(issue.send(attribute)))
    end
  end

  # Load issue level issue assets
  #
  # asset_path 'custom.js'
  #
  # Load app level assets
  # asset_path 'issue.js', global: true
  def asset_path(path, options = {})
    return path if path.nil? || path =~ /^https?:/

    if path && path =~ /^\/?assets\//
      path.gsub!(/^\/?assets\//, '')
    end

    if ENV["ASSET_HOST"]
      asset_host = ENV["ASSET_HOST"]
    else
      asset_host = request.base_url
    end

    if defined?(Rails)
      if !Rails.application.config.offline_assets && options[:global]
        return  ActionController::Base.helpers.asset_path(path)
      end

      Rails.logger.info "offline: #{Rails.application.config.offline_assets} " + File.join("assets", path.to_s)

      prefix = params[:subpage] ? "../" : ""

      return path.include?("#{prefix}assets/") ? path : File.join("#{prefix}assets", path.to_s)
    end

    if options[:global]
      "#{asset_host}/#{path}"
    else
      "#{asset_host}#{issue_path(path)}"
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

  def issue_path(path = nil)
    asset = File.expand_path("../../issues/#{params[:issue]}/assets#{path}", __FILE__)

    if File.exist?(asset) && !path.nil? && !path.empty?
      path = path + "?#{File.mtime(asset).to_i}"
    end

    "#{request.script_name}/#{params[:magazine]}/#{params[:issue]}/assets#{path}"
  end

  def issue_url(path = "")
    "#{request.base_url}#{request.script_name}/#{params[:magazine]}/#{params[:issue]}"
  end

  def page_template(page)
    if page.layout.type == "cover"
      :"issue/_cover.html"
    elsif page.layout.type == "toc"
      :"issue/_toc.html"
    else
      :"issue/_page.html"
    end
  end
end