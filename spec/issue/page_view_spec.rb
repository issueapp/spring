require 'support/local_issue'
require 'issue/page_view'
require 'local_issue/page'

RSpec.describe Issue::PageView do
  let(:top3) {local_issue 'top3'}
  let(:spring) {local_issue 'spring'}
  let(:spread) {local_issue 'spread'}
  let(:rebelskhed) {local_issue 'rebelskhed'}
  let(:music) {local_issue 'music'}

  describe 'Rendering Helpers' do
    let(:page) { LocalIssue::Page.build('story-three', issue: spring) }
    let(:view) { Issue::PageView.new(page) }

    subject { view }

    it { should respond_to('layout_class') }

    it { expect( view.dom_id   ).to eq 'sstory-three' }
    it { expect( view.page_id  ).to be_nil }
    it { expect( view.path     ).to eq 'story-three' }
    it { expect( view.handle   ).to eq 'story-three' }
    it { expect( view.title    ).to eq 'Passionfruit Cheesecake with Caramelised Pineapple' }
    it { expect( view.summary  ).to be_nil }
    it { expect( view.category ).to eq 'Recipe' }

    it { expect( view.theme    ).to eq 'white' }
    it { expect( view.credits  ).to be_nil }

    it { expect( view.show_author? ).to be_truthy }
    it { expect( view.author ).to eq Struct::Author.new('Emily Tan', nil) }

    it { expect( view ).not_to have_parent }
    it { expect( view.parent ).to be_nil }

    it { expect( view.layout.to_hash ).to be_a Hash }
    it { expect( view.column_break_count).to be 2 }

    it { expect( view ).not_to be_custom_layout }
    it { should respond_to('custom_html') }

    it { should respond_to('content_html') }

    it { expect( view ).to have_cover }
    it { should respond_to('cover') }
    it { should respond_to('cover_html') }

    it { expect( view ).not_to have_product_set }
    it { should respond_to('product_set_html') }
  end

  describe 'author' do
    it 'includes author name and icon'
    it 'shows/hides author based on switch'
    it 'shows author when there is an author'
    it 'hides author on child pages'
  end

  describe 'multicolumn' do
    it 'has 0 column break by default'
    it 'has 1 column break for cover or product set'
    it 'has 2 column breaks when three column cover takes up 2 column'
  end

  describe 'products' do
    it 'detects product set' do
      page = LocalIssue::Page.build('story-six', issue: top3)
      view = Issue::PageView.new(page)

      expect(view).to have_product_set
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
        %{<figure class="cover-area cover  image" style="background-image: url(assets/2-head-or-heart/p1-cover.jpg)"><figcaption class="inset">MINKPINK Funday Sunday Dress.</figcaption></figure>}
      )
    end

    it 'detects and renders video iframe for vimeo and youtube' do
      page = LocalIssue::Page.build('video-one', issue: spread)
      view = Issue::PageView.new(page)

      # view.cover_html to have
      #   figure.cover-area > iframe|video
      #   figure style=video.thumb_url
      expect(view.cover_html).to eq(
        %{<figure class="cover-area background  video" style="background-image: url(assets/video-your-way.jpg)"><iframe data-src="http://youtube.com/embed/IZjhUzv1YKw?autoplay=1&amp;controls=0&amp;loop=0&amp;playlist=IZjhUzv1YKw&amp;autohide=1&amp;color=white&amp;enablejsapi=1&amp;hd=1&amp;iv_load_policy=3&amp;origin=http%3A%2F%2Fissueapp.com&amp;rel=0&amp;showinfo=0&amp;wmode=transparent" frameborder="0" height="100%" width="100%" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe></figure>}
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
      it 'renders image block around figure'
      it 'renders captions in figcaption tag'
      it 'adds inset class'
    end

    describe 'link'

    describe 'audio' do
      it 'render video block around figure'
      it 'adds playback attribute: :autoplay, :muted, :controls'
      it 'might have custom thumbnail'
    end
  end

  describe 'content html' do
    it 'decorates data-* attributes with corresponding page element'
  end

  describe 'custom html' do
    it 'decorates data-* attributes with corresponding page element'
  end

  describe 'layout' do
    it 'defaults layout type to two-column'
    it 'outputs custom layout class'
    it 'outputs page layout class'
    it 'returns layout object'
  end
end
