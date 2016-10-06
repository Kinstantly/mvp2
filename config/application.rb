require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mvp2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    
    # Fallback host name used in URLs, etc.
    config.default_host = 'localhost:5000'
    
    # If true, we are running a private site.
    config.running_as_private_site = ENV['RUNNING_AS_PRIVATE_SITE'].present?
    
    # Query-string parameter placed in URLs to aid in tracking the profile-claiming funnel.
    config.claim_profile_tracking_parameter = {claim_profile: 't'}
    
    # Provider sell page.
    config.provider_sell_url = ENV['PROVIDER_SELL_URL'].presence || 'http://lp.kinstantly.com/pro/'
    
    # Where to send a provider just after they register but before they confirm their email address.
    # This page should contain instructions for confirming their registration, e.g., check their email.
    config.provider_registration_preconfirmation_url = ENV['PROVIDER_REGISTRATION_PRECONFIRMATION_URL'].presence || 'http://lp.kinstantly.com/pro-thanks'
    
    # Stripe configuration (payment gateway).
    # If stripe[:live_mode] is true, we should only process Stripe events that have livemode == true.
    config.stripe = {
      publishable_key:    ENV['STRIPE_PUBLISHABLE_KEY'].presence || 'pk_test_9m9Wy7Yc81OU2NZxELrPVbch',
      secret_key:         ENV['STRIPE_SECRET_KEY'].presence || 'sk_test_AAv7llm8N32E7HErvRqgvjm6',
      connect_client_id:  ENV['STRIPE_CONNECT_CLIENT_ID'].presence || 'ca_4aJhcyjprTFSJzhMA0NmuzWUIJiznZAb',
      live_mode:          ENV['STRIPE_LIVE_MODE'].present?,
      dashboard_url:      'https://dashboard.stripe.com/'
    }
    
    # Payment configuration that is not gateway dependent.
    config.payment = {
      application_fee_percentage: ENV['PAYMENT_APPLICATION_FEE_PERCENTAGE'].presence.try(:to_f)
    }
    
    # Mailing list management parameters.
    config.mailing_lists = {
      mailchimp_list_ids: {}, # Configured in each environment.
      active_lists: [:parent_newsletters, :provider_newsletters],
      update_in_background: ENV['UPDATE_MAILING_LISTS_IN_BACKGROUND'].present?,
      send_mailchimp_welcome: ENV['SEND_MAILCHIMP_WELCOME'].present?
    }
    
    # Input date format that is displayed to the user. It should conform to input_date_regexp_string.
    config.input_date_format_string = 'MM/DD/YYYY'
    # Regexp string used to enforce the format of a date input by a user.
    config.input_date_regexp_string = '(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/(19|20)[0-9][0-9]'
    # Regexp used to enforce ISO 8601 date format.
    config.iso_date_regexp = /\A(19|20)[0-9][0-9]-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])\z/
    
    # Sitemap generator configuration.
    config.sitemap_default_host = "http://#{config.default_host}/"
    config.sitemap_sitemaps_path = 'sitemaps_dev/'
    
    # Blog location.
    config.blog_host = 'blog.kinstantly.com'
    config.blog_url = "http://#{config.blog_host}/"

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/app/models/announcement)


    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'America/Los_Angeles'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Ensure requested locales are available.  Raises I18n::InvalidLocale if not available.
    # A security measure, to ensure user input cannot be used as locale information unless it is previously known.
    # It's recommended not to disable this option unless you have a strong reason for doing so.
    config.i18n.enforce_available_locales = true

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation, :otp_code]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Force your application to not access the DB or load models when precompiling your assets.
    # See https://devcenter.heroku.com/articles/rails3x-asset-pipeline-cedar#troubleshooting
    # In Rails 4.x this option has been removed and is no longer needed.
    # See https://devcenter.heroku.com/articles/rails-asset-pipeline#troubleshooting
    # config.assets.initialize_on_precompile = false

    # Default cache store.
    config.cache_store = :memory_store

    # We’re using Cucumber scenarios (integration tests) so unit tests of helpers and views are redundant.
    # Tell the Rails generator to not create Rspec test templates for helpers and views.
    config.generators do |g|
      g.view_specs false
      g.helper_specs false
    end

    config.middleware.use 'Rack::RawUpload'

    # Compress responses.
    # Ensure etag is calculated and conditional-get is assessed *before* compression is done.
    config.middleware.insert_before Rack::ConditionalGet, Rack::Deflater

    config.cloudfront_domain_name = ENV['CLOUDFRONT_DOMAIN_NAME'].presence || 'd3nqozpn39ttwm.cloudfront.net'

    # Wrapper for MailChimp API.
    # API key and list ID settings are in the development, test, and production configuration files.
    Gibbon::API.timeout = ENV['MAILCHIMP_API_TIMEOUT'].presence || 20
    config.mailchimp_webhook_security_token = ENV['MAILCHIMP_WEBHOOK_SECURITY_TOKEN'].presence || '115654367fbf29d8358a58d98850c666'

    # Token used to authorize a JSON sign-in attempt.
    config.sign_in_auth_token = '7d04d7c4baa559fc49c03fe5fd8dd3c5'

    # Google Analytics Tracking ID. Default ID is for development/local.kinstantly.com.
    config.google_analytics_tracking_id = ENV['GOOGLE_ANALYTICS_TRACKING_ID'].presence || 'UA-49348780-4'
    
    # For blocking & throttling abusive requests. See config/initializers/rack_attack.rb.
    config.middleware.use Rack::Attack
    
    # Cross-Origin Resource Sharing (CORS).
    # Needed to serve assets from a CDN (CloudFront), in particular, fonts.
    # https://github.com/cyu/rack-cors
    # https://www.w3.org/TR/cors/
    # https://en.wikipedia.org/wiki/Cross-origin_resource_sharing
    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :head]
      end
    end
  end
end

DEFAULT_REGION = 'CA'
DEFAULT_COUNTRY_CODE = 'US'
MAILER_DEFAULT_FROM = 'Kinstantly <support@kinstantly.com>'
MAILER_DEFAULT_REPLY_TO = 'Kinstantly <support@kinstantly.com>'
MAILER_DEFAULT_BCC = 'monitor@kinstantly.com'
Phonie.configuration.default_country_code = '1'
ADMIN_EMAIL = 'admin@kinstantly.com'
REVIEW_MODERATOR_EMAIL = 'admin@kinstantly.com'
PROFILE_MODERATOR_EMAIL = 'profile_monitor@kinstantly.com'
SUPPORT_EMAIL = 'support@kinstantly.com'
SEARCH_DEFAULT_PER_PAGE = ENV['SEARCH_DEFAULT_PER_PAGE'].presence || 20
PaperTrail.config.version_limit = 20
GOOGLE_BROWSER_API_KEY = 'AIzaSyAcg1gF_tDu3I3qOnYDLD8KUkvnAPXYVow'
FB_API_KEY = '876267945721057'
