require 'nokogiri'
require 'uri'

module LocalIssue::PageHelpers

  # <%= render_page page %>
  def render_page(page)
    doc = Nokogiri::HTML.fragment(page.content)

    # Swap data-media-id
    # videos:1
    # images:1
    doc.search("[data-media-id]").each do |node|
      asset, index = node["data-media-id"].split(":")
      index = index.to_i - 1

      if page[asset] && page[asset][index]
        media = page[asset][index]
        node["src"] = media["url"]

        if asset == "images"
          img_node = image_node(node, media)

          node.replace(img_node) if img_node != node
        end

        if asset == "videos"
          node.replace video_node(node, media)
        end

        if asset == "audios"
          node.replace audio_node(node, media)
        end
      end
    end

    doc.to_s
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
  def image_node(node, image)
    options = {}

    if image["caption"]
      figure = create_element('figure')
      figure.inner_html = node.to_s

      options[:class] = "inset" if image["caption_inset"]
      figure << create_element('figcaption', image["caption"], options)

      figure
    else
      node
    end
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
  #    loop:     true | false
  def video_node(node, video)
    class_name = nil

    video["autoplay"] ||= true
    video["controls"] ||= false

    # Setup video params
    options = {
      type:     video["type"],
      src:      video["url"],
      autoplay: video["autoplay"] ? true : nil,
      controls: video["controls"] ? true : nil,
      height:   video["height"],
      width:    video["width"],
      loop:     video["loop"],
      muted:    video["muted"],
    }.delete_if { |k, v| v.nil? }

    figure = create_element('figure', :class => "video")
    figure << create_element("div",
      class: "thumbnail",
      style: "background-image: url('#{video["thumb_url"]}')"
    )

    # Detect embed videos
    if embed_video? video["url"]
      figure.inner_html += video_iframe(video["url"], options.merge(lazy: true))

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
    class_name = nil

    # Setup audio params
    options = {
      type:     media["type"],
      src:      media["url"],
      autoplay: media["autoplay"] ? true : nil,
      controls: media["controls"] ? true : nil,
      loop:     media["loop"],
      muted:    media["muted"]
    }.delete_if { |k, v| v.nil? }

    figure = create_element('figure', :class => "audio")
    figure << create_element("img", class: "thumbnail", src: media["thumb_url"])

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
  def video_iframe(url, options = {})

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

  def embed_video?(url)
    !! (url.match(/youtube\.com\/watch\?v=(.+)/) || url.match(/vimeo\.com\/([^\/]+)/))
  end

  def create_element(*args)
    Nokogiri::HTML("").create_element(*args)
  end
end
