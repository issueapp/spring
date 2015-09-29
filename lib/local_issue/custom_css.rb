require_relative '../local_issue'

class LocalIssue::CustomCss
  attr_reader :local_issue

  def initialize issue
    case issue
    when LocalIssue
      @local_issue = issue
    when String
      @local_issue = LocalIssue.find(issue)
    else
      raise "Local issue not found: #{LocalIssue.root/issue}"
    end
  end

  def page_selectors_and_paths
    local_issue.paths.reduce({}) do |memo, path|
      if path == 'index' && cover?
        memo[path] = 'cover'
      elsif page_style? path
        memo[path] = path
      end

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
  def issue
    unless defined? @issue_scss
      parse_issue_scss
    end

    @issue_scss
  end

  def issue?
    issue_scss_path.exist?
  end

  def cover?
    (local_issue.path/'styles/_cover.scss').exist?
  end

  def page_style? path
    parent, child = path.split('/')

    if child
      page_style_path = "#{parent}/_#{child}"
    else
      page_style_path = "_#{parent}"
    end

    (local_issue.path/"styles/#{page_style_path}.scss").exist?
  end

  private

  def issue_scss_path
    local_issue.path/'styles/_issue.scss'
  end

  def parse_issue_scss
    scss = IO.read(issue_scss_path)
    filename = File.basename(issue_scss_path)
    importer = Sass::Importers::Filesystem.new('.')
    parser = Sass::SCSS::Parser.new(scss, filename, importer)

    tree = parser.parse

    @fonts = []
    @keyframes = []
    @issue_scss = ''

    tree.children.each do |node|
      case node
      when Sass::Tree::DirectiveNode
        case node.name
        when '@font-face'
          @fonts << node.to_scss
        when '@keyframes'
          @keyframes << node.to_scss
        else
          scss = node.to_scss
          scss.gsub!(/^/, '  ')
          @issue_scss << scss
        end
      else
        scss = node.to_scss
        scss.gsub!(/^/, '  ')
        @issue_scss << scss
      end
    end
  end
end
