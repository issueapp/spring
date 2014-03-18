require 'active_support/core_ext/string'

class LocalIssue < Hashie::Mash

  def self.all    
    Dir.chdir Pathname(File.expand_path("../../issues", __FILE__))
    
    Dir.glob("*/issue.yaml").map do |file|
      issue_path = file.split("/").first
      
      find issue_path
    end
  end
  
  # music
  # insight/guide
  def self.find(path)
    issue_handle = path.split("/").last
    
    # cd issues/music
    issue_path = Pathname(File.expand_path("../../issues/#{issue_handle}", __FILE__))
    
    if issue_path.exist?
      Dir.chdir issue_path
      yaml = issue_path.join("issue.yaml")
    
      if yaml.exist?
        attributes = YAML.load_file(yaml)
        
        attributes["handle"] ||= issue_handle
        attributes["magazine_handle"] ||= attributes["magazine_title"].parameterize
        
        attributes["id"]     ||= Digest::MD5.hexdigest("#{attributes["handle"]}/#{attributes["magazine_handle"]}")
        
        new attributes
      end
    end
    
  end
  
  def path
    Pathname(File.expand_path("../../issues/#{handle}/", __FILE__))
  end
  
  def items
    @items ||= Page.all
    
    self[:pages].to_a.map do |handle|
      LocalIssue::Page.find(handle, self.path)
    end
  end
  
  def pathes
    self.items.reduce([]) do |result, page|
      result << page.handle
      
      unless page.children.empty?
        result += page.children.map(&:handle)
      end
      
      result
    end
  end
  
  def pages
    self[:pages] || []
  end
  
  def to_hash(options = {})
    hash = super
    
    hash.to_a.each do |key, value|
      if options[:local_path] && key =~ /_url/
        
        url = hash.delete(key)
        
        hash[key.gsub('_url', '')] = path.join(value)
      end
    end
    
    hash
  end
end