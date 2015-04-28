require 'support/local_issue'
require 'issue/page_view'
require 'local_issue/page'

RSpec.describe Issue::PageView do
  let(:page) { {} }
  let(:view) { page_view page }

  let(:accelerator) {local_issue 'accelerator'}
  let(:adventure) {local_issue 'adventure'}
  let(:escape_one) {local_issue 'escape-one'}
  let(:great_escape) {local_issue 'great-escape'}
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
    before do
      page['handle'] = 'story-three'
      page['author_name'] = 'Emily Tan'
    end

    subject { view }

    it { view.dom_id.should eq 'sstory-three' }

    it { view.show_author?.should be_truthy }
    it { view.author.should eq Struct::Author.new('Emily Tan', nil) }

    it { view.column_break_count.should be_zero }

    it { view.custom_html?.should be_falsy }

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

    it 'renders product set in mulitples of twos' do
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
    it 'detects and renders image background' do
      page = LocalIssue::Page.build('2-head-or-heart/1', issue: music)
      view = Issue::PageView.new(page)

      expect(view.cover_html).to eq(
        %{<figure class="cover-area cover image" style="background-image: url(assets/2-head-or-heart/p1-cover.jpg)"><figcaption class="inset">MINKPINK Funday Sunday Dress.</figcaption></figure>}
      )
    end

    it "supports HTML5 video tag (mp4)" do
    end

    it 'detects and renders video iframe for vimeo and youtube' do
      page = LocalIssue::Page.build('video-one', issue: spread)
      view = Issue::PageView.new(page)

      # view.cover_html to have
      #   figure.cover-area > iframe|video
      #   figure style=video.thumb_url
      expect(view.cover_html).to eq(
        %{<figure class="cover-area background video play" style="background-image: url(assets/video-your-way.jpg)"><iframe data-src="http://youtube.com/embed/IZjhUzv1YKw?autoplay=1&amp;controls=0&amp;loop=0&amp;playlist=IZjhUzv1YKw&amp;autohide=1&amp;color=white&amp;enablejsapi=1&amp;hd=1&amp;iv_load_policy=3&amp;origin=http%3A%2F%2Fissueapp.com&amp;rel=0&amp;showinfo=0&amp;wmode=transparent" frameborder="0" height="100%" width="100%" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe></figure>}
      )
    end

    it 'renders caption' do
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
