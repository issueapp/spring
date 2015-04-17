require 'support/local_issue'
require 'issue/page_view'
require 'local_issue/page'

RSpec.describe Issue::PageView do
  let(:spring) {local_issue 'spring'}
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
    it { expect( view.credits  ).to be_nil? }

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
    it { should respond_to('products_set_html') }
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
    end

    it 'renders product set html' do
    end
  end

  describe 'cover' do
    it 'detects image cover'
    it 'detects video cover'
    it 'renders cover html'
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
