ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

ENV['SECRET_KEY_BASE'] ||= (File.open("config/master.key", 'r'){|f| f.read} rescue nil)
ENV['MONGODB_URI'] ||= (File.open("config/mongoid.key", 'r'){|f| f.read} rescue nil)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
require_relative '../lib/modules/util'

BEGIN{
  SPLIT_LINE = '-' * 21 + 10.chr
}