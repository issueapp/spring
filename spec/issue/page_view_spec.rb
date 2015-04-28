require 'support/local_issue'
require 'issue/page_view'
require 'local_issue/page'

RSpec.describe Issue::PageView do
  let(:page) { {} }
  let(:view) { page_view page }

  let(:music) {local_issue 'music'}
  let(:rebelskhed) {local_issue 'rebelskhed'}
  let(:spread) {local_issue 'spread'}
  let(:spring) {local_issue 'spring'}
  let(:top3) {local_issue 'top3'}

  it 'delegates missing methods to page' do
    page = double
    view = Issue::PageView.new(page)

    expect(page).to receive(:id)
    view.id
  end

  describe 'Rendering Helpers' do
    before { page['handle'] = 'story-three' }
    subject { view }

    it { view.dom_id.should eq 'sstory-three' }

    it { should respond_to 'show_author?' }
    it { should respond_to 'author' }

    it { should respond_to 'column_break_count' }

    it { should respond_to 'custom_html?' }

    it { should respond_to('layout_class') }
    it { should respond_to('cover_html') }
    it { should respond_to('custom_html') }
    it { should respond_to('content_html') }
    it { should respond_to('product_set_html') }
  end

  describe 'author' do
    before do
      page['author_name'] = 'Zyralyn Bacani'
      page['author_icon'] = 'http://cl.ly/StPu/Image%202013.12.11%204%3A54%3A01%20pm.png'
    end

    it 'includes author name and icon' do
      view.author.name.should eq 'Zyralyn Bacani'
      view.author.icon.should eq 'http://cl.ly/StPu/Image%202013.12.11%204%3A54%3A01%20pm.png'
    end

    it 'shows author when there is an author' do
      view.show_author?.should be_truthy
    end

    it 'shows/hides author based on switch' do
      page['layout'] = {'hide_author' => true}
      view.show_author?.should be_falsy

      view.page.layout.hide_author = false
      view.show_author?.should be_truthy
    end

    it 'hides author on child pages' do
      page['parent_path'] = 'parent'
      view.show_author?.should be_falsy
    end
  end

  describe 'multicolumn' do
    it 'has 0 column break by default'

    it 'has 1 column break for cover' do
      page['cover_url'] = 'assets/background.jpg'
      view.column_break_count.should eq 1
    end

    it 'has 1 column break for product set' do
      page['products'] = [{}]
      view.column_break_count.should eq 1
    end

    it 'has 2 column breaks when three column cover takes up 2 column' do
      page['layout'] = {type: 'three-column'}
      page['cover_url'] = 'assets/background.jpg'

      view.column_break_count.should eq 2
    end
  end

  describe 'product set html' do
    let(:product) { {} }

    subject(:product_set_html) { view.product_set_html }

    before do
      page['products'] = [product]
    end

    it { view.product_set?.should be_truthy }

    it 'renders product set html' do
      product_set_html.should have_tag('ul.product-set')
    end

    it 'renders product set in multiples of twos' do
      product_set_html.should have_tag('ul.set-2')
    end

    it 'renders product as hotspots' do
      product_set_html.should have_tag('li a.product.hotspot', count: 1)
    end

    it 'renders product affiliate link' do
      issue = double
      allow(issue).to receive('path') { Pathname.new('spec/fixtures/issue') }
      product['link'] = 'http://shop2.com/p/1096-gucci-g876'

      view.page.issue = issue

      product_set_html.should have_tag('a[href="http://affiliate.com/1096-gucci-g876"]')
    end

    it 'renders product original link' do
      product['link'] = 'http://shop2.com/p/1096-gucci-g876'
      product_set_html.should have_tag('a[data-url="http://shop2.com/p/1096-gucci-g876"]')
    end

    it 'renders product title' do
      product['title'] = 'some product'
      product_set_html.should have_tag('a[title="some product"]')
    end

    it 'renders product description' do
      product['description'] = 'greatest product ever'
      product_set_html.should have_tag('a[data-description="greatest product ever"]')
    end

    it 'renders product currency' do
      product['currency'] = 'AUD'
      product_set_html.should have_tag('a[data-currency="AUD"]')
    end

    it 'renders product price' do
      product['price'] = '6996'
      product_set_html.should have_tag('a[data-price="6996"]')
    end

    it 'renders product image' do
      product['image_url'] = 'assets/background.jpg'
      product_set_html.should have_tag('img[src="assets/background.jpg"]')
    end

    it 'renders product image via view context'

    it 'renders product hotspot marker' do
      product_set_html.should have_tag('span.tag', '1')
    end

    it 'renders hotspot click track' do
      product_set_html.should have_tag('a[data-track="hotspot:click"]')
    end
  end

  describe 'cover html' do
    subject(:cover_html) { view.cover_html }

    it 'renders image background' do
      page['images'] = [ Hashie::Mash.new(
        'type' => 'image', 'cover' => true, 'url' => 'assets/background.jpg'
      ) ]

      cover_html.should have_tag('figure.cover-area.image[style="background-image: url(assets/background.jpg)"]')
    end

    it "supports HTML5 video tag (mp4)" do
      page['videos'] = [ Hashie::Mash.new(
        'type' => 'video', 'cover' => true, 'url' => 'assets/video.mp4', 'thumb_url' => 'assets/background.jpg'
      ) ]

      cover_html.should have_tag('figure.cover-area.video[style="background-image: url(assets/background.jpg)"]') do
        with_tag 'video[src="assets/video.mp4"]'
      end
    end

    it 'renders video iframe for vimeo' do
      page['videos'] = [ Hashie::Mash.new(
        'type' => 'video', 'cover' => true, 'link' => 'https://www.youtube.com/watch?v=cats', 'thumb_url' => 'assets/background.jpg', 'autoplay' => true
      ) ]

      cover_html.should have_tag('figure.cover-area.video[style="background-image: url(assets/background.jpg)"]') do
        with_tag 'iframe', with: {frameborder: '0', height: '100%', width: '100%'}
      end

      # autoplay
      cover_html.should have_tag('figure.play')

      # lazy load
      cover_html.should have_tag('iframe[data-src="http://youtube.com/embed/cats?autoplay=1&controls=0&loop=0&playlist=cats&autohide=1&color=white&enablejsapi=1&hd=1&iv_load_policy=3&origin=http%3A%2F%2Fissueapp.com&rel=0&showinfo=0&wmode=transparent"]')

      # fullscreen
      cover_html.should have_tag('iframe[webkitallowfullscreen][mozallowfullscreen][allowfullscreen]')
    end

    it 'renders video iframe for youtube' do
    end

    it 'renders cover caption' do
      page = LocalIssue::Page.build('2-head-or-heart/1', issue: music)
      view = Issue::PageView.new(page)

      expect(view.cover_html).to include(
        %{<figcaption class="inset">MINKPINK Funday Sunday Dress.</figcaption>}
      )
    end
  end

  describe 'page elements' do
    describe 'video' do
      it 'renders video block around figure'
      it 'renders youtube video within iframe'
      it 'renders vimeo video within iframe'
      it 'may have custom thumbnail'
      it 'adds playback attribute: :autoplay, :muted, :controls'
      it 'adds caption'
    end

    describe 'image' do
      let(:image) { {
        'url' => 'assets/background.jpg',
        'capition_inset' => false,
        'caption' => "image caption",
        'height' => 200,
        "width" => 200,
        'aspect_ratio' => 1.0
      } }
      
      let(:view) { page_view content: '<img data-media-id="images:1">', images: [image] }
      
      it 'renders figure block around image' do
        view.content_html.should have_tag('figure.image') do
          with_tag 'img'
        end
      end
      
      it 'renders captions in figcaption tag' do
        view.content_html.should have_tag('figcaption', 'image caption')
      end
      
      it 'adds inset class' do
        image["caption_inset"] = true
        
        view.content_html.should have_tag('figcaption.inset')
      end
      
      it "maintains aspect-ratio using a filler div" do
        view.content_html.should have_tag('div.aspect-ratio[style*="padding-bottom: 100.0%"]')

      end
      
      it "detects image dimension if missing (height, width, aspect_ratio)" do
        image.delete("height")
        image.delete("width")
        image.delete("aspect_ratio")
        
        view.page.issue = double
        allow(view.page.issue).to receive('path') { Pathname.new('spec/fixtures/issue') }
        
        view.content_html.should have_tag('figure.image[style*="max-height: 640px; max-width: 640px"]') do
          
          have_tag('img', with: { src: "assets/background.jpg" })
          
        end
      end
    end

    describe 'link'

    describe 'audio' do
      it 'render video block around figure'
      it 'adds playback attribute: :autoplay, :muted, :controls'
      it 'might have custom thumbnail'
    end
  end

  describe 'content html' do
    it 'compiles mustache'

    it 'decorates data-media-id attributes' do
      page = LocalIssue::Page.build('story-one', issue: spring)
      view = Issue::PageView.new(page)

      expect(view.content_html).to include(
        %{<figure class="image" style="max-height: 777px; max-width: 590px"><img data-media-id="images:10" src="assets/nibble/crackers_2.jpg"><div class="aspect-ratio" style="padding-bottom: 131.6949152542373%; max-height: 777px"></div></figure>}
      )
    end
  end

  describe 'custom html' do
    let(:image) { {
      'url' => 'assets/background.jpg',
      'capition_inset' => false,
      'caption' => "image caption",
      'height' => 200,
      "width" => 200,
      'aspect_ratio' => 1.0
    } }
    
    let(:view) { 
      page_view title: "Gyft", custom_html: '<h1>{{title}}</h1><img data-media-id="images:1">', images: [image] 
    }
    
    it 'detects custom html' do
      view.should be_custom_html
    end

    it 'compiles mustache' do
      view.custom_html.should have_tag("h1", "Gyft")
    end

    it 'decorates data-media-id attributes' do
      view.custom_html.should include('<figure class="image" style="max-height: 200px; max-width: 200px">')
      view.custom_html.should include('class="aspect-ratio" style="padding-bottom: 100.0%;')
    end
  end

  describe 'layout' do
    it 'defaults layout type to two-column'
    it 'outputs custom layout class'
    it 'outputs page layout class'
    it 'returns layout object'
  end

  def page_view hash
    Issue::PageView.new(LocalIssue::Page.new(hash))
  end
end
