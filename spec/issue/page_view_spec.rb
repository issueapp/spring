require 'issue/page_view'
require 'local_issue/page'

RSpec.describe Issue::PageView do
  let(:page) { LocalIssue::Page.new }
  let(:view) { Issue::PageView.new(page) }

  describe 'Rendering Helpers' do
    subject { view }

    it { should respond_to('dom_id') }
    it { should respond_to('layout_class') }

    it { should respond_to('page_id') }
    it { should respond_to('path') }
    it { should respond_to('handle') }
    it { should respond_to('title') }
    it { should respond_to('summary') }
    it { should respond_to('category') }

    it { should respond_to('theme') }
    it { should respond_to('credits') }

    it { should respond_to('show_author?') }
    it { should respond_to('author') }

    it { should respond_to('has_parent?') }
    it { should respond_to('parent') }

    it { should respond_to('layout') }
    it { shoulde respond_to('column_break_count') }

    it { should respond_to('custom_layout?') }
    it { should respond_to('custom_layout_class') }
    it { should respond_to('custom_html') }

    it { should respond_to('content_html') }

    it { should respond_to('cover?') }
    it { should respond_to('cover') }
    it { should respond_to('cover_html') }

    it { should respond_to('product?') }
    it { should respond_to('products_html') }
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
    it 'detects products'
    it 'renders product set html'
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
