# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

Mvp2::Application.config.secret_token = 'c00622ad01f871609998b1fe3a615668cfe57eb2da29c353ddce7f65a8e25d02b1c58260dae8a7b35917e5cc6f3e899bed97da723bf2ab6a05d5bd1e3fa001b4'

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.

# When you are sure you won't be rolling back to Rails 3.x, create a secret key for the following (in production, be sure to set it from an environment variable):
Mvp2::Application.config.secret_key_base = ENV['SECRET_KEY_BASE'] || 'c0d30237ba6d1f068e4fec1fceb5d98698bc93d9dc747f6097460135fcf2e32e45d96e18b788610afcefd0036c113fa2408ede42e40528a564ab4cec32600845'

# http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#action-pack
#
# Rails 4.0 introduces ActiveSupport::KeyGenerator and uses this as a base from which to generate and verify signed cookies (among other things). Existing signed cookies generated with Rails 3.x will be transparently upgraded if you leave your existing secret_token in place and add the new secret_key_base.
#
# # config/initializers/secret_token.rb
# Myapp::Application.config.secret_token = 'existing secret token'
# Myapp::Application.config.secret_key_base = 'new secret key base'
#
# Please note that you should wait to set secret_key_base until you have 100% of your userbase on Rails 4.x and are reasonably sure you will not need to rollback to Rails 3.x. This is because cookies signed based on the new secret_key_base in Rails 4.x are not backwards compatible with Rails 3.x. You are free to leave your existing secret_token in place, not set the new secret_key_base, and ignore the deprecation warnings until you are reasonably sure that your upgrade is otherwise complete.

# After the dust has settled and you have fully converted to secret_key_base, consider using config/secrets.yml instead of config/initializers/secret_token.rb.
# See http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#config-secrets-yml
