# See http://m.onkey.org/running-rails-performance-tests-on-real-data
# fixed to work with Rails 3.2.8

# START : HAX HAX HAX
# Load Rails environment in 'test' mode
RAILS_ENV = "test"
require File.expand_path('../../config/environment', __FILE__)

# Re-establish db connection for 'performance' mode
silence_warnings { RAILS_ENV = "performance" }
ActiveRecord::Base.establish_connection
# STOP : HAX HAX HAX

require_dependency 'application_controller'

require 'test/unit'
require 'active_support/testing/performance'
require 'active_support/core_ext/kernel'
require 'active_support/test_case'
require 'action_controller/test_case'
require 'action_dispatch/testing/integration'

require 'rails/performance_test_help'

# You may want to turn off caching, if you're trying to improve non-cached rendering speed.
# Just uncomment this line:
# ActionController::Base.perform_caching = false

# Seems to be a bug in rails3, gives me a "wrong argument type Class (expected Module) (TypeError)" in Action Dispatch / performance_test.rb

ActiveSupport::Testing::Performance
