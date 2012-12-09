#
# Methods placed in this module can be used inside of any view.
# View helpers allow you to encapsalate complex logic and keep your
# views pristine.
#
module ViewHelpers
  require 'hashie/mash'
  
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
          
    render 'product', locals: { product: p, dimension: p.dimension}.merge(options)
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
  
  # Add your own helpers below...
  
end