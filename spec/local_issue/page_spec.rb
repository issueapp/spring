require 'local_issue/page'
require 'json'

RSpec.describe LocalIssue::Page do
  describe '#to_hash(local_path: true)' do
    context 'when page has children' do
      it 'strips off _url suffix in *_url attributes' do
        local_issue = LocalIssue.find('rebelskhed')
        local_page = LocalIssue::Page.find('shopping', issue: local_issue)

        hash = local_page.to_hash(local_path: true)
        #puts JSON.pretty_generate hash

        expect( hash['children'].first['products'].first ).to include(
          'image' => ISSUE_PATH.join('rebelskhed/assets/shopping/p2-product-1.jpg')
        )
        expect( hash['children'].first['images'].first ).to include(
          'file' => ISSUE_PATH.join('rebelskhed/assets/assets/madhouse/4.jpg'),
          'thumb' => ISSUE_PATH.join('rebelskhed/assets/madhouse/4.jpg')
        )
      end

      it 'does not convert *_url attributes that is remote' do
      end
    end

    it 'strips off _url suffix in *_url attributes' do
      local_issue = LocalIssue.find('rebelskhed')
      local_page = LocalIssue::Page.find('shopping', issue: local_issue)

      hash = local_page.to_hash(local_path: true)
      #puts JSON.pretty_generate hash

      expect( hash['products'].first ).to include(
        'image' => ISSUE_PATH.join('rebelskhed/assets/shopping/p1-product-1.jpg')
      )
      expect( hash['images'].first ).to include(
        'file' => ISSUE_PATH.join('rebelskhed/assets/madhouse/3.jpg'),
        'thumb' => ISSUE_PATH.join('rebelskhed/assets/shopping_thumb.jpg')
      )
    end

    it 'does not convert *_url attributes that is remote' do
    end
  end
end
