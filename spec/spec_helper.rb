# -*- encoding : utf-8 -*-
require 'bundler'
Bundler.setup
ENV['RACK_ENV'] = ENV['RAILS_ENV'] = 'test'
GEM_ROOT = Pathname.new(File.expand_path('../..', __FILE__))

require 'rspec'
