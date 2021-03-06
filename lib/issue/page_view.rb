require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/object/blank'
require 'fastimage'
require 'mustache'
require 'nokogiri'
require 'timeout'
require 'uri'

Struct.new('Author', :name, :icon, :image)

Issue rescue Issue = Module.new
class Issue::PageView

  YOUTUBE_RE = %r{youtube\.com/watch\?v=(.+)}
  VIMEO_RE = %r{vimeo\.com/([^/]+)}

  # FIXME unstable API
  def custom_html?
    page.custom_html.present?
  end
  # end FIXME unstable API

  attr_reader :page

  attr_accessor :context, :edit_mode, :offline, :static
  attr_writer :json

  def initialize page, options={}
    raise ArgumentError, 'Page not present' unless page

    @page = page

    options.each do |k, v|
      setter = "#{k}="
      send(setter, v) if respond_to? setter
    end
  end

  def class; page.class; end
  def method_missing(name, *args, &block); page.send(name, *args, &block); end
  def respond_to?(name, include_private=false); super || page.send(:respond_to?, name, include_private); end
  def respond_to_missing?(name, include_private=false); super || page.send(:respond_to_missing?, name, include_private); end

  def page_title
    case
    when page.title
      title = page.title
    when page.toc?
      title = "Table of Content - #{page.issue.title}"
    when page.parent
      title = "#{page.parent.title} - #{page.handle}"
    end

    if page.parent && title.downcase == page.parent.title.downcase
      title = "#{page.parent.title} - #{page.handle}"
    end

    title
  end

  def dom_id
    "s#{path.parameterize}"
  end

  def content?
    ! empty_content?(page.content) || ! empty_content?(page.custom_html)
  end

  def layout_class options={}
    has_header  = !empty_content?(title) || !empty_content?(summary)
    has_product = page.product_set?
    has_cover   = page.cover_url && page.style.image_style != "none"
    editing     = options[:editing]

    classes = ["page", page.style.custom_class]

    # HACK: Migrate all page type video with one column, use video.cover = true instead
    page.style.type = "one-column" if page.style.type == "video"

    classes << (page.style.type || 'two-column') unless page.toc?

    classes << 'toc'         if page.toc?
    classes << 'has-product' if has_product
    classes << 'no-header'   if !editing && !has_header
    classes << 'no-content ' if !editing && !content?
    classes << 'no-image'    if !editing && !has_cover

    classes << (page.style.content_style || 'white')
    classes << ('transparent') if page.style.content_transparent

    if page.style.type != "custom"

      # Header related style
      classes << 'inset' if page.style.header_inset || page.style.content_inset
      classes << "header-#{page.style.header_align}" if page.style.header_align
      classes << "header-#{page.style.header_valign}" if page.style.header_valign
      classes << "header-#{page.style.header_style}" if page.style.header_style

      # Content layout
      classes << (page.style.content_overflow || 'scroll')
      classes << (page.style.content_align    || 'left')
      classes << (page.style.content_valign   || 'middle')

      classes << ("height-#{page.style.content_height || 'auto'}")
      classes << "image-#{page.style.image_style}" if page.style.image_style
      classes << "cover-#{page.cover.type.to_s.split('/').first}" if page.cover
      classes << ("cover-#{page.style.image_align || "left" }")
    end

    classes.join(' ').squeeze(' ')
  end

  def show_title_image?
    (page.style.title_style == "image" && page.title_image) ||
      page['title_image_url']
  end

  def show_author?
    hide_author = truthy?(page.style.hide_author)
    ! hide_author && root_page? && author
  end

  def show_footer?
    is_not_custom_page = ->{
      page.style.type != 'custom'
    }

    should_show_footer = ->{
      ! page.style.custom_class.to_s.match('no-footer')
    }

    is_fullscreen = ->{
      page.style.image_style != 'background' ||
        page.style.custom_class.to_s.match('inset') &&
          page.style.type == 'one-column'
    }

    is_not_custom_page.call &&
      should_show_footer.call &&
        is_fullscreen.call
  end

  def author
    if page.author
      page.author
    elsif name = page.author_name
      Struct::Author.new(name, nil, nil)
    end
  end

  # Options
  #     json: Custom json for testing
  #     html_safe: escape html flag
  #     footer: custom footer markup
  def custom_html options = {}
    render_content(page.custom_html, options)
  end

  def content_html options = {}
    render_content(page.content, options)
  end

  def cover?
    !! page.cover_url
  end

  def thumb?
    !! page.thumb_url
  end

  def cover_class_name
    classes = "cover-area"
    classes << " #{page.cover.type.to_s.split('/').first}".squeeze(' ') if page.cover

    classes
  end

  def cover_html
    return unless (cover = json['cover'])

    content = %{<figure class="cover-area #{cover['style']&.[]('custom_class')}"></figure>}

    html = decorate_content(content) do |doc|
      doc.search('.cover-area').each do |node|

        type = cover['type']

        if is_video = type&.include?('video')
          cover['playsinline'] = true
          decorate_video(node, cover)

        elsif is_image = type&.include?('image')
          cover['style'] ||= {}
          cover['style']["caption"] = "inset"

          decorate_image(node, cover)
        end

      end
    end

    html = html.html_safe if html.respond_to? :html_safe
    html
  end

  def products_class_name
    count = page.products.count == 9 ? 9 : [(page.products.count/2.0).ceil*2, 6].min
    "set-#{count}"
  end

  def product_set_html
    container_class = 'product-set'
    container_class << " #{self.products_class_name}"
    container_class << ' cover-area' unless page.cover

    html = %{<ul class="#{container_class}"></ul>}
    html = decorate_hotspots html, { links: false, products: 'ul.product-set' }
    html = html.html_safe if html.respond_to? :html_safe

    html
  end

  def json
    @json ||= local_page_json
  end

  private

  def local_page_asset_path path
    if context.env['ORIGINAL_FULLPATH'].end_with? '/'
      prefix = page.parent ? '../..' : '..'
    elsif page.parent
      prefix = '..'
    end

    prefix ? "#{prefix}/#{path}" : path
  end

  def local_page_json
    hash = page.to_hash

    set_dimension! hash['cover']
    Array(hash['images']).each do |image|
      set_dimension! image
    end

    if cover = hash['cover']
      cover['url'] = local_page_asset_path(cover['url']) if cover['url']
      cover['thumb_url'] = local_page_asset_path(cover['thumb_url']) if cover['thumb_url']
    end

    if author = hash['author']
      if icon = author['icon']
        author['icon'] = local_page_asset_path(icon)
      end
    end

    %w[audios images videos].each do |element|
      if elements = hash[element]
        elements.each do |media|
          media['url'] = local_page_asset_path(media['url']) if media['url']
          media['thumb_url'] = local_page_asset_path(media['thumb_url']) if media['thumb_url']
        end
      end
    end

    %w[links products].each do |element|
      if elements = hash[element]
        elements.each do |link|
          link['image_url'] = local_page_asset_path(link['image_url']) if link['image_url']
        end
      end
    end

    hash
  end

  def set_dimension! image
    return unless image

    if image['url']
      width, height, aspect_ratio = image_get_size(image)
      image['width'] ||= width
      image['height'] ||= height
      image['aspect_ratio'] ||= aspect_ratio
    end
  end

  def find_element id
    type, index = id.split(':')

    if find_by_id = index.nil? || index.empty?
      type, element = ::Page::Elements.each_with_object([]) do |type, _|
        found = json[type].find{|e| e['id'] == id}
        break [type, found] if found
      end
    else
      element = json[type]&.[](index.to_i - 1)
    end

    [type, element]
  end

  # Options
  #     json: Custom json for testing
  #     html_safe: escape html flag
  #     footer: custom footer markup
  def render_content content, options={}
    html_safe = options.fetch(:html_safe){true}

    # Force HTML to use relative protocol
    json = ::MultiJson.dump(options[:json] || self.json)
    json.gsub!(%r{https?://issue\.}, '//issue.')
    json = ::MultiJson.load(json)

    html = Mustache.render(content.to_s, json)

    html = decorate_content(html, options) do |doc|
      doc.search('[data-media-id]').each do |node|
        type, media = find_element(node['data-media-id'])

        unless media
          raise "Media #{node['data-media-id']} not found in page #{page.path}"
          next
        end

        case type
        when 'images'
          decorate_image(node, media)

        when "videos"
          decorate_video(node, media)

        when "audios"
          decorate_audio(node, media)

        else
          log_method.call("Fail to decorate unknown element: #{type}")
        end
      end
    end
    html = decorate_hotspots(html)
    html = html.html_safe if html_safe && html.respond_to?(:html_safe)
    html
  end

  def decorate_hotspots html, options = {}
    doc = Nokogiri::HTML.fragment('<div>' << html << '</div>')

    links = options.key?(:links) ? options[:links] : true

    if links
      json['links'].each do |hotspot|
        if hotspot['target']
          doc.search(hotspot['target']).each do |target|
            decorate_hotspot(target, hotspot)
          end
        end
      end
    end

    products = options.key?(:products) ? options[:products] : true

    if products
      json['products'].each do |hotspot|
        target = hotspot['target'] || products
        if target.is_a? String
          doc.search(target).each do |target|
            decorate_hotspot(target, hotspot, :product)
          end
        end
      end
    end

    doc.child.inner_html
  end

  def decorate_hotspot node, hotspot, type=:link
    anchor_class = %W[
      hotspot
      #{hotspot['theme']}
      #{hotspot['position']}
      #{hotspot['custom_class']}
      #{'show-label' if hotspot['show_label']}
      #{'product' if type == :product}
    ].reject(&:blank?).join(' ')
    anchor_attributes = {
      class: anchor_class,
      href: hotspot['link']
    }

    if hotspot['hotspot']
      anchor_attributes['data-hotspot'] = hotspot['hotspot']
    end

    anchor = create_element('a', anchor_attributes)

    if type == :product && hotspot['image_url'] && node['class'].include?('product-set')
      url = relative_protocol(hotspot['image_url'])
      anchor << create_element('img', src: url)
    end

    anchor << create_element('i', hotspot['index'])
    anchor << create_element(
      'span',
      {class: "#{hotspot['label_position']}"},
      hotspot['title']
    )

    case node.name
    when 'a'
      node.attributes.each do |name, value|
        case name
        when 'href'
          anchor[name] = value if anchor[name].blank?
        when 'class'
          anchor['class'] += " #{value}"
        else
          anchor[name] = value
        end
      end
      node.replace anchor
    when 'ul'
      if node['class'].include? 'product-set'
        li = create_element('li')
        li << anchor
        node << li
      else
        raise 'Node must be ul.product-set'
      end
    else
      node << anchor
    end
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
      url = object['thumb_url'] || context.try(:dragonfly_url, object.try('thumb'))

    # product, link
    elsif image = options['image'] || options[:image]
      url = object['image_url'] || context.try(:dragonfly_url, object.image)

    # media: image, video, audio
    else
      url = object['url'] || object['file_url'] || begin
        is_s3_url = begin
          remote_url = object.file.try('remote_url').to_s
          remote_url.start_with?('http://', 'https://')
        rescue NotImplementedError
          false
        end

        if is_s3_url
          remote_url
        elsif context
          context.dragonfly_url(object.file)
        else
          object.file.url
        end
      end
    end

    if url.present?
      if offline
        "#{'../' if page.parent}assets/#{page.path}/#{filename url}"
      else
        asset_path url
      end
    end
  end

  def filename url
    if dragonfly_url = url[/([^\/]+)\?sha=.+$/, 1]
      dragonfly_url
    else
      File.basename url
    end
  end

  # Options
  #     footer: custom footer markup
  def decorate_content content, options = {}
    return unless content

    doc = Nokogiri::HTML.fragment('<div>' << content << '</div>')

    yield doc

    if footer = options[:footer]
      content_div = doc.css('> .content')

      if content_div.length > 0
        content_div.children.last.after footer
      end
    end

    # Unwrap additional block level elements inside p
    doc.search('p > article, p > figure, p > section').each do |node|
      node.parent.replace(node)
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

  def empty_content? content
    fragment = Nokogiri::HTML.fragment(content)

    fragment.inner_text.blank? &&
      #fragment.css('img,video,[data-media-id]').length == 0 &&
      fragment.css('img').length == 0 &&
        fragment.css('video').length == 0 &&
          fragment.css('[data-media-id]').length == 0
  end

  def decorate_image node, image
    url = relative_protocol(image['url'])

    if node.name == 'img'
      node['src'] = url
    end

    # Edit mode to maintain single image element in editor
    return node if edit_mode && !custom_html?

    is_original = node.has_attribute?('data-original')
    is_thumb = node.has_attribute?('data-thumb')
    is_cover_area = node.matches?('.cover-area')
    is_background_image = node.has_attribute?('data-background-image')

    if is_background_image || is_cover_area
      node['style'] = "background-image: url(\"#{url}\")"
    end

    if !is_cover_area && image['width'] && image['height'] &&
        (image['width'] >= 350 || image['height'] >= 350) &&
        image['type'] !~ /\/(gif|svg)/ &&
        !image['layout'] &&
        node['data-app-view'].nil?
      node['data-image'] = image['url']
    end

    if is_thumb && image['thumb_url']
      if is_background_image
        node['style'] = "background-image: url(\"#{image['thumb_url']}\")"
      else
        node['src'] = image['thumb_url']
      end
    end

    return node if is_original

    if node.has_attribute?('data-inline')
      is_svg = image['type'] == 'image/svg+xml'
      is_svg ||= image['url'] =~ /\.svg$/

      return node.replace inline_img(image) if is_svg
    end

    figure_width = image['style']&.[]('width')
    case figure_width
    when 'offset'
      figure_class = 'image wrap offset'
    when 'full', 'wrap'
      figure_class = "image #{figure_width}"
    else
      figure_class = 'image'
    end

    figure_class << " #{image['style']&.[]('custom_class')}"

    if node.parent && node.parent.name == 'figure'
      figure = node.parent.clone
      figure.inner_html = node.to_s

    else
      if node.name == 'figure'
        figure = node.clone
        figure['class'] = "#{figure['class']} #{figure_class}"
      else
        figure = create_element('figure', class: figure_class)
        figure.inner_html = node.to_s
      end
    end

    is_full_width = figure_class.end_with?('full')

    unless is_cover_area
      padding_style = "max-height: #{image['height']}px;"

      if image['aspect_ratio']
        padding_style << " padding-bottom: #{100/image['aspect_ratio']}%;"
      elsif image['width'] && image['height']
        padding_style << " padding-bottom: #{100/(image['width'].to_f/image['height'])}%;"
      end

      padding_attributes = { class: 'aspect-ratio', style: padding_style }
      figure << create_element('div', padding_attributes)
    end

    if is_full_width && image['title'].present?
      overlay_title = create_element('div', class: 'container')
      overlay_title << create_element('h3', image['title'])
      figure << overlay_title
    end

    caption = image['caption']
    if caption.present?
      caption_options = {}
      caption_options[:class] = 'inset' if image['style']&.[]('caption') == 'inset'
      figure << create_element('figcaption', caption, caption_options)
    end

    location = image['location']
    if location.present?
      geo_uri = "geo:#{location['coordinates'].join ','}?zoom=#{location['zoom']}&label=#{location['name']}"
      figure << create_element('a', class: 'show-map', href: geo_uri)
    end

    node.replace figure
  end

  def decorate_video node, video
    if edit_mode
      decorated = create_element('video', poster: asset_path('ui/video-play.svg'),
        'data-media-id' => node['data-media-id'],
        style: "background-image: url('#{asset_url(video, 'thumb' => true)}')"
      )
    else
      video_url = relative_protocol(video['url'].presence || video['link'].presence)

      options = node.attribute_nodes.reduce({}) do |memo, n|
        memo[n.node_name] = n.value if n.value.present?
        memo
      end
      value = html5_attribute_value(video['autoplay'], 'autoplay')
      options[:autoplay] = value if value
      %w[controls loop muted].each do |a|
        value = html5_attribute_value(video[a], a)
        options[a.to_sym] = value if value
      end
      value = html5_attribute_value(video['preload'], %w[auto metadata none])
      options[:preload] = value if value
      options[:global] = true if truthy? video['global']
      options[:scope] = true if truthy? video['scope']
      %w[width height].each do |a|
        value = video[a]
        options[a.to_sym] = value if value
      end

      if node.has_attribute? 'data-original'
        options[:type] = video['type'] if video['type'].present?
        options[:src] = video_url

        value = options.delete(:autoplay)
        options[:'data-autoplay'] = value if value

        options.each do |name, value|
          node[name] = value
        end

        if node.parent.node_name == 'figure' && options[:'data-autoplay']
          node.parent['class'] = "#{node.parent['class']}"
        end

        return node
      else
        width = video['style']&.[]('width')
        case width
        when 'offset'
          figure_class = 'video wrap offset'
        when 'full', 'wrap'
          figure_class = "video #{width}"
        else
          figure_class = 'video'
        end

        thumb_url = relative_protocol(video['thumb_url'])

        figure_class << " #{video['style']&.[]('custom_class')}"

        if node.name == 'figure'
          decorated = node.dup
          decorated['class'] = "#{decorated['class']} #{figure_class}"
          decorated['style'] = %{background-image: url("#{thumb_url}")}
        else
          figure_attributes = {class: figure_class, style: %{background-image: url("#{thumb_url}")}}
          decorated = create_element('figure', figure_attributes)
        end

        decorated << create_element('a', { class: 'video-play', href: '#' })

        if options[:width] && options[:height]
          padding_style = "max-height: #{options[:height]}px;"
          padding_style << " padding-bottom: #{100/(options[:width].to_f/options[:height])}%;"
          padding_attributes = { class: 'aspect-ratio', style: padding_style }
          decorated << create_element('div', padding_attributes)
        else
          decorated << create_element('div', { class: 'aspect-ratio' })
        end

        if embed_video? video_url
          decorated['class'] += ' embed'
          decorated << video_iframe_html(video_url, options)

        else
          value = options.delete(:autoplay)
          if value
            options[:'autoplay'] = true
            options[:'data-autoplay'] = value
          end

          if video['playsinline']
            options[:'playsinline'] = true
          end

          options.delete('class')

          video_node = create_element('video', options)
          source_options = {src: video_url}
          source_options[:type] = video['type'] if video['type'].present?
          video_node << create_element('source', source_options)

          decorated << video_node
        end
      end

      caption = video['caption']
      if caption.present?
        options = {}
        options[:class] = 'inset' if video['style']&.[]('caption') == 'inset'

        caption = create_element('figcaption', caption, options)
        #caption.prepend_child create_element('h3', video["title"]) if video["title"]

        decorated << caption
      end

      location = video['location']
      if location.present?
        geo_uri = "geo:#{location['coordinates'].join ','}?zoom=#{location['zoom']}&label=#{location['name']}"
        decorated << create_element('a', class: 'show-map', href: geo_uri)
      end
    end

    node.replace decorated
  end

  def decorate_audio node, audio
    element_id = node["id"] ? "#{node["id"]}-container" : ""

    options = node.attribute_nodes.reduce({}) do |memo, n|
      memo[n.node_name] = n.value
      memo
    end
    options[:type] = audio['type'] if audio['type'].present?
    options[:src] = relative_protocol(audio["url"])

    value = html5_attribute_value(audio['autoplay'], 'autoplay')
    options[:'data-autoplay'] = value if value
    %w[controls loop muted].each do |a|
      value = html5_attribute_value(audio[a], a)
      options[a.to_sym] = value if value
    end
    value = html5_attribute_value(audio['preload'], %w[auto metadata none])
    options[:preload] = value if value
    options[:'data-global'] = true if truthy? audio['global']
    options[:'data-scope'] = true if truthy? audio['scope']

    figure = create_element('figure', :class => 'audio', id: element_id)
    if thumb_url = relative_protocol(audio["thumb_url"])
      figure << create_element('img', class: 'thumbnail', src: thumb_url)
    end

    audio = create_element('audio', options)
    figure << audio

    if audio['caption']
      options = {}
      options[:class] = 'inset' if audio['caption_inset']
      figure << create_element('figcaption', audio['caption'], options)
    end

    node.replace figure
  end

  def html5_attribute_value value, value_set
    value_set = Array(value_set)

    if truthy? value
      value_set.first
    elsif value_set.include? value
      value
    end
  end

  def video_iframe_html url, params={}
    width  = params[:width] || params['width'] || '100%'
    height = params[:height] || params['height'] || '100%'

    autoplay = params[:autoplay] || params['autoplay'] ? 'data-autoplay="true"' : nil

    embed_url_params = {}
    %i[controls loop muted].each do |a|
      embed_url_params[a] = params[a] || params[a.to_s] ? 1 : 0
    end

    case url
    when YOUTUBE_RE
      embed_url_params.merge!(
        autoplay: 1,
        autohide: 1,
        color: 'white',
        enablejsapi: 1,
        hd: 1,
        iv_load_policy: 3,
        modestbranding: 1,
        origin: 'https://issueapp.com',
        rel: 0,
        showinfo: 0,
        wmode: 'transparent'
      )

      # NOTE: loop only works with the playlist param
      embed_url_params[:playlist] = $1 if params[:loop] || params['loop']

      embed_url = "https://www.youtube-nocookie.com/embed/#{$1}"

    when VIMEO_RE
      embed_url_params.merge!(
        byline: 0,
        portrait: 0,
        autoplay: 1
      )
      embed_url = "http://player.vimeo.com/video/#{$1}"

    else
      raise ArgumentError, "Unsupported url: #{url}"
    end

    embed_url << "?#{URI.escape(embed_url_params.to_param)}"

    source = %{data-src="#{embed_url}"}

    %{<div class="iframe-wrapper-top"></div>
      <iframe #{source} #{autoplay} frameborder="0" width="#{width}" height="#{height}" webkitallowfullscreen mozallowfullscreen allowfullscreen allow="autoplay"></iframe>
      <div class="iframe-wrapper-bottom"></div>}
  end

  def embed_video? url
    case url.to_s
    when YOUTUBE_RE, VIMEO_RE
      true
    else
      false
    end
  end

  def create_element *args, &block
    doc = Nokogiri::HTML('')
    doc.encoding = 'utf-8'

    name, *args = args

    elm = Nokogiri::XML::Element.new(name, doc, &block)
    args.each do |arg|
      case arg
      when Hash
        arg.each { |k,v|
          key = k.to_s
          if key =~ Nokogiri::XML::Document::NCNAME_RE
            ns_name = key.split(":", 2)[1]
            elm.add_namespace_definition ns_name, v
          else
            elm[k.to_s] = v.to_s
          end
        }
      else
        elm.inner_html = arg.to_s
      end
    end
    if ns = elm.namespace_definitions.find { |n| n.prefix.nil? or n.prefix == '' }
      elm.namespace = ns
    end
    elm
  end

  def image_get_size image
    width = image['width'] || image['file_width']
    height = image['height'] || image['file_height']

    if width && height
      aspect_ratio = image['aspect_ratio'] || image['file_aspect_ratio'] || width.to_f/height
      return [width, height, aspect_ratio.to_f]
    end

    unless issue
      if defined? RSpec
        log_method.call('Issue not found.')
        return
      else
        raise 'Issue not found'
      end
    end

    if local_image_path = image['url'][/assets.+$/]
      file = File.join(issue.path, local_image_path)
      raise "local image not found: #{file}" unless File.exist? file
    end

    # watchout for potential problem
    # http://www.mikeperham.com/2015/05/08/timeout-rubys-most-dangerous-api/
    # replace with https://github.com/david-mccullars/safe_timeout
    Timeout::timeout(0.2) do
      width, height = FastImage.size(file)

      # FastImage is unable to detect width and height for svg
      # https://github.com/sdsykes/fastimage/issues/49
      return unless width && height

      aspect_ratio = width.to_f / height

      [width, height, aspect_ratio]
    end
  end

  # Turn a SVG string into a Nokogiri node
  def inline_img media
    if media['id']
      file = page.images.find(media['id']).file
      source = file.data
    else
      file = File.join(issue.path, media['url'].gsub('../', ''))
      raise "SVG not found: #{file}" unless File.exist?(file) && file =~ /\.svg$/
      source = File.read(file)
    end

    # try to clean up bad SVG, so it's HTML friendly
    fixed_svg = Nokogiri::HTML.fragment(source).to_html

    # proceed with XML parsing
    if !fixed_svg.blank?
      Nokogiri::XML(fixed_svg).at('svg')
    else
      source
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

  def relative_protocol(url)
    if url
      url.sub(/^https?:/, '')
    end
  end

  def truthy? value
    case value.to_s.downcase
    when 'true', 'yes', '1'
      true
    else
      false
    end
  end
end
