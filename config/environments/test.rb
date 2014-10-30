Mvp2::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

	# Needed for testing email, e.g., from rspec.
	config.action_mailer.default_url_options = { :host => config.default_host }

  # Paperclip config
  config.paperclip_defaults = {
    :url => '/:attachment/:id/:filename'
    #:path => ':rails_root/public:url' #default paperclip path
  }

  # Wrapper for MailChimp API
  Gibbon::API.api_key = '1c6c41452463d27bc7b25aeb37de5133-us9'
  config.mailchimp_list_id = '96b4018f42'
end

REINDEX_PROFILES_IN_BACKGROUND = false
