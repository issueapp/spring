require 'local_issue'
require 'mustache'
require 'rdiscount'
require 'nokogiri'

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

  def self.all
    cache = {}

    pages = recursive_build('data', cache).uniq
    toc = pages.find{|p| p.handle == "toc" }

    pages.delete(toc)

    [index, toc].compact + pages
  end

  def self.find(path, options = {})
    return index if path == "index"

    parent_path, child_path = path.split("/")

    if issue = options[:issue]
      full_path = "#{issue.path}/data/#{path}.md"
    else
      full_path = "data/#{path}.md"
    end

    page_dir = Pathname(full_path).basename(".md")
    page = self.build(full_path, options)
    page.parent_path = parent_path if child_path

    page.issue = options[:issue]
    page.children = self.recursive_build("data/#{page_dir}", {}, options)

    page.children.each do |child|
      child.issue = page.issue
      child.parent_path = parent_path

      # Rails.logger.info "Set page child: #{path}"
      # child.parent = page
    end

    page

  rescue Exception => e
    puts e.inspect
    raise path.inspect
  end

  # Load markdown file into memory
  def self.build(path, options = {})
    source = open(path).read
    issue = options[:issue]
    parent_path, child_path = path.split("/")

    if "1.9".respond_to? :encoding
      source = source.force_encoding('binary')
    end

    ## Build attributes from YAML
    meta, content = source.split(/---\s?\n(.+?)---\n/nm)[1,2]
    attributes = meta ? YAML.load(meta) : {}

    # Format attribute
    if attributes["products"]
      attributes["products"].each_with_index do|p, i|
        p["index"] = i + 1
        p["summary"] = p["description"]
      end
    end

    # Convert media and entity url array into hash
    self.elements.each do |element|
      attributes[element] = attributes[element].to_a.map do |object|
        object = {'link' => object} if element == 'links' && object.is_a?(String)
        Hashie::Mash.new(object)
      end
    end

    # Add cover url into images
    if attributes["cover_url"]
      attributes["images"].push(
        Hashie::Mash.new(
          "caption"   => attributes.delete("cover_caption"),
          "url"       => attributes["cover_url"],
          "thumb_url" => attributes["thumb_url"],
          "cover"     => true
        )
      )
    end

    attributes["images"].map! do |image|
      image.layout = image.layout || !!image.cover
      image
    end

    # Custom Callback to format asset for app page elements
    if formatter = options[:format_asset]
      self.elements.each do |element|
        attributes[element] = attributes[element].to_a.map(&formatter)
      end
    end

    # Render content part
    attributes["raw_content"] = content.to_s.strip
    content = Mustache.render(content.to_s.strip, attributes)

    # Get script/style tag
    doc = Nokogiri::HTML.fragment(content)
    script_and_style = doc.search('style')[0].to_s + doc.search('script')[0].to_s

    content = RDiscount.new(content.to_s.strip).to_html + script_and_style

    # Layout
    if options[:layout]
      attributes["layout"].merge!(options[:layout])
    end
    layout = attributes.fetch("layout", {}).reverse_merge(self.default_layout)
    layout["hide_author"] = "1" if child_path
    
    attributes.merge!(
      "issue"           => issue,
      "handle"          => path.gsub("#{issue.path}/data/", '').gsub(".md", ''),
      # "published_at"    => attributes["published_at"] || File.mtime(path).to_i,
      "layout"          => layout,
      "content"         => content
    )

    new(attributes)

  rescue Exception => e
    raise "Page: #{path} failed to build, #{e.inspect}"
  end

  def self.recursive_build(start_path, cache = {}, options = {})
    issue = options[:issue]

    Dir.glob("#{issue.path}/#{start_path}/*").sort.map do |path|
      # path.gsub!(issue_path.to_s + "/", '')

      if File.directory?(path)
        page = cache[path + '.md'] = build(path + '.md', options)
        page.children = recursive_build(path, cache, options)

      elsif !cache[path]
         page = cache[path] = build(path, options)

      else
        page = cache[path]
      end
      page
    end
  end

  def cover
    (images.to_a + videos.to_a).find {|media| media.cover == true }
  end

  def cover_url
    if !self["cover_url"] && cover
      return cover.try(:type).include?("video") ? cover.thumb_url : cover.url
    else
      return self["cover_url"]
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
    hash = super.except("id", "issue", "cover_url", "thumb_url")

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
      next unless should_convert = (key.end_with?('_url') || key == 'url') && asset[key] && ! asset[key].start_with?('http://', 'https://')

      field = key.end_with?('_url') ? key.sub(/_url$/, '') : 'file'
      url = asset.delete(key)

      asset[field] = issue.path.join(url)
    end

    asset
  end
end
