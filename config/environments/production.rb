Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  
  # Fallback host name used in URLs, etc.
  config.default_host = ENV['DEFAULT_HOST'].presence || 'www.kinstantly.com'
  
  # Sitemap generator configuration.
  config.sitemap_default_host = "https://#{config.default_host}/"
  config.sitemap_sitemaps_path = ''

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  # config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # serve_static_files = true is needed to run Rails 4 on Heroku and is set by the rails_12factor gem.
  # https://devcenter.heroku.com/articles/rails-4-asset-pipeline
  config.serve_static_files = true
  config.static_cache_control = 'public, max-age=31536000'

  # Compress JavaScripts and CSS.
  config.assets.compress = true
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Set to :debug to see everything in the log.
  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store
  #
  # Dalli is a better inferface to memcached.
  # Configure to use the Memcached Cloud add-on on Heroku.
  # Note: config variables not available during slug compilation on Heroku, so handle nil gracefully.
  #       https://devcenter.heroku.com/articles/rails-asset-pipeline#compiling-assets-during-slug-compilation
  config.cache_store = :dalli_store, ENV['MEMCACHEDCLOUD_SERVERS'].try(:split, ','), { username: ENV['MEMCACHEDCLOUD_USERNAME'], password: ENV['MEMCACHEDCLOUD_PASSWORD'] }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'
  config.action_controller.asset_host = ENV['ASSET_HOST']

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Configure ActionMailer for heroku -> sendgrid.
  config.action_mailer.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com'
  }
  config.action_mailer.delivery_method = :smtp

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

	# Devise needs this for its email.
	config.action_mailer.default_url_options = { :host => config.default_host }

  # Paperclip config for S3.
  config.paperclip_defaults = {
    :storage => :s3,
    :path => 'images/profiles/:hash.:extension',
    :s3_host_alias => config.cloudfront_domain_name,
    :url => ':s3_alias_url',
    :default_url => "profile-photo-placeholder.jpg",
    :hash_secret => ENV['PAPERCLIP_HASH_SECRET'],
    :hash_data => ":attachment/:id_partition/:style/:filename",
    :s3_protocol => 'https',
    :s3_permissions => :public_read,
    :s3_credentials => {
      :bucket => ENV['PAPERCLIP_AWS_BUCKET'],
      :access_key_id => ENV['PAPERCLIP_AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['PAPERCLIP_AWS_SECRET_ACCESS_KEY']
    }
  }

  # Wrapper for MailChimp API
  Gibbon::API.api_key = ENV['MAILCHIMP_API_KEY']
  config.mailing_lists[:mailchimp_list_ids] = {
    :parent_marketing_emails => ENV['PARENT_MARKETING_EMAILS_LIST_ID'],
    :parent_newsletters => ENV['PARENT_NEWSLETTERS_LIST_ID'],
    :parent_newsletters_stage1 => ENV['PARENT_NEWSLETTERS_STAGE1_ID'],
    :parent_newsletters_stage2 => ENV['PARENT_NEWSLETTERS_STAGE2_ID'],
    :parent_newsletters_stage3 => ENV['PARENT_NEWSLETTERS_STAGE3_ID'],
    :provider_marketing_emails => ENV['PROVIDER_MARKETING_EMAILS_LIST_ID'],
    :provider_newsletters => ENV['PROVIDER_NEWSLETTERS_LIST_ID']
  }
  
  config.mailing_lists[:update_in_background] = true
end

REINDEX_PROFILES_IN_BACKGROUND = true

