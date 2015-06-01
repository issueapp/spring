require 'local_issue'

# get rid of deprecation warning
I18n.enforce_available_locales = false

ISSUE_PATH = Pathname.new(File.expand_path('../../issues', __FILE__))

RSpec.describe LocalIssue do
  describe '#to_hash(local_path: true)' do
    it 'strips off _url suffix in *_url attributes' do
      hash = LocalIssue.find('great-escape').to_hash(local_path: true)

      expect(hash).to include(
        "icon" => ISSUE_PATH.join("great-escape/assets/icon.jpg")
      )
      expect(hash['collaborators'].first).to include(
        "image" => ISSUE_PATH.join("great-escape/assets/author/zyra.png")
      )
    end

    it 'does not convert *_url attributes that is remote' do
      hash = LocalIssue.find('adventure').to_hash(local_path: true)

      expect(hash['collaborators'].first).to include(
        "image_url" => 'http://cl.ly/StPu/Image%202013.12.11%204%3A54%3A01%20pm.png'
      )
    end
  end
end
