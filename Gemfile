source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Make heroku happy.  They only support postgresql.
# gem 'sqlite3', :group => :development
gem 'pg'

gem 'haml'

# Get error message helpers for forms.
gem 'dynamic_form'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

gem 'ruby-prof', :git => 'git://github.com/wycats/ruby-prof.git'

# Authentication based on Warden.
gem 'devise'

group :development, :test do
	gem 'rspec-rails', '~> 2.0'
	gem 'cucumber-rails', '~> 1.0', require: false
	gem 'database_cleaner', '~> 0.8'
	# gem 'webrat', '~> 0.7'
	gem 'factory_girl_rails', '~> 4.1'
	gem 'email_spec', '~> 1.2'
	gem 'capybara', '~> 1.1'
	gem 'launchy', '~> 2.1'
	gem 'syntax'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
