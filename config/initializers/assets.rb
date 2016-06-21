# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( home_page.css interior.css home_page_ie8.css plain.css ie.css )
Rails.application.config.assets.precompile += %w( home_page_old.css ) # Home page with sliding banner.

# Precompile additional js manifests
Rails.application.config.assets.precompile += %w( profile_edit.js profile_search.js profile_show.js review_new.js payment.js )
