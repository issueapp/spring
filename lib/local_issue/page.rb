class LocalIssue::Page < Hashie::Mash
  
  # title
  # handle
  # summary
  # content
  # thumbnail  (320x#) 4x3
  # 
  # images
  #  - logo.png       "company logo"
  #  - something.jpg  "italian river"   cover: true
  #  - whatelse.png   "what to do in bali"   cover: true
  # 
  # virtual
  # cover -> images.where(cover:true)
  
  def self.index
    new(title: "Cover", handle: "index", image_url: "assets/background.jpg")
  end
  
  def self.all
    cache = {}
    
    pages = recursive_build('data', cache).uniq
    toc = pages.find{|p| p.handle == "toc" }
    
    pages.delete(toc)
    
    [index, toc].compact + pages
  end
  
  def self.find(path, issue_path = nil)
    return index if path == "index"

    if issue_path
      path = "#{issue_path}/data/#{path}.md"
    else
      path = "data/#{path}.md"
    end
        
    page_dir = Pathname(path).basename(".md")
    page = self.build(path)
    
    page.handle = page.handle.gsub(issue_path.to_s, "").gsub("/", "")
    
    page.children = self.recursive_build("data/#{page_dir}")
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
        product["index"] = i + 1
      end
    end
    
    if options[:layout]
      attributes["layout"].merge!(options[:layout])
    end

    attributes.merge!(
      "handle"          => path.gsub("data/", '').gsub(".md", ''),
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