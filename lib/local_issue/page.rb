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
  
  
  # Page elements: media and entities
  def self.elements
    ["images", "audios", "videos", "products", "links"]
  end
    
  def self.index
    new(title: "Cover", handle: "index", thumb_url: "assets/background.jpg")
  end
  
  def self.all
    cache = {}
    
    pages = recursive_build('data', cache).uniq
    toc = pages.find{|p| p.handle == "toc" }
    
    pages.delete(toc)
    
    [index, toc].compact + pages
  end
  
  def self.find(path, options = {})
    return index if path == "index"
    
    if issue = options[:issue]
      path = "#{issue.path}/data/#{path}.md"
    else
      path = "data/#{path}.md"
    end
        
    page_dir = Pathname(path).basename(".md")
    page = self.build(path, options)
    
    page.issue = options[:issue]
    page.children = self.recursive_build("data/#{page_dir}", {}, options)
    
    page
   end
  
  # Load markdown file into memory
  def self.build(path, options = {})
    source = open(path).read
    issue = options[:issue]
    
    if "1.9".respond_to? :encoding
      source = source.force_encoding('binary')
    end
    
    ## Build attributes from YAML
    meta, content = source.split(/---\s?\n(.+?)---\n/nm)[1,2]
    attributes = meta ? YAML.load(meta) : {}
    
    # Format attribute
    if attributes["products"]
      attributes["products"].each_with_index {|p, i| p["index"] = i + 1 }
    end
    
    # Convert media and entity url array into hash
    self.elements.each do |element|
      attributes[element] = attributes[element].to_a.map do |object|
        object = { "url" => object } if object.is_a?(String)
        object
      end
    end
    
    # Add cover url into images
    if attributes["cover_url"]
      attributes["images"].push(
        "caption"   => attributes.delete("cover_caption"),
        "url"       => attributes["cover_url"],
        "thumb_url" => attributes["thumb_url"],
        "cover"     => true
      )
    end
    
    # Custom Callback to format asset for app page elements
    if formatter = options[:format_asset]
      self.elements.each do |element|
        attributes[element] = attributes[element].to_a.map(&formatter)
      end
    end
    
    # Render content part
    content = Mustache.render(content.to_s.strip, attributes)
    
    # Get script/style tag
    doc = Nokogiri::HTML.fragment(content)
    script_and_style = doc.search('style')[0].to_s + doc.search('script')[0].to_s
    
    content = RDiscount.new(content).to_html + script_and_style
    
    # Layout
    if options[:layout]
      attributes["layout"].merge!(options[:layout])
    end
    
    attributes.merge!(
      "issue"           => issue,
      "handle"          => path.gsub("#{issue.path}/data/", '').gsub(".md", ''),
      # "published_at"    => attributes["published_at"] || File.mtime(path).to_i,
      "layout"          => attributes.fetch("layout", {}),
      "content"         => content
    )
    new(attributes)
  end

  def self.recursive_build(start_path, cache = {}, options = {})
    issue = options[:issue]
    
    Dir.glob("#{issue.path}/#{start_path}/*").sort.map do |path|
      # path.gsub!(issue_path.to_s + "/", '')
      
      if File.directory?(path)
        page = cache[path + '.md'] = build(path + '.md', options)
        page.children = children = recursive_build(path, cache, options)
        
      elsif !cache[path]
         page = cache[path] = build(path, options)
         
      else
        page = cache[path]
      end
      page
    end
  end
  
  
  def issue
    @issue
  end
  
  def issue=(issue)
    @issue ||= issue
  end
  
  def product_set?
    products.to_a.select{|p| !p.hotspot }.length > 0
  end
  
  def hotspots
    products = products.to_a.select{|p| !p.hotspot }
    
    hotspots = (products.to_a + self.links.to_a).select{|p| p.hotspot }.map do |p|
      left, right, radius = p.hotspot.split(',').map(&:strip)
      p.hotspot = { left: left, right: right, radius: radius }
      p
    end
  end
  
  def children
    self[:children] || []
  end
  
  def theme
    dark_themes = ["black", "transparent", "dark"]
    
    if dark_themes.include? layout.try(:content_style)
      "black"
    else
      "white"
    end
  end
  
  def url
    self.handle
  end
  
  def to_hash(options = {})
    hash = super.except("id", "issue")
    
    self.class.elements.each do |element|
      hash[element].to_a.each_with_index do |asset, index|
        
        asset.to_a.each do |key, value|
          next unless options[:local_path]
          
          if key =~ /url$/ && value =~ /^assets\//
            path = asset.delete(key) if asset.has_key?(key)
            
            key = "file_url" if key == "url"
            asset[key.gsub('_url', '')] = issue.path.join(value)
          end
        end
        
        hash[element][index] = asset
      end
    end
    
    hash
  end
end