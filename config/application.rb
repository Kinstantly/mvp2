require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

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
		config.i18n.enforce_available_locales = true

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # I guess assets added by Devise necessitate this work-around for asset precompilation on Heroku.
    # Force your application to not access the DB or load models when precompiling your assets.
    # See https://devcenter.heroku.com/articles/rails3x-asset-pipeline-cedar#troubleshooting
    config.assets.initialize_on_precompile = false

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
  end
end

DEFAULT_REGION = 'CA'
DEFAULT_COUNTRY_CODE = 'US'
MAILER_DEFAULT_FROM = 'Kinstantly <support@kinstantly.com>'
MAILER_DEFAULT_REPLY_TO = 'Kinstantly <support@kinstantly.com>'
MAILER_DEFAULT_BCC = 'monitor@kinstantly.com'
Phonie::Phone.default_country_code = '1'
ADMIN_EMAIL = 'admin@kinstantly.com'
REVIEW_MODERATOR_EMAIL = 'admin@kinstantly.com'
PROFILE_MODERATOR_EMAIL = 'profile_monitor@kinstantly.com'
SUPPORT_EMAIL = 'support@kinstantly.com'
SEARCH_DEFAULT_PER_PAGE = ENV['SEARCH_DEFAULT_PER_PAGE'].presence || 20
PaperTrail.config.version_limit = 20
GOOGLE_BROWSER_API_KEY = 'AIzaSyAcg1gF_tDu3I3qOnYDLD8KUkvnAPXYVow'
FB_API_KEY = '876267945721057'
