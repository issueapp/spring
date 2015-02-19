require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'

class LocalIssue < Hashie::Mash

  def self.all
    issues_path = Pathname(File.expand_path("../../issues", __FILE__))

    Dir.glob("#{issues_path}/*/issue.yaml").map do |file|
      issue_path = file.split("/").first

      find issue_path
    end
  end

  # music
  # insight/guide
  def self.find path
    issue_handle = path.split("/").last

    # cd issues/music
    issue_path = Pathname(File.expand_path("../../issues/#{issue_handle}", __FILE__))

    if issue_path.exist?
      # Dir.chdir issue_path
      yaml = issue_path.join("issue.yaml")

      if yaml.exist?
        attributes = YAML.load_file(yaml)

        # Build default labels
        attributes["handle"] ||= issue_handle
        attributes["magazine_handle"] ||= attributes["magazine_title"].parameterize

        attributes["id"]     ||= Digest::MD5.hexdigest("#{attributes["handle"]}/#{attributes["magazine_handle"]}")
        attributes["assets"] ||= []

        new attributes
      end
    end
  end

  def theme
    self[:theme] || "default"
  end

  def path
    Pathname(File.expand_path("../../issues/#{handle}/", __FILE__))
  end

  def pages_count
    pages.map(&:children).flatten.count + pages.count
  end

  def pages
    self[:paths].to_a.map do |handle|
      LocalIssue::Page.find(handle, issue: self).tap do |p|
        if p.handle == "index"
          p.thumb_url = self.thumb_url
          p.cover_url = self.cover_url
        end
      end
    end
  end

  def paths
    self.pages.reduce([]) do |result, page|
      result << page.handle

      unless page.children.empty?
        result += page.children.map(&:handle)
      end

      result
    end
  end

  def to_hash options={}
    hash = super.except("id", "featured")

    if options[:local_path]
      convert_local_path = lambda do |hash|
        hash.keys.each do |key|
          if key =~ /_url/
            url = hash.delete(key)
            hash[key.sub(/_url$/, '')] = path.join(url)
          end
        end
      end

      convert_local_path.call(hash)

      Array(hash['collaborators']).each do |h|
        convert_local_path.call(h)
      end
    end

    hash
  end
end
