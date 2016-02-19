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

  YOUTUBE_RE = %r{youtube\.com/watch\?v=(.+)}
  VIMEO_RE = %r{vimeo\.com/([^/]+)}

  # FIXME unstable API
  def custom_html?
    page.custom_html.present?
  end
  # end FIXME unstable API

  attr_reader :page

  attr_accessor :context, :edit_mode, :offline
  attr_writer :json

  def initialize page, options={}
    raise ArgumentError, 'Page not present' unless page

    @page = page

    @context = options[:context] || options['context']
    @edit_mode = options[:edit_mode] || options['edit_mode']
    @offline = options[:offline]
  end

  def class; page.class; end
  def method_missing(name, *args, &block); page.send(name, *args, &block); end
  def respond_to?(name, include_private=false); page.send('respond_to?', name, include_private); end
  def respond_to_missing?(name, include_private=false); page.send('respond_to_missing?', name, include_private); end

  def page_title
    case
    when page.title   then page.title
    when page.toc?    then "Table of Content - #{page.issue.title}" 
    when page.parent  then "#{page.parent.title} - #{page.handle}" 
    end
  end

  def dom_id
    "s#{path.parameterize}"
  end

  def content?
    ! empty_content?(page.content) || ! empty_content?(page.custom_html)
  end

  def scrollable?
    content? && page.style.type == 'one-column' && cover?
  end

  def content_dom_id
    page.path.parameterize
  end

  def layout_class options={}
    has_header  = !empty_content?(title) || !empty_content?(summary)
    has_product = page.product_set?
    has_cover   = page.cover_url && page.style.image_style != "none"
    editing     = options[:editing]

    classes = ["page", page.style.custom_class]

    # call js page.setActive() to set current class
    #classes << 'current' if options[:current]

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
    page.style.image_style != "background" ||
      page.style.custom_class.to_s.match('inset')
  end

  def author
    return page.author if page.author

    name = page.author_name
    icon = page.author_icon if page.respond_to? 'author_icon'

    if name
      Struct::Author.new(name, icon)
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
    return unless (cover = page.cover)

    content = %{<figure class="cover-area"></figure>}

    html = decorate_content(content) do |doc|
      doc.search('.cover-area').each do |node|

        if is_video = cover.type&.include?('video')
          decorate_video(node, cover)

        elsif is_image = cover.type&.include?('image')
          decorate_image(node, cover)
        end

      end
    end


    html = html.html_safe if html.respond_to? :html_safe
    html
  end

  def products_class_name
    class_name = 'product-set'
    count = page.products.count == 9 ? 9 : [(page.products.count/2.0).ceil*2, 6].min

    class_name << " set-#{count}"
  end

  def product_set_html
    container_class = self.products_class_name
    container_class << ' cover-area' unless page.cover

    fragment = create_element('ul', :class => container_class) do |ul|
      page.products.each_with_index do |product, index|
        ul << create_element('li') do |li|
          attributes = product_hotspot_attributes(product)

          li << create_element('a', attributes) do |a|
            a << create_element('img', :src => attributes[:'data-image'])
            a << create_element('span', product.title, :class => 'label') if product.style && product.style['show_label']
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
    @json ||= begin
      hash = page.to_hash

      # adjust media, link, cover path for subpage
      if page.parent
        if cover = hash['cover']
          cover['url'] = "../#{cover['url']}" if cover['url']
          cover['thumb_url'] = "../#{cover['thumb_url']}" if cover['thumb_url']
        end

        %w[audios images videos].each do |element|
          if elements = hash[element]
            elements.each do |media|
              media['url'] = "../#{media['url']}" if media['url']
              media['thumb_url'] = "../#{media['thumb_url']}" if media['thumb_url']
            end
          end
        end

        %w[links products].each do |element|
          if elements = hash[element]
            elements.each do |link|
              link['image_url'] = "../#{link['image_url']}" if link['image_url']
            end
          end
        end
      end

      hash
    end
  end


  private

  # Options
  #     json: Custom json for testing
  #     html_safe: escape html flag
  #     footer: custom footer markup
  def render_content content, options = {}
    options[:html_safe] ||= true
    json = options[:json] || self.json

    html = Mustache.render(content, json)

    html = decorate_content(html, options) do |doc|
      doc.search('[data-media-id]').each do |node|
        asset, media = page.find_element(node['data-media-id'])

        unless media
          raise "Media not found: #{node['data-media-id']}"
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
          log_method.call("Fail to decorate unknown element: #{asset}")
        end
      end
    end

    html = html.html_safe if options[:html_safe] && html.respond_to?(:html_safe)
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

  def product_hotspot_attributes product
    {
      :href => affiliate_url(product['link']),
      :class => 'product hotspot',
      :title => product.title,
      :'data-image' => asset_url(product, 'image' => true),
      #:'data-track' => 'hotspot:click',
      #:'data-action' => product[:action],
      #:'data-url' => product['link'],
      #:'data-price' => product[:price],
      #:'data-currency' =>  product[:currency],
      #:'data-description' => product[:description],
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

  def decorate_image node, image
    if node.name == 'img'
      node['src'] = asset_url(image)
    end

    # Edit mode to maintain single image element in editor
    return node if edit_mode && !custom_html?

    is_original = node.has_attribute?('data-original')
    is_cover_area = node.matches?('.cover-area')
    is_background_image = node.has_attribute?('data-background-image')

    if is_background_image || is_cover_area
      node['style'] = "background-size: cover; background-image:url(#{asset_url image})"
    end

    return node if is_original

    if node.has_attribute?('data-inline')
      img_path = (dragonfly_file_name=image['file_name']) || (local_issue_path=image['path'])
      return node.replace inline_img(image) if img_path =~ /\.svg$/
    end

    if node.parent && node.parent.name == 'figure'
      figure = node.parent.clone
      figure.inner_html = node.to_s

    else
      width = image.style&.[]('width')
      case width
      when 'offset'
        figure_class = 'image wrap offset'
      when 'full', 'wrap'
        figure_class = "image #{width}"
      else
        figure_class = 'image'
      end

      if node.name == 'figure'
        figure = node.clone
        figure['class'] = "#{figure['class']} #{figure_class}"
      else
        figure = create_element('figure', class: figure_class)
        figure.inner_html = node.to_s
      end
    end

    width, height, aspect_ratio = image_get_size(image)
    padding = 100/(aspect_ratio || 1.5)
    is_full_width = figure_class.end_with?('full')

    unless is_cover_area
      padding_attributes = {class: 'aspect-ratio', style: "padding-bottom: #{padding}%; max-height: #{height}px"}
      figure << create_element('div', padding_attributes)
    end

    if is_full_width && image.title.present?
      overlay_title = create_element('div', class: 'container')
      overlay_title << create_element('h3', image.title)
      figure << overlay_title
    end

    caption = image['caption']
    if caption.present?
      caption_options = {}
      caption_options[:class] = 'inset' if image.style&.[]('caption') == 'inset'
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
      video_url = video['link'].presence || asset_url(video)

      options = node.attribute_nodes.reduce({}) do |memo, n|
        memo[n.node_name] = n.value if n.value.present?
        memo
      end
      options[:type] = video['type'] if video['type'].present?
      options[:src] = video_url
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
        value = options.delete(:autoplay)
        options[:'data-autoplay'] = value if value
        options.each do |name, value|
          node[name] = value
        end

        if node.parent.node_name == 'figure' && options[:'data-autoplay']
          node.parent['class'] = "#{node.parent['class']} play"
        end

        return node
      else
        width = video.style&.[]('width')
        case width
        when 'offset'
          figure_class = 'video wrap offset'
        when 'full', 'wrap'
          figure_class = "video #{width}"
        else
          figure_class = 'video'
        end
        figure_class += ' play' if options[:autoplay]

        thumb_url = asset_url(video, 'thumb' => true)

        if node.name == 'figure'
          decorated = node.dup
          decorated['class'] = "#{decorated['class']} #{figure_class}"
          decorated['style'] = "background-image: url('#{thumb_url}')"
        else
          figure_attributes = {class: figure_class, style: "background-image: url('#{thumb_url}')"}
          decorated = create_element('figure', figure_attributes)
        end

        if embed_video? video_url
          decorated['class'] += ' embed'
          decorated << video_iframe_html(video_url, options)

        else
          value = options.delete(:autoplay)
          options[:'data-autoplay'] = value if value
          options.delete('class')
          decorated << create_element('video', options)
        end
      end

      caption = video['caption']
      if caption.present?
        options = {}
        options[:class] = 'inset' if video.style&.[]('caption') == 'inset'

        caption = create_element('figcaption', caption, options)
        #caption.prepend_child create_element('h3', video["title"]) if video["title"]

        decorated << caption
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
    options[:src] = asset_url(audio)
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
    if thumb_url = asset_url(audio, 'thumb' => true)
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
      <iframe #{source} #{autoplay} frameborder="0" width="#{width}" height="#{height}" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
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
    doc.create_element(*args, &block)
  end

  def image_get_size image
    if image.width && image.height
      aspect_ratio = image.aspect_ratio || image.width.to_f/image.height
      return [image.width, image.height, aspect_ratio.to_f]
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
  def inline_img(media)
    if media.file
      source = media.file.data
    else
      file = File.join(issue.path, media.url)
      raise "SVG file can't be find" unless File.exist?(file) && file =~ /\.svg$/
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

  def truthy? value
    case value.to_s.downcase
    when 'true', 'yes', '1'
      true
    else
      false
    end
  end
end
