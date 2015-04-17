def local_issue handle
  LocalIssue.find handle
end

def local_page path, local_issue
  LocalIssue::Page.find(path, issue: local_issue)
end

def issue_path path
  Pathname(File.expand_path("../../../issues/", __FILE__)).join(path)
end

def pretty_json hash
  require 'json'
  JSON.pretty_generate hash
end
