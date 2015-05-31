require 'issue/page_view'
require 'local_issue/page'

RSpec.describe Issue::PageView do
  let(:page) { {} }

  subject :view do
    Issue::PageView.new LocalIssue::Page.new(page)
  end

  it 'delegates missing methods to page' do
    page = double
    view = Issue::PageView.new(page)

    expect(page).to receive(:id)
    view.id
  end

  describe 'Rendering Helpers' do
    before { page['path'] = 'story-three' }

    subject { view }

    it { view.dom_id.should eq 'sstory-three' }

    it { should respond_to? 'show_author?' }
    it { should respond_to? 'author' }

    it { should respond_to? 'column_break_count' }

    it { should respond_to? 'custom_html?' }

    it { should respond_to? 'layout_class' }
    it { should respond_to? 'cover_html' }
    it { should respond_to? 'custom_html' }
    it { should respond_to? 'content_html' }
    it { should respond_to? 'product_set_html' }
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
    let(:image) { {'type' => 'image', 'url' => 'assets/background.jpg'} }
    let(:video) { {'type' => 'video', 'url' => 'assets/video.mp4', 'thumb_url' => 'assets/background.jpg'} }

    subject(:cover_html) { view.cover_html }

    before do
      page['images'] = [image]
      page['videos'] = [video]
    end

    it 'renders cover area' do
      image['cover'] = true
      cover_html.should have_tag('figure.cover-area')
    end

    it 'renders image as background' do
      image['cover'] = true
      cover_html.should have_tag('figure.image[style="background-image: url(\'assets/background.jpg\')"]')
    end

    it 'renders HTML5 video tag (mp4)' do
      video['cover'] = true

      cover_html.should have_tag('figure.video') do
        with_tag 'video[src="assets/video.mp4"]'
      end
    end

    it 'renders video thumb as background' do
      video['cover'] = true
      cover_html.should have_tag('figure[style="background-image: url(\'assets/background.jpg\')"]')
    end

    it 'renders cover caption' do
      image['cover'] = true
      image['caption'] = 'this is a cover'
      cover_html.should have_tag('figcaption', 'this is a cover')
    end

    it 'renders cover inset caption' do
      image['cover'] = true
      image['caption'] = 'this is a cover'
      image['caption_inset'] = true
      cover_html.should have_tag('figcaption.inset')
    end

    describe 'youtube iframe' do
      before do
        video['cover'] = true
        video['link'] = 'https://www.youtube.com/watch?v=cats'
      end

      it 'renders video iframe' do
        cover_html.should have_tag('figure.cover-area.video') do
          with_tag 'iframe', with: {frameborder: '0', height: '100%', width: '100%'}
        end
      end

      it 'renders iframe width, height at 100% when not given' do
        cover_html.should have_tag('iframe[width="100%"][height="100%"]')
      end

      it 'renders thumb background' do
        video['thumb_url'] = 'assets/background.jpg'
        cover_html.should have_tag('figure[style="background-image: url(\'assets/background.jpg\')"]')
      end

      it 'renders autoplay' do
        video['autoplay'] = true
        cover_html.should have_tag('figure.play')
      end

      it 'renders lazy load' do
        cover_html.should have_tag('iframe[data-src="http://youtube.com/embed/cats?autohide=1&autoplay=1&color=white&controls=0&enablejsapi=1&hd=1&iv_load_policy=3&loop=0&origin=https%3A%2F%2Fissueapp.com&playlist=cats&rel=0&showinfo=0&wmode=transparent"]')
      end

      it 'renders fullscreen mode' do
        cover_html.should have_tag('iframe[webkitallowfullscreen][mozallowfullscreen][allowfullscreen]')
      end
    end

    describe 'vimeo iframe' do
      before do
        video['cover'] = true
        video['link'] = 'http://vimeo.com/98524032'
      end

      it 'renders video iframe' do
        cover_html.should have_tag('figure.cover-area.video') do
          with_tag 'iframe', with: {frameborder: '0', height: '100%', width: '100%'}
        end
      end

      it 'renders thumb background' do
        video['thumb_url'] = 'http://i.vimeocdn.com/video/479274132_640.jpg'
        cover_html.should have_tag('figure[style="background-image: url(\'http://i.vimeocdn.com/video/479274132_640.jpg\')"]')
      end

      it 'renders autoplay' do
        video['autoplay'] = true
        cover_html.should have_tag('figure.play')
      end

      it 'renders lazy load' do
        cover_html.should have_tag('iframe[data-src="http://player.vimeo.com/video/98524032?autoplay=1&byline=0&controls=0&loop=0&muted=0&portrait=0"]')
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

    describe 'Location decoration' do
      let(:image) { {location: {name: 'Home', coordinate: [-31.648238,139.013542]}} }

      before do
        page['images'] = [image]
        page['content'] = '<img data-media-id="images:1">'
      end

      it 'renders location tag' do
        html.should have_tag('a.geo')
      end

      it 'renders location name' do
        html.should have_tag('a[href*="label=Home"]')
      end

      it 'renders location coordinate' do
        html.should have_tag('a[href*="-31.648238,139.013542"]')
      end
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

      it 'renders inset caption' do
        image['caption'] = 'image caption'
        image['caption_inset'] = true

        html.should have_tag('figcaption.inset')
      end
    end

    describe 'Video decoration' do
      let(:video) { {} }

      before do
        page['videos'] = [video]
        page['content'] = '<video data-media-id="videos:1">'
      end

      it 'renders figure around video' do
        html.should have_tag('figure.video')
      end

      it 'renders thumb background' do
        video['thumb_url'] = 'assets/background.jpg'
        html.should have_tag('figure[style="background-image: url(\'assets/background.jpg\')"]')
      end

      it 'renders HTML5 video tag (mp4)' do
        video['url'] = 'assets/video.mp4'
        html.should have_tag('video[data-src="assets/video.mp4"]')
      end

      it 'renders caption' do
        video['caption'] = 'this is a video'
        html.should have_tag('figcaption', 'this is a video')
      end

      it 'renders inset caption' do
        video['caption_inset'] = true
        video['caption'] = 'this is a video'
        html.should have_tag('figcaption.inset')
      end

      it 'adds playback attribute: :autoplay, :muted, :controls'

      it 'renders autoplay' do
        video['autoplay'] = true
        html.should have_tag('video[autoplay=true]')
      end


      describe 'youtube iframe' do
        before do
          video['link'] = 'https://www.youtube.com/watch?v=cats'
        end

        it 'renders video iframe' do
          html.should have_tag('figure.video') do
            with_tag 'iframe[frameborder="0"][width="100%"][height="100%"]'
          end
        end

        it 'renders thumb background' do
          video['thumb_url'] = 'assets/background.jpg'
          html.should have_tag('figure[style="background-image: url(\'assets/background.jpg\')"]')
        end

        it 'renders lazy load' do
          html.should have_tag('iframe[data-src="http://youtube.com/embed/cats?autohide=1&autoplay=1&color=white&controls=0&enablejsapi=1&hd=1&iv_load_policy=3&loop=0&origin=https%3A%2F%2Fissueapp.com&playlist=cats&rel=0&showinfo=0&wmode=transparent"]')
        end

        it 'renders autoplay by default' do
          html.should have_tag('[data-src*="autoplay=1"]')

          view.page.videos.first.autoplay = false
          view.content_html.should have_tag('[data-src*="autoplay=0"]')
        end

        it 'renders controls' do
        end

        it 'renders loop' do
        end

        it 'renders fullscreen mode'
        it 'renders poster'
      end

      describe 'vimeo iframe' do
        it 'renders video iframe'
        it 'renders thumb background'
        it 'renders autoplay'
        it 'renders lazy load'
        it 'renders fullscreen mode'
      end
    end

    describe 'Audio decoration' do
      it 'render figure around audio'
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

  describe 'Edit mode' do
    it 'decorates image with <img> tag'
    it 'decorates video with <video> tag'
  end
end
