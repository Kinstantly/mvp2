# This file is copied to spec/ when you run 'rails generate rspec:install'

# IMPORTANT: If you regenerate this file, then you'll need to reintegrate spork.
# Run the following command and then move all the rspec stuff into the Spork.prefork block.
#   bundle exec spork rspec --bootstrap

require 'rubygems'
require 'spork'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] ||= 'test'

  # Delay loading of routes, Devise, and the User model!
  require 'rails/application'
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

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
      set_up_gibbon_mocks unless example.metadata[:contact_mailchimp]
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
  end

  # End of Spork.prefork
end

Spork.each_run do
  # This code will be run each time you run your specs.

  FactoryGirl.reload
  I18n.backend.reload!
end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.
