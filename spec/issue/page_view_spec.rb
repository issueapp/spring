require 'support/local_issue'
require 'issue/page_view'
require 'local_issue/page'

RSpec.describe Issue::PageView do
  let(:music) {local_issue 'music'}
  let(:page) { {} }

  subject(:view) { page_view page }


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

    it 'renders product image within view context' do
      product['image_url'] = 'assets/background.jpg'
      view.context = double

      expect(view.context).to receive('asset_path').with('assets/background.jpg')
      product_set_html
    end

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

    # TODO replace issues fixtures
    it 'renders cover caption' do
      page = LocalIssue::Page.build('2-head-or-heart/1', issue: music)
      view = Issue::PageView.new(page)

      expect(view.cover_html).to include(
        %{<figcaption class="inset">MINKPINK Funday Sunday Dress.</figcaption>}
      )
    end

    describe 'youtube iframe' do
      before do
        page['videos'] = [ Hashie::Mash.new(
          'type' => 'video', 'cover' => true, 'link' => 'https://www.youtube.com/watch?v=cats', 'thumb_url' => 'assets/background.jpg', 'autoplay' => true
        ) ]
      end

      it 'renders video iframe' do
        cover_html.should have_tag('figure.cover-area.video') do
          with_tag 'iframe', with: {frameborder: '0', height: '100%', width: '100%'}
        end
      end

      it 'renders thumb background' do
        cover_html.should have_tag('figure[style="background-image: url(assets/background.jpg)"]')
      end

      it 'renders autoplay' do
        cover_html.should have_tag('figure.play')
      end

      it 'renders lazy load' do
        cover_html.should have_tag('iframe[data-src="http://youtube.com/embed/cats?autoplay=1&controls=0&loop=0&playlist=cats&autohide=1&color=white&enablejsapi=1&hd=1&iv_load_policy=3&origin=http%3A%2F%2Fissueapp.com&rel=0&showinfo=0&wmode=transparent"]')
      end

      it 'renders fullscreen mode' do
        cover_html.should have_tag('iframe[webkitallowfullscreen][mozallowfullscreen][allowfullscreen]')
      end
    end

    describe 'vimeo iframe' do
      before do
        page['videos'] = [ Hashie::Mash.new(
          'type' => 'video', 'cover' => true, 'link' => 'http://vimeo.com/98524032', 'thumb_url' => 'http://i.vimeocdn.com/video/479274132_640.jpg', 'autoplay' => true
        ) ]
      end

      it 'renders video iframe' do
        cover_html.should have_tag('figure.cover-area.video') do
          with_tag 'iframe', with: {frameborder: '0', height: '100%', width: '100%'}
        end
      end

      it 'renders thumb background' do
        cover_html.should have_tag('figure[style="background-image: url(http://i.vimeocdn.com/video/479274132_640.jpg)"]')
      end

      it 'renders autoplay' do
        cover_html.should have_tag('figure.play')
      end

      it 'renders lazy load' do
        cover_html.should have_tag('iframe[data-src="http://player.vimeo.com/video/98524032?autoplay=1&controls=0&loop=0&byline=0&portrait=0"]')
      end

      it 'renders fullscreen mode' do
        cover_html.should have_tag('iframe[webkitallowfullscreen][mozallowfullscreen][allowfullscreen]')
      end
    end
  end

  describe 'html rendering' do
    subject(:html) { view.content_html }

    it 'compiles mustache' do
      page['title'] = 'Gyft'
      page['content'] = '<h1>{{title}}</h1>'

      html.should have_tag("h1", "Gyft")
    end

    describe 'Image decoration' do
      let(:image) { {} }

      before do
        page['images'] = [image]
        page['content'] = '<img data-media-id="images:1">'
      end

      it 'renders figure around image' do
        html.should have_tag('figure.image') do
          with_tag 'img'
        end
      end

      it 'renders responsive image hack' do
        image['width'] = 200
        image['height'] = 200

        html.should have_tag('figure[style="max-height: 200px; max-width: 200px"]')
      end

      it 'renders filler div to maintain aspect-ratio' do
        html.should have_tag('div.aspect-ratio[style*="padding-bottom: 66.66666666666667%"]')
      end

      it "detects image dimension if missing (height, width, aspect_ratio)" do
        image['url'] = 'assets/background.jpg'
        view.page.issue = double
        allow(view.page.issue).to receive('path') { Pathname.new('spec/fixtures/issue') }

        html.should have_tag('figure.image[style*="max-height: 640px; max-width: 640px"]') do
          have_tag('img', with: { src: "assets/background.jpg" })
        end
      end

      it 'renders captions in figcaption tag' do
        image['caption'] = 'image caption'
        html.should have_tag('figcaption', 'image caption')
      end

      it 'renders captions with inset class' do
        image['caption'] = 'image caption'
        image['caption_inset'] = true

        html.should have_tag('figcaption.inset')
      end
    end

    describe 'Video decoration' do
      it 'renders video block around figure'
      it 'renders youtube video within iframe'
      it 'renders vimeo video within iframe'
      it 'may have custom thumbnail'
      it 'adds playback attribute: :autoplay, :muted, :controls'
      it 'adds caption'
    end

    describe 'Audio decoration' do
      it 'render video block around figure'
      it 'adds playback attribute: :autoplay, :muted, :controls'
      it 'might have custom thumbnail'
    end

    describe 'Link decoration'
    describe 'Product decoration'
  end

  describe 'content html' do
    it 'compiles mustache' # expect mustache render is called
    it 'decorates data-media-id attributes' # expect decorate media is called
  end

  describe 'custom html' do
    it 'detects custom html' do
      page['custom_html'] = 'I am custom'
      view.should be_custom_html
    end

    it 'compiles mustache' # expect mustache render is called
    it 'decorates data-media-id attributes' # expect decorate media is called
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
