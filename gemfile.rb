# helper to include gems that Spring depends upon into your Gemfile
#
# $ cat Gemfile
# require_relative File.join(File.dirname(__FILE__), 'lib', 'spring', 'gemfile')
# eval(Spring.gemfile, binding)
#
module Spring
  def self.gemfile options={}
    gemfile = File.join(File.dirname(__FILE__), 'Gemfile')

    gems = IO.read(gemfile)

    gems.sub!(/^source.+/, '')
    gems.sub!(/^ruby.+/, '')

    if options['exclude']
      pattern = /^.+["'](#{Array(options['exclude']).join('|')})["'].*$/
      gems.gsub!(pattern, '')
    end

    gems
  end
end
