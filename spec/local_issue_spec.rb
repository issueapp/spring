require 'local_issue'

# get rid of deprecation warning
I18n.enforce_available_locales = false

RSpec.describe LocalIssue do

  let(:local_issue_hash) { {handle: 'issue'} }
  let(:local_issue) { LocalIssue.new local_issue_hash }

  describe '#to_hash' do

    context 'From dropbox repository' do
      it 'skips remote url' do
        local_issue_hash['cover_url'] = 'http://iam.remote'
        hash = local_issue.to_hash(repository: 'dropbox')

        expect(hash).to eq('cover_url' => 'http://iam.remote')
      end

      it 'replaces values with content for keys that end with _url' do
        local_issue_hash['handle'] = 'rebelskhed'
        local_issue_hash['cover_url'] = 'assets/shopping_thumb.jpg'
        hash = local_issue.to_hash(repository: 'dropbox')

        expect(hash).to eq('cover' => IO.read('issues/rebelskhed/assets/shopping_thumb.jpg'))
      end

      it 'strips off _url at the end of keys'
    end

    context 'From local repository' do
      pending 'converts to dragonfly friendly key, value pair'

      it 'skips remote url' do
        local_issue_hash['cover_url'] = 'http://iam.remote'
        hash = local_issue.to_hash(repository: 'local')

        expect(hash).to eq('cover_url' => 'http://iam.remote')
      end

      it 'converts collaborators to local path' do
        local_issue.regular_writer('collaborators', [{'image_url' => 'path/to/image.png'}])
        hash = local_issue.to_hash(repository: 'local')

        expect(hash).to eq('collaborators' => [{'image' => Spring.issues_path/'issue/path/to/image.png'}])
      end

      it 'replaces values with pathnames for keys that end with _url' do
        local_issue_hash['cover_url'] = 'path/to/cover.png'
        hash = local_issue.to_hash(repository: 'local')

        expect(hash.values.first).to eq Spring.issues_path/'issue/path/to/cover.png'
      end

      it 'strips off _url at the end of keys' do
        local_issue_hash['thumb_url'] = 'path/to/thumb.png'
        local_issue_hash['icon_url'] = 'path/to/icon.png'

        hash = local_issue.to_hash(repository: 'local')

        expect(hash).to include('icon', 'thumb')
      end
    end
  end
end
