require_relative '../local_issue'
require_relative 'style_file_importer'

class LocalIssue::CustomCss
  attr_reader :issue

  def initialize issue
    case issue
    when LocalIssue
      @issue = issue
    when String
      @issue = LocalIssue.find(issue)
    else
      raise "Local issue not found: #{LocalIssue.root/issue}"
    end
  end

  def style_paths
    issue.paths.reduce([]) do |memo, path|
      path = 'cover' if path == 'index'
      memo << path if style_path(path).exist?
      memo
    end
  end

  # extracted font face definitions from :issue/styles/_issue.scss
  def fonts
    unless defined? @fonts
      parse_issue_scss
    end

    @fonts
  end

  # extracted keyframes definitions from :issue/styles/_issue.scss
  def keyframes
    unless defined? @keyframes
      parse_issue_scss
    end

    @keyframes
  end

  # extracted scss from :issue/styles/_issue.scss
  def issue_scss
    unless defined? @issue_scss
      parse_issue_scss
    end

    @issue_scss
  end

  def fresh?
    return false if ! custom_scss_path.exist?
    return false if issue_scss_path.exist? && mtime < issue_scss_path.mtime

    issue.paths.each do |path|
      path = 'cover' if path == 'index'
      page_style_path = style_path(path)
      return false if page_style_path.exist? && mtime < page_style_path.mtime
    end

    true
  end

  def write scss
    IO.write(custom_scss_path, scss)
  end

  def to_css
    css_path = Rails.root/"tmp/local_#{issue.magazine_handle}_#{issue.handle}_custom.css"

    if stale_css = !css_path.exist? || css_path.mtime < mtime
      Sass.load_paths.concat([issue.path/'styles', Rails.root/'app/assets/stylesheets/'])
      css = Sass.compile_file(custom_scss_path.to_s, issue: issue, filesystem_importer: StyleFileImporter)
      css = AutoprefixerRails.process(css, from: 'custom.scss', browsers: ['> 1%', 'ie 10']).css
      IO.write(css_path, css)
    else
      css = css_path.read
    end

    css
  end

  private

  def style_path path
    parent, child = path.split('/')

    if child
      style_path = "#{parent}/_#{child}"
    else
      style_path = "_#{parent}"
    end

    issue.path/"styles/#{style_path}.scss"
  end

  def mtime
    @mtime ||= custom_scss_path.mtime
  end

  def custom_scss_path
    @custom_scss_path ||= issue.path/'assets/custom.scss'
  end

  def issue_scss_path
    @issue_scss_path ||= style_path('issue')
  end

  def parse_issue_scss
    @fonts = []
    @keyframes = []
    @issue_scss = ''

    return unless issue_scss_path.exist?

    scss = IO.read(issue_scss_path)
    filename = File.basename(issue_scss_path)
    importer = Sass::Importers::Filesystem.new('.')
    parser = Sass::SCSS::Parser.new(scss, filename, importer)

    tree = parser.parse

    tree.children.each do |node|
      case node
      when Sass::Tree::DirectiveNode
        case node.name
        when '@font-face'
          @fonts << node.to_scss
        when '@keyframes'
          @keyframes << node.to_scss
        else
          @issue_scss << node.to_scss
        end
      else
        @issue_scss << node.to_scss
      end
    end
  end
end
