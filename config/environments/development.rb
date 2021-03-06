Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

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
  
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Do not compress assets
  config.assets.compress = false

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

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
    :hash_secret => 'b3d7280f61cbeef18975fc5ba14795974e4b38acf76585ba37c296aceb37cd928c2ead29e362f121fee0e4717e8d60ace5d5152c50799301c7027afd4ba2bfc7',
    :hash_data => ":attachment/:id_partition/:style/:filename",
    :s3_protocol => 'https',
    :s3_permissions => :public_read,
    :s3_credentials => {
      :access_key_id => ENV['PAPERCLIP_AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['PAPERCLIP_AWS_SECRET_ACCESS_KEY']
    }
  }

  # Wrapper for MailChimp API
  Gibbon::Request.api_key = ENV['MAILCHIMP_API_KEY']
  config.mailing_lists[:mailchimp_list_ids] = {
    :parent_marketing_emails => '46eeff8675',
    :parent_newsletters => '7030e9d15b',
    :parent_newsletters_stage1 => '0ffd57085c',
    :parent_newsletters_stage2 => '0859eacd38',
    :parent_newsletters_stage3 => 'f0cbd23bb0',
    :provider_marketing_emails => '17cb397f2a',
    :provider_newsletters => 'ef9518f95a'
  }
  config.mailing_lists[:mailchimp_folder_ids] = {
    :parent_newsletters_source_campaigns => '24a1040a6b',
    :parent_newsletters_campaigns => 'c028bc23cb'
  }
  Delayed::Worker.logger = Rails.logger
end

REINDEX_PROFILES_IN_BACKGROUND = true

Kaminari.configure do |config|
	config.default_per_page = 10
end
