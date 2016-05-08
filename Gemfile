source 'https://rubygems.org'

ruby '2.3.0'

gem 'rails', '3.2.22.2'
# gem 'rails', '4.0.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Put nokogiri before other gems that use libxml (like pg).
# http://stackoverflow.com/a/15492096/1203206
# http://stackoverflow.com/a/16943050/1203206
gem 'nokogiri'

# Abort requests that are taking too long; a subclass of Timeout::Error is raised.
gem 'rack-timeout'

# json 1.7.7 has a bug fix: CVE-2013-0269
gem 'json', '>= 1.7.7'

# Make heroku happy.  They only support postgresql.
# gem 'sqlite3', :group => :development
gem 'pg'

gem 'haml'

# html2haml loads ruby_parser which requires tons of memory.
# Only needed in development from the command line.  Install it manually!
# gem 'html2haml', group: :development

# Get error message helpers for forms.
gem 'dynamic_form'

# Dynamic add and remove links for nested models.
gem 'nested_form'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'#,   '~> 3.2.3'
  gem 'coffee-rails'#, '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

	# http://github.com/lautis/uglifier
  gem 'uglifier'#, '>= 1.0.3'
end

# Has jquery and jquery_ujs.
gem 'jquery-rails'
# Has jquery-ui (jquery-rails >= 3.0.0 no longer includes jquery-ui).
gem 'jquery-ui-rails'

# HAML 4 includes coffeescript support.
# gem 'coffee-filter'

# ruby-prof is a fast code profiler for Ruby
gem 'ruby-prof'

# Authentication based on Warden.
gem 'devise'

# Two factor authentication for Devise.
# https://github.com/Houdini/two_factor_authentication
gem 'two_factor_authentication'

# Generates a QR code from a URI, I hope.
# https://github.com/samvincent/rqrcode-rails3
gem 'rqrcode-rails3'

# Authorization library.
# https://github.com/CanCanCommunity/cancancan
gem 'cancancan'

# Sitemap generation and search engine pinging.
# Can upload sitemaps to AWS S3 (see below).
gem 'sitemap_generator', '~> 5.1'

# Fog gives sitemap_generator access to AWS S3.
# The fog gem is a memory hog.  So use fog-aws instead.
gem 'fog-aws'

# Search with the Solr search engine.
# gem 'sunspot_rails', '~> 2.0.0.pre'
git 'git://github.com/edsimpson/sunspot.git', tag: 'v2.0.0.pre.130115' do
	gem 'sunspot'
	gem 'sunspot_rails'
end

# Show progress on the console of long-running tasks.
gem 'progress_bar'

# Generates various types of UUIDs.  It conforms to RFC 4122 whenever possible.
gem 'uuidtools'

# Integration of jQuery UI Autocomplete Widget for Rails 3.2 and above.
# https://github.com/bigtunacan/rails-jquery-autocomplete
gem 'rails-jquery-autocomplete'

# A repository of geographic regions for Ruby via Rails.
# https://github.com/jim/carmen-rails
gem 'carmen-rails'

# Parse and print phone numbers.  International support.
gem 'phonie'

# Geocoding (by street or IP address), reverse geocoding (find street address based on given coordinates), and distance queries.
gem 'geocoder'

# Use to safely create links from user input.
# http://github.com/tenderlove/rails_autolink
gem 'rails_autolink'

# Pagination.
gem 'kaminari'

# Form helpers
gem 'simple_form'

# Background processing
# http://github.com/collectiveidea/delayed_job_active_record
gem 'delayed_job_active_record'

# Support multiple simultaneous requests by forking multiple rails processes.
gem 'unicorn'

# PaperTrail lets you track changes to your models' data. It's good for auditing or versioning.
# You can see how a model looked at any stage in its lifecycle, revert it to any version, and
# even undelete it after it's been destroyed.
# https://github.com/airblade/paper_trail
gem 'paper_trail'

