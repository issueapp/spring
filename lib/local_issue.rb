require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object/try'
require 'hashie'
require 'pathname'
require 'yaml'

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
    magazine_handle, issue_handle = path.split('/')
    magazine_handle, issue_handle = nil, magazine_handle if issue_handle.nil?

    if magazine_handle.nil?
      glob_pattern = (root/'*'/issue_handle).to_s
    else
      glob_pattern = (root/magazine_handle/issue_handle).to_s
    end

    issue_paths = Dir[glob_pattern]
    case issue_paths.count
    when 1
      issue_path = Pathname(issue_paths.first)
    when 0
      raise ArgumentError, "Issue not found: #{path}"
    else
      raise ArgumentError, "Ambiguous match: #{issue_paths}"
    end

    yml = locate_issue_yml(issue_path)
    attributes = YAML.load_file(yml)

    collaborators = attributes.delete('collaborators')

    attributes['handle'] ||= issue_handle
    attributes['magazine_handle'] ||= File.basename(File.dirname(issue_path))
    attributes['assets'] ||= []

    local = new(attributes)
    local.regular_writer('collaborators', collaborators)
    local
  end

  def self.locate_issue_yml issue_path
    %w[issue.yml issue.yaml].each do |issue_yml|
      yml = issue_path/issue_yml
      return yml if yml.exist?
    end

    raise "Issue yaml not found at #{issue_path}"
  end

  def theme
    self[:theme] || "default"
  end

  def yaml_path
    self.class.locate_issue_yml path
  end

  def path
    raise 'Handle not found' unless magazine_handle && handle
    self.class.root/magazine_handle/handle
  end

  def pages_count
    pages.map(&:children).flatten.count + pages.count
  end

  # options
  #   layout_nav
  #     true (default)    all pages with layout.nav true or nil
  #     false             all pages with layout.nav false
  #     nil               all pages regardless of layout.nav value
  def all_pages options={}
    excluded = options[:exclude] || []
    root_only = options.fetch(:root){false}
    layout_nav = options.fetch(:layout_nav){true}

    self.pages.reduce([]) do |result, page|
      next result if excluded.include?(page.handle) ||
        (!layout_nav.nil? && page.style.try('nav') != layout_nav)

      result << page
      result.concat page.children unless root_only
      result
    end
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

  #def paths
  #  self.pages.reduce([]) do |result, page|
  #    result << (page.path || page.handle)

  #    unless page.children.empty?
  #      result.concat page.children.map(&:path)
  #    end

  #    result
  #  end
  #end
  #alias_method :page_paths, :paths

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
