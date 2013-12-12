#
# Methods placed in this module can be used inside of any view.
# View helpers allow you to encapsalate complex logic and keep your
# views pristine.
#
module ViewHelpers
  require 'hashie/mash'
  require 'forgery'

  def issue_contents(include_head = false)
    # <li><a href="/issue">Cover</a></li>
    # <li><a href="/issue/contents">Contents</a></li>
    # <li><a href="/issue/two-col">Two column</a></li>
    # <li><a href="/issue/one-col">One Column</a></li>
    # <li><a href="/issue/fullscreen">Fullscreen</a></li>
    # <li><a href="/issue/one-third">Third</a></li>
    # <li><a href="/issue/youtube">Youtube</a></li>
    # <li><a href="/issue/vimeo">Vimeo</a></li>
    # <li><a href="/issue/products-split">Products 1</a></li>
    # <li><a href="/issue/products-collage">Collage</a></li>
    items = {
      "Content :: Two Column :: By Auther" => "/issue/two-col",
      "Content :: One Column :: By Jessica Cheung" => "/issue/one-col",
      "Content :: Fullscreen :: By Auther" => "/issue/fullscreen",
      "Content :: Third :: By Auther" => "/issue/one-third",
      "Media :: Youtube :: By Auther" => "/issue/youtube",
      "Media :: Vimeo :: By Auther" => "/issue/vimeo",
      "Shopping :: Product Set In Split :: By Auther" => "/issue/products-split",
      "Shopping :: Collage :: By Auther" => "/issue/products-collage"
    }

    items = { "Cover"=> "/issue", "Contents"=> "/issue/contents" }.merge(items) if include_head

    items.map do |text, link|
      category, title, author = text.split(/::/).map(&:strip)
      title, category = category, title unless title

      Hashie::Mash.new(
        title: title,
        category: category,
        author_name: author,
        url: link
      )
    end
  end

  def embed_video url
    case url

    when /player.vimeo.com\/video\/(.+)/, /http:\/\/vimeo.com\/(.+)/
      vimeo_id = $1.strip
      options = { autoplay: 1, byline: 0, portrait: 0 }

      embed_url = "//player.vimeo.com/video/#{vimeo_id}?#{options.to_param}"

    when /youtube.com\/watch\?v=(.+)/, /youtu.be\/(.+)/
      youtube_id = $1.strip
      options = { controls: 0, wmode: 'transparent', autoplay: 1,
        iv_load_policy: 3, autohide: 1, hd: 1, color: 'white',
        rel: 0, showinfo: 0, enablejsapi: 1,
        origin: "http://issueapp.com"
      }

      embed_url = "//www.youtube.com/embed/#{youtube_id}?#{options.to_param}"

    else
      embed_url = url
    end

    %_<iframe src="#{embed_url}" frameborder="0" height="100%" width="100%" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>_.html_safe
  end


  def lorem_ipsum(sentences = 3)
    Forgery(:lorem_ipsum).sentences(sentences)
  end

  def cover_image(url)
<<-eos
  <div class="image" style="background-image: url(#{url}); background-size: cover; background-position: center;">
  </div>
eos
  end

  def px2em(pixel)
    pixel.to_f / 13
  end

  def size(width, height, base = 390)
    scale = base.to_f/width

    orientation = case
    when width > height then 'landscape'
    when width < height then 'portrait'
    else
      'square'
    end

    Hashie::Mash.new(
      scale: scale.round(2),
      width: px2em( scale < 1 ? base : width  ).round(2),
      height: px2em( scale < 1 ? height * scale : height  ).round(2),
      orientation: orientation
    )
  end

  def sample_products(options = {})
    i = 0
    YAML.load_file('products.yml').map do |p|
      p["id"] = i += 1
      Hashie::Mash.new(p)
    end

  end


  def render_product(product, options = {})
    if product.is_a? Hash
      p = Hashie::Mash.new(product)
    else
      p = product
    end
    p.dimension = size(p.image_width, p.image_height) if p.image_width && !p.dimension

    render 'templates/product', locals: { product: p, dimension: p.dimension}.merge(options)
  end

  # Calculate the years for a copyright
  def copyright_years(start_year)
    end_year = Date.today.year
    if start_year == end_year
      "\#{start_year}"
    else
      "\#{start_year}&#8211;\#{end_year}"
    end
  end

  # Handy for hiding a block of unfinished code
  def hidden(&block)
    #no-op
  end

  def image_tag(src, *args)
    src = "/images/#{src}"
    super
  end

  def image_path(src)
    src = "/images/#{src}"
  end

  def image_holder(size)
    width, height = size.split("x")

    image_tag "http://placehold.it/#{width}/#{height}"
  end

  # Add your own helpers below...

end
