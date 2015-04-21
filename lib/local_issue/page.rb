require 'rdiscount'
require 'nokogiri'
require 'local_issue'

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

  def self.default_layout
    {
      'content_style'          => 'white',
      'type'                   => 'two-column',
      'image_style'            => 'cover',
      'image_align'            => 'left',
      'content_align'          => 'left',
      'content_valign'         => 'top',
      'content_height'         => 'auto',
      'content_overflow'       => 'scroll',
      'content_transparent_bg' => 'scroll',
      'nav'                    => true
    }
  end

  # Page elements: media and entities
  def self.elements
    ["images", "audios", "videos", "products", "links"]
  end

  def self.index
    new(title: "Cover", handle: "index", thumb_url: "assets/background.jpg")
  end

  # TODO should this be scoped to an issue?
  #def self.all
  #  cache = {}

  #  pages = recursive_build('data', cache).uniq
  #  toc = pages.find{|p| p.handle == "toc" }

  #  pages.delete(toc)

  #  [index, toc].compact + pages
  #end

  def self.find(path, options = {})
    return index if path == "index"

    parent_path, child_path = path.split("/")

    page = self.build(path, options)
    page.parent_path = parent_path if child_path

    page.issue = options[:issue]
    page.children = self.recursive_build(path, {}, options)

    page.children.each do |child|
      child.issue = page.issue
      child.parent_path = parent_path

      # Rails.logger.info "Set page child: #{path}"
      # child.parent = page
    end

    page

  rescue Exception => e
    puts e.inspect
    puts e.backtrace.join("\n")
    raise path.inspect
  end

  # Convert page data from file into memory
  def self.build path, options={}, source=nil
    source ||= data_path(path, options).read
    issue = options[:issue]
    parent_path, child_path = path.split("/")

    #if "1.9".respond_to? :encoding
    #  source = source.force_encoding('binary')
    #end

    ## Build attributes from YAML
    meta, content = source.split(/---\s?\n(.+?)---\n/nm)[1,2]
    content = content.to_s
    attributes = meta ? YAML.load(meta) : {}

    # Add index and summary to products
    Array(attributes['products']).each_with_index do|p, i|
      p['index'] = i + 1
      p['summary'] = p['description']
    end

    # Convert media and entity url array into hash
    self.elements.each do |element|
      attributes[element] = attributes[element].to_a.map do |object|
        if object.is_a? String
          if element == 'links'
            key = 'link'
          elsif element == 'images'
            key = 'url'
          else
            raise "Unsupported element: #{element}"
          end

          object = {key => object}
        end

        Hashie::Mash.new(object)
      end
    end

    # Add cover url into images
    if attributes["cover_url"]
      cover = Hashie::Mash.new(
        "caption"   => attributes.delete("cover_caption"),
        "url"       => attributes["cover_url"],
        "thumb_url" => attributes["thumb_url"],
        "cover"     => true
      )
      attributes["images"].push(cover)
    end
    
    attributes["images"].map! do |image|
      image.layout = image.layout || !!image.cover
      image.type ||= "image"
      image
    end
    
    attributes["videos"].map! do |video|
      video.type ||= "video"
      video
    end


    # TODO push this responsibility to view model
    #
    # Custom Callback to format asset for app page elements
    #if formatter = options[:format_asset]
    #  self.elements.each do |element|
    #    attributes[element] = attributes[element].to_a.map do |item|
    #      formatter.call(item, element)
    #    end
    #  end
    #end

    # Find cover from video/image
    if !attributes["cover_url"]
      cover = (attributes["images"] + attributes["videos"]).compact.find{|img| img.cover }
      attributes["cover_url"] = cover.try(:url)
    end
    attributes["cover"] = cover
    
    # construct HTML-mustache for content or custom_html
    if attributes.key? 'custom_html'
      attributes['custom_html'] = content
    else
      attributes['content'] = RDiscount.new(content).to_html
    end

    layout = self.default_layout.merge(attributes['layout'] || {})
    layout.merge!(options['layout'] || options[:layout] || {})

    attributes.merge!(
      "issue"    => issue,
      "handle"   => path.split('/').last,
      "path"     => path,
      "layout"   => layout,
    )

    new attributes

  #rescue Exception => e
  #  raise "Page: #{path} failed to build, #{e.inspect}"
  end

  def self.recursive_build path, cache={}, options={}
    issue = options[:issue]

    data_path = data_path(path, options).sub_ext('')

    Dir.glob("#{data_path}/*").sort.map do |child_path|
      if File.directory? child_path
        page = cache[child_path + '.md'] = build(child_path, options)
        page.children = recursive_build(child_path, cache, options)

      elsif ! cache[child_path]
        page = cache[child_path] = build("#{path}/#{File.basename(child_path, '.md')}", options)

      else
        page = cache[child_path]
      end

      page
    end
  end

  def self.data_path path, options={}
    if issue = options[:issue]
      full_path = issue.path.join("data/#{path}.md")
    else
      full_path = "data/#{path}.md"
    end

    Pathname full_path
  end

  def self.boolean_value value
    value = value.to_s.strip
    [/true/i, /yes/i, '1'].any?{|v| v === value}
  end


  def cover
    (images.to_a + videos.to_a).find {|media| media.cover == true }
  end

  def cover_url
    if !self["cover_url"] && cover
      cover.type.try(:include?, "video") ? cover.thumb_url : cover.url
    else
      self["cover_url"]
    end
  end

  def parent
    @parent ||= LocalIssue::Page.find(parent_path, issue: issue) if parent_path
  end

  def number
    if parent
      count = parent.children.map(&:handle).index(handle) + 1
      count = count + parent.number
    else
      issue.pages.index(self) + 1
    end
  end

  def byline
    if author_name
      "by #{author_name}"
    else
      self[:byline]
    end
  end

  def issue=(issue)
    self[:issue] ||= issue
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

  # Map attributes for import
  #
  def to_hash options={}
    hash = super.except("id", "issue", "cover_url", "thumb_url", "cover")

    hash["title"] ||= "Table of Content" if handle == "toc"

    return hash unless options[:local_path]

    self.class.elements.each do |element|
      Array(hash[element]).each_with_index do |asset, index|
        convert_local_path!(asset)
        hash[element][index] = asset
      end
    end

    hash['children'] = children.map do |page|
      page.to_hash(options)
    end

    hash
  end

  def convert_local_path! asset
    asset.keys.each do |key|
      next unless is_local = (key.end_with?('_url') || key == 'url') && asset[key] && ! asset[key].start_with?('http://', 'https://')

      field = key.end_with?('_url') ? key.sub(/_url$/, '') : 'file'
      url = asset.delete(key)

      asset[field] = issue.path.join(url)
    end

    asset
  end
end
