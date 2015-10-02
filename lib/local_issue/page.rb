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

  def self.default_style
    {
      'content_style'          => 'white',
      'type'                   => 'one-column',
      'image_style'            => 'cover',
      'image_align'            => 'left',
      'content_align'          => 'left',
      'content_valign'         => 'top',
      'content_height'         => 'auto',
      'content_overflow'       => 'scroll',
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

  def self.find path, options={}
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

  #rescue Exception => e
  #  puts e.inspect
  #  puts e.backtrace.join("\n")
  #  raise path.inspect
  end

  # Convert page data from file into memory
  def self.build path, options={}, source=nil
    source ||= data_path(path, options).read
    issue = options[:issue]
    parent_path, child_path = path.split("/")

    ## Build attributes from YAML
    meta, content = source.split(/---\n(.+?)---\n/m)[1,2]
    content = content.to_s

    attributes = YAML.load(meta) if meta
    attributes ||= {}

    # Add index and summary to products
    Array(attributes['products']).each_with_index do|p, i|
    #  p['index'] = i + 1
      p['summary'] = p.delete('description')
    end

    # Convert media and entity url array into hash
    self.elements.each do |element|
      attributes[element] = attributes[element].to_a.each_with_index.map do |object, index|
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

        object['index'] = index+1

        Hashie::Mash.new(object)
      end
    end

    # Add cover url into images
    if attributes['cover_url'] || attributes['thumb_url']
      cover = Hashie::Mash.new(
        'caption'   => attributes.delete('cover_caption'),
        'cover'     => true
      )

      cover.url = attributes['cover_url'] if attributes['cover_url']
      cover.thumb_url = attributes['thumb_url'] if attributes['thumb_url']

      attributes["images"].push(cover)
    end

    attributes["images"].map! do |image|
      image.type ||= "image"
      image
    end

    attributes["videos"].map! do |video|
      video.type ||= "video"
      video
    end

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

    # FIXME rename page.layout to page.style
    style = attributes['layout'] || attributes['style'] || {}

    style = self.default_style.merge(style)
    style.merge!(options['style'] || options[:style] || {})
    %w[content_transparent hide_author].each do |field|
      if style.key? field
        case style[field]
        when '1', 'yes' then style[field] = true
        when '0', 'no'  then style[field] = false
        end
      end
    end

    attributes['issue'] ||= issue
    attributes['handle'] ||= path.split('/').last
    attributes['path'] = path
    attributes['style'] = Hashie::Mash.new(style)

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

  def initialize *args
    super

    self['style'] ||= Hashie::Mash.new(self.class.default_style)
  end

  def find_element id
    return unless id

    asset, index = id.split(':')

    if find_by_id = index.nil? || index.empty?
      media = %w[audios images videos].reduce(nil) do |_, e|
        if found = self[e] && self[e].find{|m| m['id'] == id}
          asset = e
          break found
        end
      end
    else
      media = self[asset][index.to_i - 1] if self[asset]
    end

    if media
      [asset, media]
    end
  end

  def toc?
    handle == 'toc'
  end

  def cover
    images.to_a.find {|media| media['cover'] } ||
      videos.to_a.find {|media| media['cover'] }
  end

  def cover_url
    if !self["cover_url"] && cover
      cover.type.try(:include?, "video") ? cover.thumb_url : cover.url
    else
      self["cover_url"]
    end
  end

  def thumb_url
    self["thumb_url"] ||
      if cover = self.cover
        cover.thumb_url
      end
  end

  def root_page?
    ! parent_path
  end

  def child_page?
    ! root_page?
  end

  def parent
    @parent ||= LocalIssue::Page.find(parent_path, issue: issue) if parent_path
  end

  def summary
    self['summary'] ||  self['description']
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

    if dark_themes.include? style.try(:content_style)
      "black"
    else
      "white"
    end
  end

  def url
    self.handle
  end
end
