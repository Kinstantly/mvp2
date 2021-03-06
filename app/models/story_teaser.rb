class StoryTeaser < ActiveRecord::Base
	has_paper_trail # Track changes to each story teaser.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [ :active, :css_class, :display_order, :image_file, :title, :url ]
	
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :css_class, :image_file, :title, :url

	# Define minimum and/or maximum length of string and text attributes in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MAX_LENGTHS = {
		css_class: 254,
		image_file: 254,
		title: 254,
		url: 254
	}
	
	[:display_order].each do |attribute|
		validates attribute, presence: true
	end
	[:image_file, :title, :url].each do |attribute|
		validates attribute, presence: true
		validates attribute, length: {maximum: MAX_LENGTHS[attribute]}
	end
	[:css_class].each do |attribute|
		validates attribute, allow_blank: true, length: {maximum: MAX_LENGTHS[attribute]}
	end
	
	scope :order_by_descending_id, -> { order('id DESC') }
	scope :order_by_active_display_order, -> { order('active DESC, display_order ASC, id DESC') }
	scope :order_by_display_order, -> { order('display_order ASC') }
	scope :active_only, -> { where(active: true) }
	
	def tracked_url(source, medium, position)
		if url.present?
			campaign = url.gsub(%r{/?(\?.*)?\z}, '').gsub(%r{\A.+/}, '')
			tracked_url = url.include?('?') ? "#{url}&" : "#{url}?"
			tracked_url << "utm_source=#{source}"
			tracked_url << "&utm_medium=#{medium}"
			tracked_url << "&utm_content=position_#{position}"
			tracked_url << "&utm_campaign=blog_#{campaign}"
		else 
			url
		end
	end
	
	def activate
		self.active = true
		save
	end
	
	def deactivate
		self.active = false
		save
	end
end
