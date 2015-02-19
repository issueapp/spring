require 'hashie'
require 'pathname'
require 'yaml'
require './lib/local_issue'

ISSUE_ROOT = Pathname(File.expand_path("../../issues/", __FILE__))

RSpec.describe LocalIssue do
  describe '#to_hash' do
    it 'when local_path is true, strips off _url suffix in *_url attributes' do
      hash = LocalIssue.find('great-escape').to_hash(local_path: true)

      expect(hash).to include(
        "icon" => ISSUE_ROOT.join("great-escape/assets/icon.jpg")
      )
      expect(hash['collaborators'].first).to include(
        "image" => ISSUE_ROOT.join("great-escape/assets/author/zyra.png")
      )
    end
  end
end
