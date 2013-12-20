require 'rdiscount'
require 'sinatra/base'
require 'hashie/mash'

class IssuePreview < Sinatra::Base
  
  helpers do
    def render(*args)
      if args.first.is_a?(Hash) && args.first.keys.include?(:partial)
        return haml "_#{args.first[:partial]}".to_sym, :layout => false
      else
        super
      end
    end
  end
  
  get %r{/preview/([^\/]+)/([^\/]+)(?:\/([^\/]+))?} do
    path = params[:captures].compact.join('/')

    file_path = File.expand_path("../views/#{path}.md", __FILE__)
    source = open(file_path).read
    
    if "1.9".respond_to? :encode
      source = source.force_encoding('binary') 
    end
    
    meta, content = source.split(/---\n(.+?)---/usm)[1,2]
    
    page = YAML.load(meta)
    page.merge!(
      content: content && RDiscount.new(content).to_html,
      layout: {}
    )
    
    erb :"issue/_column.html", locals: { page: Hashie::Mash.new(page) }, layout: :"issue/_layout.html"
  end
  
end
