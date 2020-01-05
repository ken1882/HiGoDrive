require_relative 'boot'

require 'digest'
require 'net/http'
require 'open-uri'
require 'ostruct'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

Bundler.require(*Rails.groups)

module GuaneiArk
  class Application < Rails::Application

    config.mongoid.logger = Logger.new($stdout, :warn)

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Disable precompile in order to run on heroku
    config.assets.initialize_on_precompile = false
    config.assets.compile = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.after_initialize do
      puts "#{SPLIT_LINE}Pre-init"
      Task.setup
      Rails.application.eager_load! if Rails.production?
      Mongoid.raise_not_found_error = false
      puts "Rail server started! (#{Rails.env})\n#{SPLIT_LINE}"
    end
    #------------------------------------------------------------------------------
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins /\Ahttp:\/\/localhost:\d+/
        resource '/api/*', headers: :any, methods: [:get, :post, :options]
      end
    end
    #------------------------------------------------------------------------------
  end
end
