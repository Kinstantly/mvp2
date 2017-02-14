Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The proper default is implemented with Rails 4.2.
  # If not set, then it is effectively true only if cache_classes and eager_load are both true.
  # Caybara should NOT be allowed to make concurrent requests to a multi-threaded web server, e.g., webkit.
  # Operations that are not threadsafe can cause the test to fail incorrectly.
  # https://robots.thoughtbot.com/how-to-fix-circular-dependency-errors-in-rails-integration-tests
  # https://github.com/rails/rails/commit/112077c255879351edf4530791cc4bcc7bd4005b
  # config.allow_concurrency = false

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static file server for tests with Cache-Control for performance.
  config.serve_static_files   = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Randomize the order test cases are executed.
  config.active_support.test_order = :random # or `:sorted` if you prefer

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

	# Needed for testing email, e.g., from rspec.
	config.action_mailer.default_url_options = { :host => config.default_host }

  # Paperclip config
  config.paperclip_defaults = {
    :url => '/:attachment/:id/:filename'
    #:path => ':rails_root/public:url' #default paperclip path
  }

  # Wrapper for MailChimp API
  Gibbon::Request.api_key = '1c6c41452463d27bc7b25aeb37de5133-us9'
  config.mailing_lists[:mailchimp_list_ids] = {
    :parent_marketing_emails => '24517534db',
    :parent_newsletters => '1575880c9b',
    :parent_newsletters_stage1 => '5b35d2d5db',
    :parent_newsletters_stage2 => '3142e58c78',
    :parent_newsletters_stage3 => '38d9a88031',
    :provider_marketing_emails => 'acc03566ad',
    :provider_newsletters => '64efed04f6'
  }
  config.mailing_lists[:mailchimp_folder_ids] = {
    :parent_newsletters_source_campaigns => 'dc18c4f0ad',
    :parent_newsletters_campaigns => 'b8618a7fda'
  }
end

REINDEX_PROFILES_IN_BACKGROUND = false
