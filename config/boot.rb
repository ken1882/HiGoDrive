ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# Path on local machine that contains key files
PRECONFIG_PATH = ["#{ENV['HOME']}/RoR"]
KEYFILE_MAP = {
  'mongoid'       => 'MONGODB_URI',
  'master'        => 'SECRET_KEY_BASE',
  'vapid_public'  => 'VAPID_PUBLIC_KEY',
  'vapid_private' => 'VAPID_PRIVATE_KEY',
  'postmark'      => 'POSTMARK_TOKEN',
  'smtp'          => 'SMTP_SETTING'
}

PRECONFIG_PATH.each do |path|
  next unless File.exist?("#{path}/mongoid.key")
  KEYFILE_MAP.each do |fname, val|
    File.open("#{path}/#{fname}.key", 'r') do |file|
      ENV[val] ||= file.read.chomp
    end
  end
end

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.

BEGIN{
  SPLIT_LINE = '-' * 21 + 10.chr
}