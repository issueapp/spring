require 'support/local_issue'
require 'issue/page_view'
require 'local_issue/page'

RSpec.describe Issue::PageView do
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
    let(:page) { LocalIssue::Page.build('story-three', issue: spring) }
    let(:view) { Issue::PageView.new(page) }

    subject { view }

    it { should respond_to('layout_class') }

    it { expect( view.dom_id   ).to eq 'sstory-three' }

    it { expect( view.show_author? ).to be_truthy }
    it { expect( view.author ).to eq Struct::Author.new('Emily Tan', nil) }

    it { expect( view.column_break_count).to be 2 }

    it { expect( view.custom_html? ).to be_falsy }

    it { should respond_to('cover_html') }
    it { should respond_to('custom_html') }
    it { should respond_to('content_html') }
    it { should respond_to('product_set_html') }
  end

  describe 'author' do
    it 'includes author name and icon' do
      page = LocalIssue::Page.build('video-six', issue: accelerator)
      view = Issue::PageView.new(page)

      expect(view.author).to eq Struct::Author.new('Zyralyn Bacani', 'http://cl.ly/StPu/Image%202013.12.11%204%3A54%3A01%20pm.png')
    end

    it 'shows author when there is an author' do
      page = LocalIssue::Page.build('1-a-holiday-in-style', issue: great_escape)
      view = Issue::PageView.new(page)

      expect(view.show_author?).to be_truthy
    end

    it 'shows/hides author based on switch' do
      page = LocalIssue::Page.build('an-ode-to-produce', issue: escape_one)
      view = Issue::PageView.new(page)

      expect(view.show_author?).to be_falsy

      page.layout.hide_author = false
      expect(view.show_author?).to be_truthy
    end

    it 'hides author on child pages' do
      page = LocalIssue::Page.build('1-styling-it-out/1', issue: music)
      view = Issue::PageView.new(page)

      expect(view.show_author?).to be_falsy
    end
  end

  describe 'multicolumn' do
    it 'has 0 column break by default'

    it 'has 1 column break for cover or product set' do
      page = LocalIssue::Page.build('video-six', issue: accelerator)
      view = Issue::PageView.new(page)
      expect(view.column_break_count).to eq 1
    end

    it 'has 2 column breaks when three column cover takes up 2 column' do
      page = LocalIssue::Page.build('story-one', issue: top3)
      view = Issue::PageView.new(page)

      expect(view.column_break_count).to eq 2
    end
  end

  describe 'products' do
    it 'detects product set' do
      page = LocalIssue::Page.build('story-six', issue: top3)
      view = Issue::PageView.new(page)

      expect(view.product_set?).to be_truthy
    end

    it 'renders product set html' do
      page = LocalIssue::Page.build('story-six', issue: top3)
      view = Issue::PageView.new(page)

      expect(view.product_set_html).to eq(
        %{<ul class="product-set set-6">
<li><a href="" class="product hotspot" title="Chillsner Beer Chiller 2pk" data-track="hotspot:click" data-action="" data-url="http://top3.com.au/categories/bar-and-wine-and-water/beer-and-accessories/chillsner-beer-chiller/4002c" data-image="assets/story-six/p1-product-1.jpg" data-price="$40" data-currency="" data-description="Chillsner by Corkcicle. Just freeze, insert into any bottled beer and never suffer through another warm brew. Respect the beer. Chillsner is perfect for parties, tailgating and pretty much any occasion where beloved beers are enjoyed."><img src="assets/story-six/p1-product-1.jpg"><span class="tag">1</span></a></li>
<li><a href="" class="product hotspot" title="Elipson Timber" data-track="hotspot:click" data-action="" data-url="http://top3.com.au/categories/home-and-living/audio---bluetooth-speakers/elipson-bluetooth-speakers/elipsontimber" data-image="assets/story-six/p1-product-2.jpg" data-price="$499" data-currency="" data-description="The Timber is a compact wireless speaker born from cooperation between Habitat &amp; Elipson, that works according to the Bluetooth 2.1 protocol."><img src="assets/story-six/p1-product-2.jpg"><span class="tag">2</span></a></li>
<li><a href="" class="product hotspot" title="Sphere Bottle Opener Natural" data-track="hotspot:click" data-action="" data-url="http://top3.com.au/categories/bar-and-wine-and-water/bottle-openers/areaware-sphere-bottle-opener/aw-fsbon" data-image="assets/story-six/p1-product-3.jpg" data-price="$30" data-currency="" data-description="A smooth, ergonomic bottle opener that fits perfectly in the palm of your hand. Made From Beechwood."><img src="assets/story-six/p1-product-3.jpg"><span class="tag">3</span></a></li>
<li><a href="" class="product hotspot" title="Whisky stones" data-track="hotspot:click" data-action="" data-url="http://top3.com.au/categories/bar-and-wine-and-water/drinks---cooling-accessories/whisky-stones/whiskystone" data-image="assets/story-six/p1-product-4.jpg" data-price="$30" data-currency="" data-description="Ideal for chilling your favorite spirit without diluting its flavor with melting ice."><img src="assets/story-six/p1-product-4.jpg"><span class="tag">4</span></a></li>
<li><a href="" class="product hotspot" title="Block Table by Norman Copenhagen" data-track="hotspot:click" data-action="" data-url="http://top3.com.au/categories/bar-and-wine-and-water/bar-trolleys/nm-block-table/602205" data-image="assets/story-six/p1-product-5.jpg" data-price="$465" data-currency="" data-description="The Block table by Normann Copenhagen is a versatile and mobile table - perfect for use as a bar trolley, or for countless other uses in the home."><img src="assets/story-six/p1-product-5.jpg"><span class="tag">5</span></a></li>
<li><a href="" class="product hotspot" title="Beer Foamer Copper by Menu" data-track="hotspot:click" data-action="" data-url="http://top3.com.au/categories/bar-and-wine-and-water/beer-and-accessories/menu-beer-foamer/men4690239" data-image="assets/story-six/p1-product-6.jpg" data-price="AUD $99" data-currency="" data-description="The Beer Foamer gets you as close to the Pub experience as you can without leaving your home. Denser beer foam will significantly increase the taste, aroma and feeling of the beer - just like beer fresh from the tap."><img src="assets/story-six/p1-product-6.jpg"><span class="tag">6</span></a></li>
</ul>}
      )
    end

    it 'detects and renders product set according to size' do
      page = LocalIssue::Page.build('story-six', issue: top3)
      view = Issue::PageView.new(page)

      expect(view.product_set_html).to start_with(
        %{<ul class="product-set set-6">}
      )
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
  
  def page_view(hash)
    Issue::PageView.new(LocalIssue::Page.new(hash))
  end
end
