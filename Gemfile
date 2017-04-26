# Global source lines are a security risk and should not be used as they can lead to gems being installed from unintended sources.
# Wrap all "gem" calls within a "source" block.

ruby '2.4.1'

source 'https://rubygems.org' do

	# gem 'rails', '4.2.7.1'
	gem 'rails', '4.2.8'

	# Bundle edge Rails instead:
	# gem 'rails', :git => 'git://github.com/rails/rails.git'

	# http://github.com/plataformatec/responders
	gem 'responders', '~> 2.0'

	# Put nokogiri before other gems that use libxml (like pg).
	# http://stackoverflow.com/a/15492096/1203206
	# http://stackoverflow.com/a/16943050/1203206
	# http://nokogiri.org
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

	# Gems used for assets.
	# https://github.com/rails/sass-rails
	gem 'sass-rails'
	# https://github.com/rails/coffee-rails
	gem 'coffee-rails'
	# http://github.com/lautis/uglifier
	gem 'uglifier'

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
	# We need >= 2.0.0. But it's not available on rubygems.org as of April 23, 2017.
	gem 'two_factor_authentication', git: 'https://github.com/Houdini/two_factor_authentication.git', ref: '82fb6b1'

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
	# http://sunspot.github.io/
	gem 'sunspot'
	gem 'sunspot_rails'

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
	# http://github.com/wmoxam/phonie
	gem 'phonie'

	# Geocoding (by street or IP address), reverse geocoding (find street address based on given coordinates), and distance queries.
	gem 'geocoder'

	# Use to safely create links from user input.
	# http://github.com/tenderlove/rails_autolink
	gem 'rails_autolink'

	# Pagination.
	gem 'kaminari'

	# Form helpers
	# https://github.com/plataformatec/simple_form
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
		gem 'sunspot_solr', git: 'https://github.com/edsimpson/sunspot.git'
	end

	# Benchmarking, debugging, and development.
	group :development do
		gem 'derailed'
		gem 'stackprof'
		# https://github.com/josevalim/rails-footnotes
		gem 'rails-footnotes', '~> 4.0'
		gem 'web-console', '~> 2.0'
		# Spring is a Rails application preloader.
		# https://github.com/rails/spring
		gem 'spring'
		gem 'spring-commands-rspec'
		gem 'spring-commands-cucumber'
		# The byebug debugger.
		# Example: bundle exec rails server --port=5000
		# http://github.com/deivid-rodriguez/byebug
		gem 'byebug'
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

	# Makes running your Rails app easier. Based on the ideas behind 12factor.net
	# https://github.com/heroku/rails_12factor
	gem 'rails_12factor', group: :production

	#Support for ReCAPTCHA's Mailhide API
	gem 'recaptcha-mailhide'

	# Custom categories and filters for Sendgrid
	gem 'sendgrid'

	# Cron jobs
	gem 'whenever', :require => false

	# Payments
	# https://stripe.com/docs
	gem 'stripe'
	# Stripe Connect
	# https://stripe.com/docs/connect
	gem 'omniauth-stripe-connect' #, :git => 'https://github.com/isaacsanders/omniauth-stripe-connect.git'
	# https://github.com/integrallis/stripe_event
	gem 'stripe_event'

	# Money! https://github.com/RubyMoney
	gem 'money-rails'

	# Mailchimp API wrapper
	# http://github.com/amro/gibbon
	gem "gibbon"

	# Rack middleware for blocking & throttling abusive requests.
	# https://github.com/kickstarter/rack-attack
	gem 'rack-attack'

	# Cross-Origin Resource Sharing (CORS).
	# Needed to serve assets from a CDN (CloudFront), in particular, fonts.
	# https://github.com/cyu/rack-cors
	gem 'rack-cors', require: 'rack/cors'

end
