# This timeout will produce a stack trace for debugging.
# To get a stack trace, this timeout should be less than the timeout value in config/unicorn.rb.
# FYI, Heroku’s router enforces a 30 second window before there is a request timeout.
# To use this:
#    gem 'rack-timeout'
# See https://github.com/kch/rack-timeout
#
# Rack::Timeout.timeout = 15  # seconds
