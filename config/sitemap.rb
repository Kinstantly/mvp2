# See: https://github.com/kjvarga/sitemap_generator/wiki/Generate-Sitemaps-on-read-only-filesystems-like-Heroku

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = Rails.configuration.sitemap_default_host
SitemapGenerator::Sitemap.sitemaps_host = "https://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com/"
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = Rails.configuration.sitemap_sitemaps_path
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new

SitemapGenerator::Sitemap.create do
	add provider_sign_up_path, changefreq: 'monthly'
	add new_user_registration_path, changefreq: 'monthly'
	add about_path, changefreq: 'monthly'
	add contact_path, changefreq: 'monthly'
	add terms_path, changefreq: 'monthly'
	add privacy_path, changefreq: 'monthly'
	
	# KidNotes (alerts) sign-up.
	add alerts_path, priority: 1.0, changefreq: 'monthly'
	
	Profile.where(is_published: true).find_each do |profile|
		add profile_path(profile), priority: 0.8, changefreq: 'daily', lastmod: profile.updated_at
	end
	
	# # Newsletter archive.
	# # Because the list page displays links to all samples, it changes with each mailing.
	# add newsletter_list_path, changefreq: 'weekly'
	# # And a page for each campaign (mailing).
	# [:parent_newsletters_stage1, :parent_newsletters_stage2, :parent_newsletters_stage3].each do |list|
	# 	Newsletter.send(list).each do |newsletter|
	# 		add newsletter_path(newsletter.cid), changefreq: 'monthly', lastmod: newsletter.updated_at if newsletter.content.present?
	# 	end
	# end
	
	# Put links creation logic here.
	#
	# The root path '/' and sitemap index file are added automatically for you.
	# Links are added to the Sitemap in the order they are specified.
	#
	# Usage: add(path, options={})
	#        (default options are used if you don't specify)
	#
	# Defaults: :priority => 0.5, :changefreq => 'weekly',
	#           :lastmod => Time.now, :host => default_host
	#
	# Examples:
	#
	# Add '/articles'
	#
	#   add articles_path, :priority => 0.7, :changefreq => 'daily'
	#
	# Add all articles:
	#
	#   Article.find_each do |article|
	#     add article_path(article), :lastmod => article.updated_at
	#   end
end
