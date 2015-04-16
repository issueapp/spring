require 'local_issue/page_view'
#require 'issue/page_view'

RSpec.describe Issue::PageView do
  let(:page) { LocalIssue::Page.new }
  let(:view) { LocalIssue::PageView.new(page) }

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
    it { should respond_to('author') }
    it { should respond_to('credits') }

    it { should respond_to('has_parent?') }
    it { should respond_to('parent') }
    it { should respond_to('parent_title') }

    it { should respond_to('layout') }

    it { should respond_to('custom_layout?') }
    it { should respond_to('custom_layout_class') }
    it { should respond_to('custom_html') }

    it { should respond_to('content_html') }

    it { should respond_to('cover?') }
    it { should respond_to('cover') }
    it { should respond_to('cover_html') }
    #it { should respond_to('cover_layout_class') }

    it { should respond_to('product?') }
    it { should respond_to('products_html') }
  end

  describe 'multicolumn'
  describe 'products'
  describe 'cover'
  describe 'author'

  describe 'page elements' do
    describe 'video'
    describe 'audio'
    describe 'image'
    describe 'link'
  end

  describe 'custom html'

  describe 'layout'
end
