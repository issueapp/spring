require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/object/blank'
require 'fastimage'
require 'mustache'
require 'nokogiri'
require 'timeout'
require 'uri'

begin
  Issue
rescue NameError
  Issue = Module.new
end

Struct.new('Author', :name, :icon)

class Issue::PageView

  # FIXME unstable API
  def custom_html?
    page.custom_html.present?
  end

  # end FIXME unstable API

  attr_reader :page, :context

  def initialize page, context=nil
    @page = page
    @context = context
  end

  def method_missing(name, *args, &block); page.send(name, *args, &block); end
  def respond_to_missing?(name, include_private=false); page.send('respond_to_missing?', name, include_private); end

  def dom_id
    "s#{handle}"
  end

  def layout_class options={}
    has_header  = !empty_content?(title) || !empty_content?(summary)
    has_content = !empty_content?(page.content)
    has_product = page.product_set?
    has_cover   = page.cover_url && page.layout.image_style != "none"
    editing     = options[:editing]

    classes = ["page", "page-fadein", page.type, page.layout.custom_class]

    # HACK: Migrate all page type video with one column, use video.cover = true instead
    page.layout.type = "one-column" if page.layout.type == "video"

    classes << (page.layout.type || 'two-column') unless page.toc?

    classes << 'toc'         if page.toc?
    classes << 'has-product' if has_product
    classes << 'no-header'   if !editing && !has_header
    classes << 'no-content ' if !editing && !has_content
    classes << 'no-image'    if !editing && !has_cover
    
    classes << (page.layout.content_style    || 'white')
    classes << ('transparent') if page.layout.content_transparent == "1"

    if page.layout.type != "custom"
      classes << (page.layout.content_overflow || 'scroll')
      classes << (page.layout.content_align    || 'left')
      classes << (page.layout.content_valign   || 'middle')

      classes << ("height-#{page.layout.content_height || 'auto'}")
      classes << "image-#{page.layout.image_style}" if page.layout.image_style
      classes << ("cover-#{page.layout.image_align || "left" }")
    end

    classes.join(' ').squeeze(' ')
  end

  def show_author?
    hide_author = [/true/i, /yes/i, '1'].any?{|v| v === layout.hide_author.to_s}
    ! hide_author && root_page? && author
  end

  def author
    return page.author if page.author

    name = page.author_name
    icon = page.author_icon if page.respond_to? 'author_icon'

    if name
      Struct::Author.new(name, icon)
    end
  end

  def column_break_count
    count = 0

    has_cover_url = ! page.cover_url.blank?

    count += 1 if has_cover_url || product_set?
    count += 1 if layout.type == 'three-column' && has_cover_url

    count
  end

  def custom_html json=nil
    json ||= send('json')
    render_html(page.custom_html, json)
  end

  def content_html json=nil
    json ||= send('json')
    render_html(page.content, json)
  end

  def cover_html
    return unless (cover = page.cover)

    container_class = "cover-area #{layout.image_style}  #{cover.style}  #{cover.type.to_s.split('/').first}".squeeze(' ')
    container_class << ' play' if cover.autoplay

    container_background = "background-image: url(#{asset_url(cover, 'thumb' => cover.type.to_s.include?('video'))})"

    attributes = {:class => container_class, :style => container_background}
    fragment = create_element('figure', attributes) do |figure|

      #  TODO unsure what to do with this?
      #  <% if page.cover.style == 'overlay' %>
      #    <%= header_area %>
      #  <% end %>
      #  end TODO unsure what to do with this?

      if cover.type.include? 'video'
        if embed_video? cover.link
          figure << video_iframe_html(
            cover.link,
            page.cover.to_hash.merge(lazy: true, autoplay: true)
          )
        else
          attributes = {
            :src => asset_url(cover),
            'data-media-id' => cover.id,
            :poster => asset_url(cover, 'thumb' => true)
          }
          attributes['data-autoplay'] = '' if cover.autoplay
          attributes['loop'] = '' if cover.loop

          figure << create_element('video', attributes)
        end
      end

      if cover.caption.present?
        figure << create_element('figcaption', :class => 'inset') do |figcaption|
          figcaption << cover.caption
        end
      end
    end

    html = fragment.to_html
    html = html.html_safe if html.respond_to? :html_safe
    html
  end

  def product_set_html
    container_class = 'product-set'
    container_class << " set-#{(page.products.to_a.count/2.0).ceil*2}" 
    container_class << ' cover-area' unless page.cover

    fragment = create_element('ul', :class => container_class) do |ul|
      page.products.each_with_index do |product, index|
        ul << create_element('li') do |li|
          attributes = product_hotspot_attributes(product)
          li << create_element('a', attributes) do |a|
            a << create_element('img', :src => asset_url(product, 'image' => true))
            a << create_element('span', index + 1, :class => 'tag')
          end
        end
      end
    end

    html = fragment.to_html
    html = html.html_safe if html.respond_to? :html_safe
    html
  end

  private

  def render_html content, json
    html = Mustache.render(content, json)
    html = decorate_media(html)
    html = html.html_safe if html.respond_to? :html_safe
    html
  end

  def json
    if page.respond_to? 'to_hash'
      hash = page.to_hash
    else
      hash = page.as_json(methods: [:cover_url, :cover_caption, :thumb_url, :link])
      hash['id'] = hash.delete('_id')
    end

    hash["cover_url"] = asset_path(hash["cover_url"])
    hash["thumb_url"] = asset_path(hash["thumb_url"])

    if show_author?
      hash['byline'] = "by #{author.name}"
      hash['author_icon'] = author.icon
      hash['show_author'] = true
    end

    hash['layout'] = layout

    %w[images videos].each do |element|
      next unless hash[element]

      # make cover on top level
      hash['cover'] ||= hash[element].find{|m| m['cover'] }

      page_element = page.send(element)
      hash[element].each_with_index do |object, i|
        object['url'] = asset_url(page_element[i])
      end
    end

    %w[products links].each do |element|
      next unless hash[element]

      page_element = page.send(element)
      hash[element].each_with_index do |object, i|
        object['image_url'] = asset_url(page_element[i], 'image' => true)
        object['url'] = object['link']
      end
    end

    # Convert ObjectId, Date to string
    hash = hash.as_json if hash.respond_to? 'as_json'

    hash
  end


  def asset_path value
    value = context.asset_path(value) if context.respond_to? 'asset_path'
    value
  end

  def asset_url object, options={}
    if thumb = options['thumb'] || options[:thumb]
      url = object['thumb_url'] || object.thumb.try('url')

    # product, link
    elsif image = options['image'] || options[:image]
      url = object['image_url'] || object.image.try('url')

    # media: image, video, audio
    else
      url = object['url'] || object['file_url'] || object.file.try('url')
    end

    asset_path url
  end

  # Swap data-media-id
  # videos:1
  # images:1
  def decorate_media content
    return unless content

    doc = Nokogiri::HTML.fragment('<div>' << content << '</div>')

    doc.search('[data-media-id]').each do |node|

      asset, media = page.find_element(node['data-media-id'])

      unless media
        log_method.call("Media not found: #{node['data-media-id']}")
        next
      end

      case asset
      when 'images'
        if node['data-background-image']
          node['style'] = "background-size: cover; background-image:url(#{asset_url media})"

        elsif ! node['data-original']
          node.replace image_node(node, media)
        end

      when "videos"
        node.replace video_node(node, media)

      when "audios"
        node.replace audio_node(node, media)

      else
        log_method.call("Unknow asset: #{asset})
      end
    end

    doc.child.inner_html
  end

  def affiliate_url url
    @affiliate_urls ||= begin
      data_path = File.expand_path("../../../issues/#{issue.handle}/affiliate_products.yml", __FILE__)
      File.readable?(data_path) && YAML.load_file(data_path) || {}
    end

    @affiliate_urls[url] || url
  end

  def product_hotspot_attributes product
    {
      :href => affiliate_url(product[:url]),
      :class => 'product hotspot',
      :title => product.title,
      :'data-track' => 'hotspot:click',
      :'data-action' => product[:action],
      :'data-url' => product[:url] || product[:link],
      :'data-image' => asset_url(product, 'image' => true),
      :'data-price' => product[:price],
      :'data-currency' =>  product[:currency],
      :'data-description' => product[:description],
    }
  end

  def empty_content? content
    fragment = Nokogiri::HTML.fragment(content)

    fragment.inner_text.blank? &&
      #fragment.css('img,video,[data-media-id]').length == 0 &&
      fragment.css('img').length == 0 &&
        fragment.css('video').length == 0 &&
          fragment.css('[data-media-id]').length == 0
  end

  # <img>
  # <figure>
  #   <img src="../assets/1-styling-it-out/_MG_5433_1024@2x.jpg" width=80%>
  #   <figcaption>Her ‘favourite permanent accessory’, CP is the proud owner of over 65 tattoos - although she admits to having lost count of the exact number</figcaption>
  # </figure>
  #  <figure>
  #   <img data-media-id="images:1" src="../assets/1-styling-it-out/20130906-20130906MinkPink_ChristinaPerri_0006-15.jpg">
  #   <figcaption class="inset">
  #     MINKPINK Rock Me Again Playsuit.
  #   </figcaption>
  #   <figcaption>Although a tomboy at heart, Christina admits the last 3 years have seen her become ‘obsessed’ with fashion.</figcaption>
  # </figure>
  def image_node node, image
    caption_options = {}
    caption_options[:class] = 'inset' if image['caption_inset']

    width, height, aspect_ratio = image_get_size(image)
    max_dimension = "max-height: #{height}px; max-width: #{width}px"
    padding = 100/(aspect_ratio || 1.5)

    node['src'] = asset_url(image)

    if node.parent && node.parent.name == "figure"
      figure = node.parent.clone
      figure['style'] = max_dimension
    else
      figure = create_element('figure', class: 'image', style: max_dimension)
    end
    figure.inner_html = node.to_s

    figure << create_element('div',
      class: 'aspect-ratio', 
      style: "padding-bottom: #{padding}%; max-height: #{height}px"
    )

    figure << create_element('figcaption', image["caption"], caption_options) if image["caption"].present?

    figure
  end

  # <video data-media-id="videos:1" type="video/youtube" src="http://youtube.com/watch?v=8v_4O44sfjM"  poster="../assets/1-styling-it-out/Jar-of-Hearts-christina-perri-16882990-1280-720.jpg"/>
  # <figure class="video">
  #   <img class="thumbnail" src="../assets/1-styling-it-out/A-Thousand-Years-christina-perri-26451562-1920-1080.jpg">
  #   <iframe data-src="http://www.youtube.com/embed/rtOvBOTyX00?autohide=1&amp;autoplay=1&amp;color=white&amp;controls=0&amp;enablejsapi=1&amp;hd=1&amp;iv_load_policy=3&amp;origin=http%3A%2F%2Fissueapp.com&amp;rel=0&amp;showinfo=0&amp;wmode=transparent&amp;autoplay=1" frameborder="0" height="100%" width="100%" webkitallowfullscreen="" mozallowfullscreen="" allowfullscreen="" style="position: absolute; top: 0; left:0 "></iframe>
  #   <figcaption>Christina’s newest album ‘Head or Heart' is set for release in February 2014</figcaption>
  # </figure>

  # Params:
  #    autoplay: true | false
  #    controls: true | false
  #    loop:     true | false
  def video_node node, video
    video["autoplay"] ||= true
    video["controls"] ||= false

    # TODO: Double check video url & link
    video_url = video["url"] || video["link"]

    # Setup video params
    options = {
      type:     video["type"],
      src:      video_url,
      # autoplay: video["autoplay"] ? true : nil,
      'data-autoplay': video["autoplay"] ? true : nil,
      controls: video["controls"] ? true : nil,
      height:   video["height"],
      width:    video["width"],
      loop:     video["loop"],
      muted:    video["muted"],
    }.delete_if { |k,v| v.nil? }

    figure = create_element('figure', :class => "video")
    figure << create_element("div",
      class: "thumbnail",
      style: "background-image: url('#{asset_url(video, 'thumb' => true)}')"
    )

    # Detect embed videos
    if embed_video? video_url
      figure.inner_html += video_iframe_html(video_url, options.merge(lazy: true))

    # Use HTML5 native Video element
    else
      options[:poster] = video["thumb_url"] if video["thumb_url"]
      options[:mute]   = video["mute"]

      figure << create_element("video", options)
    end

    if video["caption"]
      options = {}
      options[:class] = "inset" if video["caption_inset"]
      figure << create_element("figcaption", video["caption"], options)
    end

    figure
  end

  def audio_node(node, media)
    # Setup audio params
    options = {
      type:     media["type"],
      src:      asset_url(media),
      'data-autoplay': media["autoplay"] ? true : nil,
      controls: media["controls"] ? true : nil,
      loop:     media["loop"],
      muted:    media["muted"]
    }.delete_if { |k, v| v.nil? }

    figure = create_element('figure', :class => "audio")
    figure << create_element("img", class: "thumbnail", src: asset_url(media, 'thumb' => true))

    audio = create_element("audio", options)
    figure << audio

    if media["caption"]
      options = {}
      options[:class] = "inset" if media["caption_inset"]
      figure << create_element("figcaption", media["caption"], options)
    end

    figure
  end

  # TODO: pass html5 compatible params
  # autoplay, controls, loop, width, height
  def video_iframe_html url, options={}
    params = {
      autoplay: options[:autoplay] ? "1" : "0",
      controls: options[:controls] ? "1" : "0",
      loop:     options[:loop] ? "1" : "0"
    }

    embed_url = case url
      when /youtube\.com\/watch\?v=(.+)/
        "http://youtube.com/embed/#{$1}?#{URI.escape(params.to_param)}&amp;playlist=#{$1}&amp;autohide=1&amp;color=white&amp;enablejsapi=1&amp;hd=1&amp;iv_load_policy=3&amp;origin=http%3A%2F%2Fissueapp.com&amp;rel=0&amp;showinfo=0&amp;wmode=transparent"
      when /vimeo\.com\/([^\/]+)/
        "http://player.vimeo.com/video/#{$1}?#{URI.escape(params.to_param)}&amp;byline=0&amp;portrait=0"
    end

    if options[:lazy]
      source = "data-src=\"#{embed_url}\""
    else
      source = "src=\"#{embed_url}\""
    end

    "<iframe #{source} frameborder=0 height=#{options[:height] || "100%" } width=#{options[:width] || "100%" } webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>"
  end

  def embed_video? url
    return false unless url
    !! (url.match(/youtube\.com\/watch\?v=(.+)/) || url.match(/vimeo\.com\/([^\/]+)/))
  end

  def create_element *args, &block
    Nokogiri::HTML('').create_element(*args, &block)
  end

  def image_get_size image
    if image.respond_to? 'attributes'
      size = image.attributes.values_at('file_width', 'file_height', 'file_aspect_ratio')
      return size if size.all?
    end

    file = File.join(issue.path, image['url'])
    raise "local image not found: #{file}" unless File.exist? file

    Timeout::timeout(0.2) do
      width, height = FastImage.size(file)

      # FastImage is unable to detect width and height for svg
      # https://github.com/sdsykes/fastimage/issues/49
      return unless width && height

      aspect_ratio = width.to_f / height

      [width, height, aspect_ratio]
    end
  end

  def log_method
    @log_method ||=
      if defined? Rails
        Rails.logger.method :debug
      else
        method :puts
      end
  end
end
