require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/object/blank'
require 'fastimage'
require 'mustache'
require 'nokogiri'
require 'timeout'
require 'uri'

Struct.new('Author', :name, :icon)

class Issue::PageView

  # FIXME unstable API
  def custom_html?
    page.custom_html.present?
  end
  # end FIXME unstable API

  attr_reader :page
  attr_accessor :context, :edit_mode

  def initialize page, context=nil, edit_mode=false
    @page = page
    @context = context
    @edit_mode = edit_mode
  end

  def class; page.class; end
  def method_missing(name, *args, &block); page.send(name, *args, &block); end
  def respond_to?(name, include_private=false); page.send('respond_to?', name, include_private); end
  def respond_to_missing?(name, include_private=false); page.send('respond_to_missing?', name, include_private); end

  def dom_id
    "s#{path.parameterize}"
  end

  def layout_class options={}
    has_header  = !empty_content?(title) || !empty_content?(summary)
    has_content = !empty_content?(page.content) || !empty_content?(page.custom_html)
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

  def custom_html json=nil, html_safe=true
    json ||= send('json')
    render_html(page.custom_html, json, html_safe)
  end

  def content_html json=nil, html_safe=true
    json ||= send('json')
    render_html(page.content, json, html_safe)
  end

  def cover_html
    return unless (cover = page.cover)

    container_class = "cover-area #{cover.type.to_s.split('/').first}".squeeze(' ')
    container_class << ' play' if cover.autoplay

    container_background = "background-image: url('#{asset_url(cover, 'thumb' => cover.type.to_s.include?('video'))}')"

    attributes = {:class => container_class, :style => container_background}
    figure = create_element('figure', attributes)

    #  TODO unsure what to do with this?
    #  <% if page.cover.style == 'overlay' %>
    #    <%= header_area %>
    #  <% end %>
    #  end TODO unsure what to do with this?

    if cover.type.include? 'video'
      if embed_video? cover.link
        params = cover.respond_to?('to_hash') ? cover.to_hash : cover.attributes
        params.key?('autoplay') || (params['autoplay'] = true)
        figure << video_iframe_html(cover.link, params)
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

    html = figure.to_html
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
            a << create_element('img', :src => attributes[:'data-image'])
            a << create_element('span', index + 1, :class => 'tag')
          end
        end
      end
    end

    html = fragment.to_html
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

    hash['parentTitle'] = page.parent.title if page.parent

    #hash["cover_url"] = asset_path(hash["cover_url"])
    #hash["thumb_url"] = asset_path(hash["thumb_url"])

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

        object["thumb_url"] = asset_url(page_element[i], thumb: true)
        object['url'] = asset_url(page_element[i])
      end
    end

    %w[products links].each do |element|
      next unless hash[element]

      page_element = page.send(element)
      hash[element].each_with_index do |object, i|
        object['index'] = i + 1
        object['image_url'] = asset_url(page_element[i], 'image' => true)
        object['url'] = object['link']
        object['description'] = object['summary']
      end
    end

    # Convert ObjectId, Date to string
    hash = hash.as_json if hash.respond_to? 'as_json'

    hash
  end

  private

  def render_html content, json, html_safe
    html = Mustache.render(content, json)
    html = decorate_media(html)
    html = html.html_safe if html_safe && html.respond_to?(:html_safe)
    html
  end

  def asset_path value
    if context.respond_to? 'asset_path'
      context.asset_path value
    else
      value
    end
  end

  def asset_url object, options={}
    if thumb = options['thumb'] || options[:thumb]
      url = object['thumb_url'] || object.try('thumb').try('url')

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
  # audios:1
  # images:1
  # videos:1
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
        decorate_image(node, media)

      when "videos"
        decorate_video(node, media)

      when "audios"
        decorate_audio(node, media)

      else
        log_method.call("Fail to decorate unknown asset: #{asset}")
      end
    end

    doc.child.inner_html
  end

  def affiliate_url url
    return url unless issue

    @affiliate_urls ||= begin
      data_path = File.join(issue.path, 'affiliate_products.yml')
      File.readable?(data_path) && YAML.load_file(data_path) || {}
    end

    @affiliate_urls[url] || url
  end

  def product_hotspot_attributes product
    {
      :href => affiliate_url(product['link']),
      :class => 'product hotspot',
      :title => product.title,
      :'data-track' => 'hotspot:click',
      :'data-action' => product[:action],
      :'data-url' => product['link'],
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
  def decorate_image node, image
    if node.name == 'img'
      node['src'] = asset_url(image)
    end

    return node if edit_mode

    if node['data-background-image']
      node['style'] = "background-size: cover; background-image:url(#{asset_url image})"
    end

    return node if node['data-original'] || node.matches?('.cover-area')

    caption_options = {}
    caption_options[:class] = 'inset' if image['caption_inset']

    width, height, aspect_ratio = image_get_size(image)
    max_dimension = "max-height: #{height}px; max-width: #{width}px"
    padding = 100/(aspect_ratio || 1.5)

    if node.parent && node.parent.name == 'figure'
      figure = node.parent.clone
      figure['style'] = max_dimension
      figure.inner_html = node.to_s

    elsif node.name != 'figure'
      figure = create_element('figure', class: 'image', style: max_dimension)
      figure.inner_html = node.to_s
    end

    figure << create_element('div',
      class: 'aspect-ratio',
      style: "padding-bottom: #{padding}%; max-height: #{height}px"
    )

    figure << create_element('figcaption', image["caption"], caption_options) if image["caption"].present?

    node.replace figure
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
  def decorate_video node, video
    if edit_mode
      decorated = create_element('video', poster: asset_path('ui/video-play.svg'),
        'data-media-id' => node['data-media-id'],
        style: "background-image: url('#{asset_url(video, 'thumb' => true)}')"
      )

    else
      # TODO: Double check video url & link
      video_url = video['url'] || video['link']

      options = {
        type:          video['type'],
        :'data-src' => video_url,
        'autoplay'  => extract_value_from(video, key='autoplay', default=true),
        controls:      extract_value_from(video, key='controls', default=false),
        width:         video['width'],
        height:        video['height'],
        loop:          video['loop'],
        mute:          video['mute'],
        #muted:         video['muted'],
      }

      decorated = create_element('figure', class: "video",
        style: "background-image: url('#{asset_url(video, 'thumb' => true)}')"
      )

      if embed_video? video_url
        decorated << video_iframe_html(video_url, options)

      else
        options[:'data-autoplay'] = true if options.delete(:autoplay)

        decorated << create_element('video', options)
      end

      if video['caption'].present?
        options = {}
        options[:class] = 'inset' if video['caption_inset']
        decorated << create_element('figcaption', video['caption'], options)
      end
    end

    node.replace decorated
  end

  def decorate_audio node, audio
    # Setup audio params
    options = {
      type:     audio['type'],
      src:      asset_url(audio),
      'data-autoplay': audio['autoplay'] ? true : nil,
      controls: audio['controls'] ? true : nil,
      loop:     audio['loop'],
      muted:    audio['muted'],
      'data-global': audio['global'],
      'data-scope': audio['scope']
    }.delete_if { |k, v| v.nil? }

    figure = create_element('figure', :class => 'audio')
    figure << create_element('img', class: 'thumbnail', src: asset_url(audio, 'thumb' => true))

    audio = create_element('audio', options)
    figure << audio

    if audio['caption']
      options = {}
      options[:class] = 'inset' if audio['caption_inset']
      figure << create_element('figcaption', audio['caption'], options)
    end

    node.replace figure
  end

  def video_iframe_html url, params={}
    width = params.delete(:width) || params.delete('width') || '100%'
    height = params.delete(:height) || params.delete('height') || '100%'

    whitelist = ['autoplay', 'controls', 'loop', 'muted']
    params = params.slice(*whitelist)
    whitelist.each do |name|
      params[name] = params[name] ? 1 : 0
    end

    case url
    when /youtube\.com\/watch\?v=(.+)/
      params = params.merge(
        playlist: $1,
        autohide: 1,
        color: 'white',
        enablejsapi: 1,
        hd: 1,
        iv_load_policy: 3,
        origin: 'https://issueapp.com',
        rel: 0,
        showinfo: 0,
        wmode: 'transparent',
      )
      embed_url = "https://youtube.com/embed/#{$1}"

    when /vimeo\.com\/([^\/]+)/
      params = params.merge(
        byline: 0,
        portrait: 0,
      )
      embed_url = "http://player.vimeo.com/video/#{$1}"

    else
      raise ArgumentError, "Unsupported url: #{url}"
    end

    embed_url << "?#{URI.escape(params.to_param)}"

    source = %{data-src="#{embed_url}"}

    %{<iframe #{source} frameborder="0" width="#{width}" height="#{height}" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>}
  end

  def extract_value_from object, key, default
    if object.respond_to? 'has_attribute?'
      object.has_attribute?(key) ? object[key] : default
    elsif object.respond_to? 'fetch'
      object.fetch(key) { default }
    else
      default
    end
  end

  def embed_video? url
    return false unless url
    !! (url.match(/youtube\.com\/watch\?v=(.+)/) || url.match(/vimeo\.com\/([^\/]+)/))
  end

  def create_element *args, &block
    doc = Nokogiri::HTML('')
    doc.encoding = 'utf-8'
    doc.create_element(*args, &block)
  end

  def image_get_size image
    if image.width && image.height
      return [image.width, image.height, image.aspect_ratio.to_f]
    end

    unless issue
      if defined? RSpec
        log_method.call('Issue not found.')
        return
      else
        raise 'Issue not found'
      end
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
