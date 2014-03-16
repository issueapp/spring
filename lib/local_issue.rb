class LocalIssue < Hashie::Mash
  
  # minkpink/music
  # insight/guide
  def self.find(path)
    
    issue_handle = path.split("/").last
    
    # cd issues/music
    issue_path = Pathname(File.expand_path("../../issues/#{issue_handle}", __FILE__))
    Dir.chdir issue_path
    
    yaml = issue_path.join("issue.yaml")
    
    if yaml.exist?
      attributes = YAML.load_file(yaml) 
      
      new attributes
    end
  end
  
  def pages
    @pages ||= Page.all
    
    self[:pages].map do |handle|
      Page.find(handle)
    end
  end
  
  def pathes
    self.pages.reduce([]) do |result, page|
      result << page.handle
      
      unless page.children.empty?
        result += page.children.map {|child| "#{page.handle}/#{child.handle}" }
      end
      
      result
    end
  end
end