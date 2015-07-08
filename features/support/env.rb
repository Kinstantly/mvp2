# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a 
# newer version of cucumber-rails. Consider adding your own code to a new file 
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

# IMPORTANT: If you regenerate this file, then you'll need to reintegrate spork.
# Run the following command and then move all the cucumber stuff into the Spork.prefork block.
#   bundle exec spork cucumber --bootstrap

require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # Delay loading of routes, Devise, and the User model!
  require 'rails/application'
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  require 'cucumber/rails'
  
  # RSpec’s supported mocking frameworks (RSpec, Mocha, RR, Flexmock).
  require 'cucumber/rspec/doubles'

  # Mocks of Gibbon, a wrapper for the MailChimp API.
  require File.expand_path('../../../spec/support/mailing_list_helpers', __FILE__)

  # Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
  # order to ease the transition to Capybara we set the default here. If you'd
  # prefer to use XPath just remove this line and adjust any selectors in your
  # steps to use the XPath syntax.
  Capybara.default_selector = :css

  # The capybara-webkit driver is for true headless testing.
  # It uses QtWebKit to start a rendering engine process.
  # It can execute JavaScript as well.
  # It is significantly faster than drivers like Selenium since it does not load an entire browser.
  Capybara.javascript_driver = :webkit

  # http://rubydoc.info/github/jnicklas/capybara/#Asynchronous_JavaScript__Ajax_and_friends_
  # When working with asynchronous JavaScript, you might come across situations where
  # you are attempting to interact with an element which is not yet present on the page.
  # Capybara automatically deals with this by waiting for elements to appear on the page.
  # You can adjust how long this period is (the default is 2 seconds):
  Capybara.default_wait_time = 5

  # Capybara Webkit configuration: https://github.com/thoughtbot/capybara-webkit#configuration
  Capybara::Webkit.configure do |config|
    # By default, requests to outside domains (anything besides localhost) will
    # result in a warning. Several methods allow you to change this behavior.

    # Edward tried to allow and block specific URLs, but that caused scenarios to fail randomly or webkit to hang.
    # So let's just allow all URLs.  Too bad.
    config.allow_unknown_urls
  end

  # By default, any exception happening in your Rails application will bubble up
  # to Cucumber so that your scenario will fail. This is a different from how 
  # your application behaves in the production environment, where an error page will 
  # be rendered instead.
  #
  # Sometimes we want to override this default behaviour and allow Rails to rescue
  # exceptions and display an error page (just like when the app is running in production).
  # Typical scenarios where you want to do this is when you test your error pages.
  # There are two ways to allow Rails to rescue exceptions:
  #
  # 1) Tag your scenario (or feature) with @allow-rescue
  #
  # 2) Set the value below to true. Beware that doing this globally is not
  # recommended as it will mask a lot of errors for you!
  #
  ActionController::Base.allow_rescue = false

  # Remove/comment out the lines below if your app doesn't have a database.
  # For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
  begin
    DatabaseCleaner.strategy = :transaction
  rescue NameError
    raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
  end

  # You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
  # See the DatabaseCleaner documentation for details. Example:
  #
  #   Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
  #     # { :except => [:widgets] } may not do what you expect here
  #     # as tCucumber::Rails::Database.javascript_strategy overrides
  #     # this setting.
  #     DatabaseCleaner.strategy = :truncation
  #   end
  #
  #   Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity', '~@javascript') do
  #     DatabaseCleaner.strategy = :transaction
  #   end
  #

  # Possible values are :truncation and :transaction
  # The :transaction strategy is faster, but might give you threading problems.
  # See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
  Cucumber::Rails::Database.javascript_strategy = :truncation

  # Make sure the search index is clean before running a search scenario.
  Before('@search') do
    Sunspot.remove_all!
  end

  Before do
    set_up_gibbon_mocks
  end

  # Scenarios for describing behavior while running as a private site.
  Around('@private_site') do |scenario, block|
    previous_state = Rails.configuration.running_as_private_site
    Rails.configuration.running_as_private_site = true
    block.call
    Rails.configuration.running_as_private_site = previous_state
  end

  # Desperate work-around webkit hanging.
  After do
    sleep 0.2
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

