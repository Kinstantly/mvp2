source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '3.2.21'

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
gem 'html2haml'

# Get error message helpers for forms.
gem 'dynamic_form'

# Dynamic add and remove links for nested models.
gem 'nested_form'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

# Has jquery, jquery_ujs, and jquery-ui.
gem 'jquery-rails'

# HAML 4 includes coffeescript support.
# gem 'coffee-filter'

# ruby-prof is a fast code profiler for Ruby
gem 'ruby-prof'

# Authentication based on Warden.
gem 'devise'

# Authorization library.
gem 'cancan'

# Sitemap generation and search engine pinging.
# Can upload sitemaps to AWS S3 (see below).
gem 'sitemap_generator', '~> 5.0.0'

# AWS S3 access.
gem 'fog'

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

# Rails integration of jQuery UI Autocomplete Widget.
gem 'rails3-jquery-autocomplete' # , github: 'edsimpson/rails3-jquery-autocomplete'

# A repository of geographic regions for Ruby via Rails.
gem 'carmen-rails', '~> 1.0.0.beta3'

# Parse and print phone numbers.  International support.
gem 'phonie'

# Geocoding (by street or IP address), reverse geocoding (find street address based on given coordinates), and distance queries.
gem 'geocoder'

# Use to safely create links from user input.
gem 'rails_autolink'

# Pagination.
gem 'kaminari'

# Form helpers
gem 'simple_form'

# Background processing
gem 'delayed_job_active_record'

# Support multiple simultaneous requests by forking multiple rails processes.
gem 'unicorn'

# PaperTrail lets you track changes to your models' data. It's good for auditing or versioning.
# You can see how a model looked at any stage in its lifecycle, revert it to any version, and
# even undelete it after it's been destroyed.
gem 'paper_trail', '~> 2'

# AutoStripAttributes helps to remove unnecessary whitespace from ActiveRecord or ActiveModel attributes.
# It's good for removing accidental spaces from user inputs
# (e.g. when user copy/pastes some value to a form and the value has extra spaces at the end).
gem 'auto_strip_attributes'

group :development, :test do
	gem 'rspec-rails', '~> 2.0'
	gem 'cucumber-rails', '~> 1.0', require: false
	gem 'database_cleaner', '~> 0.8'
	# gem 'webrat', '~> 0.7'
	gem 'factory_girl_rails', '~> 4.1'
	gem 'email_spec', '~> 1.4'
	gem 'capybara', '~> 2.4'
	gem 'capybara-webkit'
	gem 'launchy', '~> 2.1'
	gem 'syntax'
	# gem 'sunspot_solr', '~> 2.0.0.pre' # optional pre-packaged Solr distribution for use in development
	git 'git://github.com/edsimpson/sunspot.git' do
		gem 'sunspot_solr'
	end
	# Run a test server (DRb server) via spork.
	gem 'spork-rails'
end

#Image processor and model manager for photo uploads
gem 'paperclip', '~> 3.5.0'

#S3 storage
gem 'aws-sdk', '~> 1.5.7'

#AJAX file uploader
gem 'jack_up', :git => 'https://github.com/thoughtbot/jack_up.git'
#Required for Jack_up
gem 'underscore-rails'
#Required for Jack_up
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

# To use debugger
# Ruby version 2.2.0 is not supported as of 19-Feb-2015.
#gem 'debugger', group: :development

# Makes running your Rails app easier. Based on the ideas behind 12factor.net
# https://github.com/heroku/rails_12factor
gem 'rails_12factor', group: :production

gem 'rails-footnotes', '>= 3.7.9', group: :development

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
gem "gibbon"
