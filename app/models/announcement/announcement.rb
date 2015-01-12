class Announcement < ActiveRecord::Base
  	has_paper_trail # Track changes to each announcement.

	attr_accessible :icon, :position, :button_or_link_text, :date_start, :date_end
  
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :button_or_link_text
	
	# Touch the associated profile to change the cache_key for its fragment caches.
	belongs_to :profile, counter_cache: true, touch: true

	# Define maximum length of each string or text attribute in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MAX_LENGTHS = {button_or_link_text: 25}

	# Note: length of the phone attribute is checked by the phone number validator.
	[:button_or_link_text].each do |attribute|
		validates attribute, presence: true, length: {maximum: MAX_LENGTHS[attribute]}
	end

	validates :icon, :date_start, :date_end, presence: true

	before_save :set_active_status

	scope :active_profile_announcements, -> { where(type: 'profile_announcement', active: true) }
	scope :active_search_announcements,  -> { where(type: 'search_announcement', active: true) }

	def active?
		active
	end

	private

	def set_active_status
	    now = Date.today
	    self.active = (now <= date_end && now > date_start) unless date_start.blank? || date_end.blank?
	    true
	end
end
