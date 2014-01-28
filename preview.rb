require 'rdiscount'
require 'hashie/mash'
require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/asset_pipeline'

require 'nokogiri'

class IssuePreview < Sinatra::Base
  register Sinatra::AssetPipeline
  helpers Sinatra::ContentFor
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

  get %r{/viewer/(?<issue>[^\/]+)/?(?<page>[^\/]+)?(?:\/(?<subpage>[^\/]+))?} do
    @path = params.slice("issue", "page", "subpage").values.compact.join('/')

    erb :"issue/viewer.html", layout: :"/layouts/_docs.html", locals: { path: "/issues/#{@path}", issue: current_issue }
  end

  get '/magazines.json' do
    @issues = Dir.glob('issues/*/issue.yaml').map do |file|
      issue_path = file.split("/")[1]

      issue = Hashie::Mash.new(YAML.load_file(file)).tap do |i|
        i.background_url = "/issues/#{issue_path}/#{i.background_url}"
        i.url = "/issues/#{issue_path}/"
      end
    end

    if params[:q]
      @issues.select! do |issue|
        text = "#{issue.edition_title} #{issue.title}"
        pattern = Regexp.compile(params[:q], Regexp::IGNORECASE)

        result = text.match( pattern )


        if params[:filter] == "featured"
          result = issue.featured
        end

        result
      end
    end

    @issues.to_json
  end

  get '/issues/?' do
    @issues = Dir.glob('issues/*/issue.yaml').map do |file|
      issue_path = file.split("/")[1]

      issue = Hashie::Mash.new(YAML.load_file(file)).tap do |i|
        i.image_url = "#{issue_path}/#{i.image_url}"
      end
    end

    erb :"issue/list.html", layout: :"/layouts/_docs.html"
  end


  get '/issues/:issue/products.json' do
    cache = {}
    # pages = recursive_build("issues/#{params[:issue]}", cache).uniq
    content_type :json

    files    = Dir.glob("issues/#{params[:issue]}/data/*/*.{md}") +   Dir.glob("issues/#{params[:issue]}/data/*.{md}")
    pages    = files.map {|path| find_page(path) }
    products = pages.map(&:products).flatten.compact

    products.to_json
  end

  get "/issues/:issue/index" do
    redirect to("/issues/#{params[:issue]}/")
  end

  get "/issues/:issue" do
    redirect to("/issues/#{params[:issue]}/")
  end

  get "/issues/:issue/" do
    erb :"issue/_cover.html", layout: :"/layouts/_app.html", locals: { issue: current_issue}
  end

  get "/issues/:issue/_menu" do
    erb :"issue/_menu.html", layout: false, locals: { issue: current_issue}
  end

  get "/issues/:issue/issue.json" do

    pages = current_issue.items.reduce([]) do |result, item|
      result << item["handle"] #.gsub('/issue/', '')

      if item["pages"]
        result += item["pages"].map{|p|
          p["path"] ||  item["handle"] + "/" + p["handle"]
        }
      end

      result
    end
    
    data = current_issue.to_h
    data.delete("items")
    data["pages"] = [ "index" ] + pages

    data["menu_html"] = erb :"issue/_menu.html", layout: false, locals: { issue: current_issue}

    if params[:callback]
      "#{params[:callback]}(#{data.to_json})";
    else
      data.to_json
    end
  end

  # Page and subpage
  get %r{/issues/(?<issue>[^\/]+)/(?<page>[^\/]+)(?:\/(?<subpage>[^\/]+))?} do
    if params["page"] == "assets"
      return send_file request.path[1, request.path.length - 1]
    end

    @path = [params["issue"], "data", params["page"], params["subpage"]].compact.join('/')

    file_path = File.expand_path("../issues/#{@path}.md", __FILE__)
    page      = find_page(file_path)

    page.handle = [params["page"], params["subpage"]].compact.join('/')

    erb page_template(page), locals: { issue: current_issue, page: page }, layout: :"/layouts/_app.html"
  end

  private

  def current_issue
    issue = YAML.load_file(File.expand_path("../issues/#{params[:issue]}/issue.yaml", __FILE__))
    items = issue.fetch("items", []).map do |page|
      page["url"] = "#{page["handle"]}"
      page["image_url"] = asset_path(page["image_url"])

      page
    end

    issue.merge!(
      "image_url" => asset_path(issue["image_url"]),
      "items" => items
    )

    Hashie::Mash.new(issue)
  end

  # Find page data file and turn yaml in heading into page attribute, body as page content
  def find_page(path)
    source = open(path).read

    if "1.9".respond_to? :encode
      source = source.force_encoding('binary')
    end

    meta, content = source.split(/---\s?\n(.+?)---\n/nm)[1,2]
    content = content.to_s.strip

    ## Parse YAML
    if meta
      attributes = YAML.load(meta)
    else
      attributes = {}
    end

    author_icon     = attributes["author_icon"] ? asset_path(attributes["author_icon"]) : nil
    brand_image_url = attributes["brand_image_url"] ? asset_path(attributes["brand_image_url"]) : nil

    if products = attributes["products"]
      products.each_with_index do |product, i|
        product["image_url"] = asset_path(product["image_url"])
        product["index"] = i + 1
      end
    end

    id = [params[:page], params[:subpage]].compact.join('/')

    attributes.merge!(
      "id" => "#{id}",
      "issue_url" => issue_url,
      "page_url" => "#{issue_url}/#{params[:page]}",
      "image_url" => attributes["image_url"] && asset_path(attributes["image_url"]), # remove preview rendering
      "author_icon" => author_icon,
      "brand_image_url" => brand_image_url,
      "products" => products,
      "published_at" => attributes["published_at"] || File.mtime(path),
      "layout" => attributes.fetch("layout", {})
    )

    # Render content part
    content = Mustache.render(content, attributes)
    doc     = Nokogiri::HTML(content)
    content = content.empty? ? nil : (RDiscount.new(content).to_html.to_s + doc.search('style')[0].to_s + doc.search('script')[0].to_s )

    attributes["content"] = content

    if params[:layout]
      attributes["layout"].merge!(params[:layout])
    end

    Hashie::Mash.new(attributes)
  end

  def asset_path(path)
    if path =~ /^https?:/
      path
    elsif path
      "#{issue_url}/#{path}"
    end
  end

  def issue_url
    "#{request.base_url}/#{params[:issue]}"
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

  def recursive_build(start_path, cache)
    Dir.glob("#{start_path}/*").map do |path|
      if File.directory?(path) && File.exists?(path + '.md')
        page = cache[path + '.md'] = find_page(path + '.md')
        page.children = recursive_build(path, cache)
      elsif !cache[path] && File.exists?(path + '.md')
         page = cache[path] = find_page(path)
      else
        page = cache[path]
      end
      page
    end
  end
end
