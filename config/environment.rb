# Load the Rails application
require File.expand_path('../application', __FILE__)

# Initialize the Rails application
Mvp2::Application.initialize!

Haml::Template.options[:ugly] = true
