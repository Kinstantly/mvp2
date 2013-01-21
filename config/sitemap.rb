# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = SITEMAP_DEFAULT_HOST
SitemapGenerator::Sitemap.sitemaps_host = 'http://s3.amazonaws.com/kinstantly/'
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = SITEMAP_SITEMAPS_PATH
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new

SitemapGenerator::Sitemap.create do
	add provider_sign_up_path, changefreq: 'monthly'
	add about_path, changefreq: 'monthly'
	add contact_path, changefreq: 'monthly'
	add terms_path, changefreq: 'monthly'
	
	Profile.where(is_published: true).find_each do |profile|
		add profile_path(profile), priority: 1.0, changefreq: 'daily', lastmod: profile.updated_at
	end
	
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
