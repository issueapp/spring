class LocalIssue::Page < Hashie::Mash

  def self.index
    new(title: "Cover", handle: "index")
  end
  
  def self.all
    cache = {}
    
    pages = recursive_build('data', cache).uniq
    toc = pages.find{|p| p.handle == "toc" }
    
    pages.delete(toc)
    
    [index, toc].compact + pages
  end
  
  def self.find(path)
    return index if path == "index"
    
    path = Dir.glob("data/#{path}.md").first or raise "Page not found"
    dir = Pathname(path).basename(".md").to_s
    
    page = self.build(path)
    page.children = self.recursive_build("data/"+dir)
    page
   end
  
  # Load markdown file into memory
  def self.build(path, options = {})
    source = open(path).read
    
    if "1.9".respond_to? :encoding
      source = source.force_encoding('binary')
    end
    
    meta, content = source.split(/---\s?\n(.+?)---\n/nm)[1,2]

    ## Build attributes from YAML
    attributes = meta ? YAML.load(meta) : {}
    
    # Render content part
    content = Mustache.render(content.to_s.strip, attributes)
    doc     = Nokogiri::HTML(content)
    
    if content
      content = RDiscount.new(content).to_html + doc.search('style')[0].to_s + doc.search('script')[0].to_s
    end
    
    if products = attributes["products"]
      products.each_with_index do |product, i|
        product["image_url"] = (product["image_url"])
        product["index"] = i + 1
      end
    end
    
    if options[:layout]
      attributes["layout"].merge!(options[:layout])
    end

    attributes.merge!(
      "handle"          => Pathname(path).basename(".md").to_s,
      "products"        => products,
      "published_at"    => attributes["published_at"] || File.mtime(path).to_i,
      "layout"          => attributes.fetch("layout", {}),
      "content"         => content
    )
    new(attributes)
  end

  def self.recursive_build(start_path, cache = {})
    Dir.glob("#{start_path}/*").map do |path|
      if File.directory?(path)
        page = cache[path + '.md'] = build(path + '.md')
        page.children = children = recursive_build(path, cache)
      elsif !cache[path]
         page = cache[path] = build(path)
      else
        page = cache[path]
      end
      page
    end
  end
  
  def children
    self[:children] || []
  end
  
end