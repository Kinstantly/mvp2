# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Mvp2::Application.initialize!

Haml::Template.options[:ugly] = true
