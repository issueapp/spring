require 'local_issue'

LocalIssue.set_root Pathname('spec/fixtures/issues')

# get rid of deprecation warning
I18n.enforce_available_locales = false

RSpec.describe LocalIssue do

  let(:local_issue_hash) { {handle: 'issue'} }
  let(:local_issue) { LocalIssue.new local_issue_hash }

  describe '#find' do
    it 'finds local issue by path :magazine/:issue' do
      LocalIssue.find('spread/spring').should be_a(LocalIssue)
    end

    it 'finds local issue by issue path if unique' do
      LocalIssue.find('spring').should be_a(LocalIssue)
    end

    it 'raises error when issue path matches more than one issue' do
      expect{ LocalIssue.find('hard') }.to raise_error ArgumentError
    end

    it 'uses magazine handle from path' do
      LocalIssue.find('never').magazine_handle.should == 'die'
    end

    it 'prefers magazine handle from issue yaml over path' do
      LocalIssue.find('die/hard').magazine_handle.should == 'dead'
    end

    it 'supports issue.yaml and issue.yml' do
      # issue.yml
      expect { LocalIssue.find('die/never') }.to_not raise_error

      # issue.yaml
      expect { LocalIssue.find('spring') }.to_not raise_error
    end
  end

  describe '#to_hash' do
    pending 'converts to dragonfly friendly key, value pair'

    it 'skips remote url' do
      local_issue_hash['cover_url'] = 'http://iam.remote'
      hash = local_issue.to_hash(local_path: true)

      expect(hash).to eq('cover_url' => 'http://iam.remote')
    end

    it 'converts collaborators to local path' do
      local_issue.regular_writer('collaborators', [{'image_url' => 'path/to/image.png'}])
      hash = local_issue.to_hash(local_path: true)

      expect(hash).to eq('collaborators' => [{'image' => LocalIssue.root/'issue/path/to/image.png'}])
    end

    it 'replaces values with pathnames for keys that end with _url' do
      local_issue_hash['cover_url'] = 'path/to/cover.png'
      hash = local_issue.to_hash(local_path: true)

      expect(hash.values.first).to eq LocalIssue.root/'issue/path/to/cover.png'
    end

    it 'strips off _url at the end of keys' do
      local_issue_hash['thumb_url'] = 'path/to/thumb.png'
      local_issue_hash['icon_url'] = 'path/to/icon.png'

      hash = local_issue.to_hash(local_path: true)

      expect(hash).to include('icon', 'thumb')
    end
  end
end
