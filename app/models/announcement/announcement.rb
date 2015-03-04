class Announcement < ActiveRecord::Base
	has_paper_trail # Track changes to each announcement.

	attr_accessible :body, :headline, :icon, :position, :button_text, :button_url, :start_at, :end_at
  
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :body, :headline, :button_text, :button_url
	
	# Touch the associated profile to change the cache_key for its fragment caches.
	belongs_to :profile, counter_cache: true, touch: true

	# Define maximum length of each string or text attribute in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MAX_LENGTHS = {headline: 50, body: 500, button_text: 25}
	DATEFORMAT = I18n.t('date.formats.display')

	[:headline, :body, :button_text].each do |attribute|
		validates attribute, length: {maximum: MAX_LENGTHS[attribute]}
	end

	validates :profile, :body, :headline, :icon, :start_at, presence: true
	validates_presence_of :button_text, :if => :button_url?
	validates_presence_of :button_url, :if => :button_text?
	validate :validate_date_range
	#validates_format_of :button_or_link_url, with: URI::regexp

	before_save :set_active_status
	after_initialize :defaults

	scope :active, -> { where(active: true) }

	def start_at_date
		start_at.strftime(DATEFORMAT) unless start_at.blank?
	end

	def end_at_date
		end_at.strftime(DATEFORMAT) unless end_at.blank?
	end

	def start_at=(input_date)
		self[:start_at] = convert_to_datetime(input_date)
	end

	def end_at=(input_date)
		self[:end_at] = convert_to_datetime(input_date)
	end

	def active?
		active
	end

	private

	def defaults
		self.icon ||= 0
	end

	def set_active_status
		now = Time.zone.now
		self.active = (start_at <= now && (end_at.blank? || end_at >= now)) unless start_at.blank?
		true
	end

	def validate_date_range
		if end_at.present? && start_at.present?
			errors.add(:end_at, I18n.t('models.announcement.end_before_start_error')) if end_at < start_at
		end
	end

	def convert_to_datetime(date_str)
		begin
			Time.strptime("#{date_str} #{Time.zone.formatted_offset}", "#{DATEFORMAT} %z") unless date_str.blank?
		rescue
			date_str
		end
	end
end
