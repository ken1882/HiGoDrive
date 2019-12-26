ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# Path on local machine that contains key files
PRECONFIG_PATH = ["#{ENV['HOME']}/RoR"]
PRECONFIG_PATH.each do |path|
  next unless File.exist?("#{path}/mongoid.key")
  File.open("#{path}/mongoid.key", 'r'){|f| ENV['MONGODB_URI'] ||= f.read.chomp}
  File.open("#{path}/master.key", 'r'){|f| ENV['SECRET_KEY_BASE'] ||= f.read.chomp}
  File.open("#{path}/vapid_public.key", 'r'){|f| ENV['VAPID_PUBLIC_KEY'] ||= f.read.chomp}
  File.open("#{path}/vapid_private.key", 'r'){|f| ENV['VAPID_PRIVATE_KEY'] ||= f.read.chomp}
  File.open("#{path}/postmark.key", 'r'){|f| ENV['POSTMARK_TOKEN'] ||= f.read.chomp}
end

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.

BEGIN{
  SPLIT_LINE = '-' * 21 + 10.chr
}