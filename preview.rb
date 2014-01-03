require 'rdiscount'
require 'hashie/mash'
require 'sinatra/base'
require 'sinatra/content_for'
require 'json'
require 'yaml'

class IssuePreview < Sinatra::Base
  # helpers Serve::RenderHelpers
  helpers Sinatra::ContentFor

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

  get '/issues/:issue' do
    redirect to("/issues/#{params[:issue]}/")
  end

  get "/issues/:issue/" do
    erb :"issue/_cover.html", layout: :"issue/_layout.html", locals: { issue: current_issue}
  end

  # Page and subpage
  get %r{/issues/(?<issue>[^\/]+)/(?<page>[^\/]+)(?:\/(?<subpage>[^\/]+))?} do
    path = params.slice("issue", "page", "subpage").values.compact.join('/')
    file_path = File.expand_path("../issues/#{path}.md", __FILE__)

    page = find_page(file_path)
    erb page_template(page), locals: { issue: current_issue, page: page  }, layout: :"issue/_layout.html"
  end

  private

  def current_issue
    issue = YAML.load_file(File.expand_path("../issues/#{params[:issue]}/issue.yaml", __FILE__))
    items = issue.fetch("items", []).map do |page|
      page["url"] = "#{page["handle"]}"

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

    ## Parse YAML
    meta, content = source.split(/---\n(.+?)---/nm)[1,2]

    if meta
      attributes = YAML.load(meta)
    else
      attributes = {}
    end

    author_icon = attributes["author_icon"] ? asset_path(attributes["author_icon"]) : nil

    attributes.merge!(
      "issue_url" => issue_url,
      "page_url" => "#{issue_url}/#{params[:page]}",
      "image_url" => asset_path(attributes["image_url"]), # remove preview rendering
      "author_icon" => author_icon,

      "content" => content && RDiscount.new(content).to_html,
      "published_at" => attributes["published_at"] || File.mtime(path),
      "layout" => attributes.fetch("layout", {})
    )

    Hashie::Mash.new(attributes)
  end

  def asset_path(path)
    "#{issue_url}/#{path}"
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
end
