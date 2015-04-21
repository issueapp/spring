require 'support/local_issue'
require 'local_issue/page'

# get rid of deprecation warning
I18n.enforce_available_locales = false

RSpec.describe LocalIssue::Page do
  let(:spring) {local_issue 'spring'}
  let(:rebelskhed) {local_issue 'rebelskhed'}
  let(:music) {local_issue 'music'}

  describe '.all' do
    it 'returns all pages for an issue' do
    end
  end

  describe '.build' do
    it 'builds images from a list of URLs' do
      page = LocalIssue::Page.build('toc', issue: music)
      expect( page.images.first.url ).to eq 'assets/toc/brand_logo.png'
    end

    it 'compiles Markdown content into HTML-mustache' do
      page = LocalIssue::Page.build('dummy', {}, <<-PAGE.gsub(/^ {6}/, ''))
      ---
      title: dummy
      ---
      {{title}}

      have a great day
      PAGE

      expect( page.content ).to eq <<-HTML_Mustache.gsub(/^ {6}/, '')
      <p>{{title}}</p>

      <p>have a great day</p>
      HTML_Mustache
    end

    it 'compiles custom html into HTML-mustache' do
      page = LocalIssue::Page.build('dummy', {}, <<-PAGE.gsub(/^ {6}/, ''))
      ---
      custom_html: true
      ---
      <figure class="cover-area" style="background-image: url({{ cover.thumb_url }})">
        <header>
          <h1 class="title">{{title}}</h1>
        </header>
      </figure>
      PAGE

      expect( page.custom_html ).to eq <<-HTML_Mustache.gsub(/^ {6}/, '')
      <figure class="cover-area" style="background-image: url({{ cover.thumb_url }})">
        <header>
          <h1 class="title">{{title}}</h1>
        </header>
      </figure>
      HTML_Mustache
    end

=begin
    it 'hides author on subpage' do
      page = LocalIssue::Page.build('story-one/1', issue: rebelskhed)
      expect( page.layout.hide_author ).to eq '1'
    end

    it 'shows author on page' do
      page = LocalIssue::Page.build('story-three', issue: spring)
      expect( page.layout.hide_author ).to be_nil
    end
=end
  end

  describe '.recursive_build' do
    it 'builds children pages' do
      pages = LocalIssue::Page.recursive_build('story-four', {}, issue: spring)

      expect( pages.count ).to eq 2
      expect(pages).to all( be_a(LocalIssue::Page) )
    end
  end

  describe '#to_hash(local_path: true)' do
    context 'when page has children' do
      it 'strips off _url suffix in *_url attributes' do
        hash = local_page('shopping', rebelskhed).to_hash(local_path: true)

        expect( hash['children'].first['products'].first ).to include(
          'image' => issue_path('rebelskhed/assets/shopping/p2-product-1.jpg')
        )
        expect( hash['children'].first['images'].first ).to include(
          'file' => issue_path('rebelskhed/assets/madhouse/4.jpg'),
          'thumb' => issue_path('rebelskhed/assets/madhouse/4.jpg')
        )
      end

      it 'does not convert *_url attributes that is remote' do
        hash = local_page('3-shop-the-shoot/1', music).to_hash(local_path: true)

        expect( hash['products'][1] ).to include(
          'image_url' => 'http://www.femalefirst.co.uk/image-library/square/270/b/black-ribbon-trim-shaker-hat.jpg'
        )
      end
    end

    it 'strips off _url suffix in *_url attributes' do
      hash = local_page('shopping', rebelskhed).to_hash(local_path: true)

      expect( hash['products'].first ).to include(
        'image' => issue_path('rebelskhed/assets/shopping/p1-product-1.jpg')
      )
      expect( hash['images'].first ).to include(
        'file' => issue_path('rebelskhed/assets/madhouse/3.jpg'),
        'thumb' => issue_path('rebelskhed/assets/shopping_thumb.jpg')
      )
    end

    it 'does not convert *_url attributes that is remote' do
      hash = local_page('video-heat', rebelskhed).to_hash(local_path: true)

      expect( hash['videos'].first ).to include(
        'thumb_url' => 'http://i.vimeocdn.com/video/479274132_640.jpg'
      )
    end
  end
end
