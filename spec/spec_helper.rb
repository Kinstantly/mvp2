# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# require 'rspec/autorun'
require 'rspec/collection_matchers' # Should only be using this for error_on and errors_on.
require 'capybara/rspec'
require 'email_spec'
require 'paperclip/matchers'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|

  config.include SiteConfigurationHelpers

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  
  # rspec-rails 3 no longer automatically infers an example group's spec type from the file location.
  # Explicitly opt-in to this feature.
  config.infer_spec_type_from_file_location!
  
  config.include Paperclip::Shoulda::Matchers

  # Examples that we don't want to run by default should have this tag.
  # To run them, use "--no-drb --tag excluded_by_default" on the command line.
  config.filter_run_excluding excluded_by_default: true

  # To reset your application database to a pristine state during testing.
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end
  config.before(:example) do
    DatabaseCleaner.start
  end
  config.after(:example) do
    DatabaseCleaner.clean
  end

  # Mocks for the MailChimp API via Gibbon.
  config.before(:example) do |example|
    if example.metadata[:use_gibbon_mocks] or
      !(example.metadata[:contact_mailchimp] or ENV['CONTACT_MAILCHIMP'].present?)
      set_up_gibbon_mocks
    elsif example.metadata[:mailchimp]
      # Not using mocks.
      empty_campaign_folders # Prevent build-up of test data in our MailChimp account.
    end
  end

  # Specs for describing behavior while running as a private site.
  config.around(:example, private_site: true) do |example|
    previous_state = Rails.configuration.running_as_private_site
    Rails.configuration.running_as_private_site = true
    # Object.send(:remove_const, 'User')
    # load 'user.rb'
    example.run
    Rails.configuration.running_as_private_site = previous_state
    # Object.send(:remove_const, 'User')
    # load 'user.rb'
  end
  
  # Hacky hack: On Mac OS X 10.11, RSpec is really hitting the CPU hard and
  # literally making it hot!  Allow time to cool down between examples.
  if ENV['RSPEC_THROTTLE_INTERVAL'].to_f > 0
    puts "Throttle specified: sleep #{ENV['RSPEC_THROTTLE_INTERVAL'].to_f} seconds between each example."
    config.after(:example) do
      sleep ENV['RSPEC_THROTTLE_INTERVAL'].to_f
    end
  end
end
