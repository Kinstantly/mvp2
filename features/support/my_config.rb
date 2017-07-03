# Modifications to the default cucumber configuration.
# Try to keep env.rb as it was created by 'rails generate cucumber:install'.

# RSpec’s supported mocking frameworks (RSpec, Mocha, RR, Flexmock).
require 'cucumber/rspec/doubles'

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
Capybara.default_max_wait_time = 10

# Capybara Webkit configuration: https://github.com/thoughtbot/capybara-webkit#configuration
Capybara::Webkit.configure do |config|
	# By default, requests to outside domains (anything besides localhost) will
	# result in a warning. Several methods allow you to change this behavior.

	# Edward tried to allow and block specific URLs, but that caused scenarios to fail randomly or webkit to hang.
	# So let's just allow all URLs.  Too bad.
	config.allow_unknown_urls
end

# Cucumber/Capybara doesn't really work with redirecting to an offsite page.
# So test with a local page; specifying the path is sufficient.
Rails.configuration.provider_registration_preconfirmation_page = '/member/awaiting_confirmation'

# Make sure the search index is clean before running a search scenario.
Before('@search') do
	Sunspot.remove_all!
end

Before do
	# MailChimp API mocks
	set_up_gibbon_mocks unless ENV['CONTACT_MAILCHIMP'].present?
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

