class Announcement < ActiveRecord::Base
  	has_paper_trail # Track changes to each announcement.

	attr_accessible :body, :headline, :icon, :position, :button_text, :button_url, :start_at, :end_at
  
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :body, :headline, :button_text, :button_url
	
	# Touch the associated profile to change the cache_key for its fragment caches.
	belongs_to :profile, counter_cache: true, touch: true

	# Define maximum length of each string or text attribute in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MAX_LENGTHS = {headline: 50, body:  150, button_text: 25}
	DATEFORMAT =  "%Y-%m-%d"

	[:headline, :body, :button_text].each do |attribute|
		validates attribute, length: {maximum: MAX_LENGTHS[attribute]}
	end

	validates :body, :headline, :icon, :button_text, :button_url, :start_at, :end_at, presence: true
	validate :validate_date_range
	#validates_format_of :button_or_link_url, with: URI::regexp

	before_save :set_active_status

	scope :active, -> { where(active: true) }

	def start_at_date
		start_at.strftime(DATEFORMAT) unless start_at.blank?
	end

	def end_at_date
		end_at.strftime(DATEFORMAT) unless end_at.blank?
	end

	def active?
		active
	end

	private

	def set_active_status
	    now = DateTime.now
	    self.active = (start_at <= now && end_at >= now) unless start_at.blank? || end_at.blank?
	    true
	end

	def validate_date_range
	    if end_at.present? && start_at.present?
	    	errors.add(:end_at, I18n.t('models.announcement.end_at.end_before_start_error')) if end_at < start_at
	    end
	end
end
