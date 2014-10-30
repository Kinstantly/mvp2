Mvp2::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports.
  config.consider_all_requests_local       = true

  if ENV['PERFORM_CACHING'].present?
    # Enable caching.
    config.action_controller.perform_caching = true
    
    # Better interface to memcached.
    config.cache_store = :dalli_store
  else
    # Disable caching.
    config.action_controller.perform_caching = false
  end
  
  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

	# Devise needs this for its email.
	config.action_mailer.default_url_options = { :host => config.default_host }

  # Configure ActionMailer for smtp.
  # By default, puts the email in the log file.
  # Will attempt delivery via gmail if you set SMTP_USER_NAME and SMTP_PASSWORD in your environment.
  # If you want to send through another gateway, set the appropriate environment variables (see below).
  if ENV['SMTP_USER_NAME'].present? and ENV['SMTP_PASSWORD'].present?
    config.action_mailer.smtp_settings = {
      :address        => (ENV['SMTP_ADDRESS'].presence || 'smtp.gmail.com'),
      :port           => (ENV['SMTP_PORT'].presence || '587'),
      :authentication => (ENV['SMTP_AUTHENTICATION'].try(:to_sym) || :plain),
      :user_name      => ENV['SMTP_USER_NAME'],
      :password       => ENV['SMTP_PASSWORD']
    }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.raise_delivery_errors = true
  end

  # Paperclip config.
  config.paperclip_defaults = {
    #:url => '/:class/:attachment/:id_partition/:filename',
	  #:path => ':rails_root/public:url', #default paperclip path
    #S3 config. Comment out for local storage.
    :storage => :s3,
    :path => 'images/profiles/:hash.:extension',
    :bucket => 'kinstantly-assets-development',
    #:bucket => 'assets.kinstantly-develop.com',
    #:s3_host_alias => 'assets.kinstantly-develop.com',
    :s3_host_alias => config.cloudfront_domain_name,
    :url => ':s3_alias_url',
    #:url => ":s3_domain_url",
    :hash_secret => 'DLJsk1RTbt2ybEsDx5ib71mRJPBRmeJ/+vxAun3zZS+3v8Dctd+jUP3IfgVNdmhXaIGguuM74ucCRiiXTg7jhg==',
    :hash_data => ":attachment/:id_partition/:style/:filename",
    :s3_protocol => 'https',
    :s3_permissions => :public_read,
    :s3_credentials => {
      :access_key_id => 'AKIAICTCJIOBR3CFCHBQ',
      :secret_access_key => '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'
    }
  }

  # Wrapper for MailChimp API
  Gibbon::API.api_key = '924cc5a82c5f67ecc397bd1d4fcb7236-us9'
  config.mailchimp_list_id = '240b02592e'
end

REINDEX_PROFILES_IN_BACKGROUND = true

Kaminari.configure do |config|
	config.default_per_page = 10
end
