ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
require_relative '../lib/modules/util'

BEGIN{
  SPLIT_LINE = '-' * 21 + 10.chr
}