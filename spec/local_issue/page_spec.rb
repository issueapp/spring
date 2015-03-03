require 'local_issue/page'

RSpec.describe LocalIssue::Page do
  let(:rebelskhed) {local_issue 'rebelskhed'}
  let(:music) {local_issue 'music'}

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

  def local_issue handle
    LocalIssue.find handle
  end

  def local_page path, local_issue
    LocalIssue::Page.find(path, issue: local_issue)
  end

  def issue_path path
    ISSUE_PATH.join path
  end

  def pretty_json hash
    require 'json'
    puts JSON.pretty_generate hash
  end
end
