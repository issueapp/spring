require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object/try'
require 'hashie'
require 'pathname'
require 'yaml'

# Setup auto load for page view mode
Issue rescue Issue = Module.new
Issue.autoload :Preview, 'issue/page_view.rb'

class LocalIssue < Hashie::Mash

  # root of issues data and assets
  def self.root
    @local_issue_root || set_root(ENV['LOCAL_ISSUE_ROOT'] || '~/Dropbox/issues')
  end

  def self.set_root path
    case path
    when String
      if path_is_relative = ! path[0].start_with?('/', '~')
        if defined? Rails
          path = Rails.root/path
        else
          raise "Fail to set local issue root with relative path: #{path}"
        end
      end

      @local_issue_root = Pathname(path.sub(/^~/, ENV['HOME']))
    when Pathname, nil
      @local_issue_root = path
    else
      raise "Fail to set root: #{path}"
    end
  end

  def self.all
    Dir.glob("#{root}/*/issue.yaml").map do |file|
      issue_path = file.split("/").first
      find issue_path
    end
  end

  # music
  # insight/guide
  def self.find path
    issue_handle = path.split("/").last

    issue_path = root/issue_handle
    raise "Issue not found: #{issue_path}" unless issue_path.exist?

    yaml = issue_path/'issue.yaml'
    raise "Issue yaml not found: #{yaml}" unless yaml.exist?

    attributes = YAML.load_file(yaml)

    magazine_handle = attributes['magazine_title'].parameterize
    collaborators = attributes.delete('collaborators')

    # Build default labels
    # FIXME khoa says why do we need this?
    #attributes["id"] ||= Digest::MD5.hexdigest("#{issue_handle}/#{magazine_handle}")
    # /FIXME khoa says why do we need this?
    attributes["handle"] ||= issue_handle
    attributes["magazine_handle"] ||= magazine_handle
    attributes["assets"] ||= []

    local = new(attributes)
    local.regular_writer('collaborators', collaborators)
    local
  end

  def theme
    self[:theme] || "default"
  end

  def path
    raise 'Handle not found' unless handle
    self.class.root/handle
  end

  def pages_count
    pages.map(&:children).flatten.count + pages.count
  end

  def all_pages options={}
    excluded = options['exclude'] || options[:exclude] || []
    root = options['root'] || options[:root]
    layout_nav = options['layout_nav'] || options[:layout_nav] || true

    pages = self.pages
    pages.select!(&:root_page?) if root

    pages.select! do |page|
      ! excluded.include?(page.handle) && page.layout.try('nav') == layout_nav
    end

    pages
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
      result << (page.path || page.handle)

      unless page.children.empty?
        result.concat page.children.map(&:path)
      end

      result
    end
  end
  alias_method :page_paths, :paths

  def to_hash options={}
    hash = {}

    whitelist = %w[
      title description
      magazine_handle magazine_title
      theme
      icon_url thumb_url cover_url
      assets paths collaborators
    ]
    whitelist.each do |a|
      hash[a] = regular_reader(a) if key? a
    end

    if options[:local_path]
      convert_local_path! hash

      Array(hash['collaborators']).each do |h|
        convert_local_path! h
      end
    end

    hash
  end

  def convert_local_path! hash
    hash.keys.each do |key|
      next unless is_local = key.end_with?('_url') && ! String(hash[key]).start_with?('http://', 'https://')

      url = hash.delete(key)
      hash[key.sub(/_url$/, '')] = path/url
    end
  end
end
