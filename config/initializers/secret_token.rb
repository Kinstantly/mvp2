# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

Mvp2::Application.config.secret_token = 'c00622ad01f871609998b1fe3a615668cfe57eb2da29c353ddce7f65a8e25d02b1c58260dae8a7b35917e5cc6f3e899bed97da723bf2ab6a05d5bd1e3fa001b4'

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.

# When you are sure you won't be rolling back to Rails 3.x, create a secret key for the following:
# Mvp2::Application.config.secret_key_base = ''