# AutoStripAttributes helps to remove unnecessary whitespace from ActiveRecord or ActiveModel attributes.
# It's good for removing accidental spaces from user inputs
# (e.g. when user copy/pastes some value to a form and the value has extra spaces at the end).
gem 'auto_strip_attributes'

# Test::Unit is no longer included in the Ruby distribution.
# 'rails console' needs this, so it needs to be installed on production.
gem 'test-unit', '~> 3.0'

group :development, :test do
	gem 'rspec-rails', '~> 3.3'
	gem 'rspec-collection_matchers'
	# https://cucumber.io/docs/reference/rails
	gem 'cucumber-rails', require: false
	# https://github.com/DatabaseCleaner/database_cleaner
	gem 'database_cleaner'
	# gem 'webrat', '~> 0.7'
	gem 'factory_girl_rails', '~> 4.1'
	gem 'email_spec', '~> 1.4'
	# https://github.com/jnicklas/capybara
	gem 'capybara'
	# https://github.com/thoughtbot/capybara-webkit
	# https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit
	# Qt 5.5 is the last version of Qt that capybara-webkit will support.
	# The Qt project has dropped the WebKit bindings from binary releases in 5.6.
	gem 'capybara-webkit'
	gem 'launchy', '~> 2.1'
	gem 'syntax'
	# gem 'sunspot_solr', '~> 2.0.0.pre' # optional pre-packaged Solr distribution for use in development
	git 'git://github.com/edsimpson/sunspot.git' do
		gem 'sunspot_solr'
	end
end

# Benchmarking.
group :development do
	gem 'derailed'
	gem 'stackprof'
	# https://github.com/josevalim/rails-footnotes
	gem 'rails-footnotes', '~> 4.0'
end

#Image processor and model manager for photo uploads
# We really want the following, but it uses too much memory.  See below.
# gem 'paperclip', '~> 4.3'

# The following includes a fix for CVE-2015-2963 and a fix for memory over usage.
# https://github.com/thoughtbot/paperclip/pull/1888/commits
gem 'paperclip', git: 'https://github.com/dgynn/paperclip.git', branch: 'interpolations_tuning'

#S3 storage
gem 'aws-sdk', '~> 1.6'

# AJAX file uploader
# https://github.com/thoughtbot/jack_up
gem 'jack_up'
# Required for Jack_up
# https://github.com/rweng/underscore-rails
gem 'underscore-rails'
# Required for Jack_up
# https://github.com/newbamboo/rack-raw-upload
gem 'rack-raw-upload'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Deploy with Capistrano
# gem 'capistrano'

# Dalli is a better inferface to memcached.
# https://github.com/mperham/dalli
gem 'dalli'

# Detects changes to templates when caching is being used.
# Note: available by default in Rails 4.
# https://github.com/rails/cache_digests
gem 'cache_digests'

# The byebug debugger.
# Example: bundle exec rails server --port=5000
# http://github.com/deivid-rodriguez/byebug
gem 'byebug', group: :development

# Makes running your Rails app easier. Based on the ideas behind 12factor.net
# https://github.com/heroku/rails_12factor
gem 'rails_12factor', group: :production

#Support for ReCAPTCHA's Mailhide API
gem 'recaptcha-mailhide'

# Custom categories and filters for Sendgrid
gem 'sendgrid'

# Cron jobs
gem 'whenever', :require => false

# Stripe Connect
gem 'omniauth-stripe-connect', :git => 'https://github.com/isaacsanders/omniauth-stripe-connect.git'
gem 'stripe_event'

# Money! https://github.com/RubyMoney
gem 'money-rails'

# Mailchimp API wrapper
# http://github.com/amro/gibbon
gem "gibbon"

# Prep for migration to Rails 4.
# Remove this when migrated to Rails 4 because it is built in.
# https://github.com/rails/strong_parameters
gem 'strong_parameters'

# Rack middleware for blocking & throttling abusive requests.
# https://github.com/kickstarter/rack-attack
gem 'rack-attack'
