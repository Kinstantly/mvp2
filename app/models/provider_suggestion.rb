class ProviderSuggestion < ActiveRecord::Base
	has_paper_trail # Track changes to each provider suggestion.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [ :description, :provider_name, :provider_url, :suggester_email, :suggester_name, :permission_use_suggester_name ]
	EDITOR_ACCESSIBLE_ATTRIBUTES = [
		*DEFAULT_ACCESSIBLE_ATTRIBUTES,
		:admin_notes
	]
	
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :description, :provider_name, :provider_url, :suggester_email, :suggester_name
	
	belongs_to :suggester, class_name: 'User'
	
	# Define minimum and/or maximum length of string and text attributes in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MIN_LENGTHS = {
		description: 4,
		provider_name: 4
	}
	MAX_LENGTHS = {
		description: 5000,
		provider_name: 250,
		provider_url: 250,
		suggester_name: 250,
		suggester_email: User::MAX_LENGTHS[:email]
	}
	
	# Require a suggester email address if there is no suggester record.
	validates :suggester_email, email: true, if: Proc.new { |provider_suggestion| provider_suggestion.suggester.nil? }
	
	[:suggester_name, :provider_url].each do |attribute|
		validates attribute, allow_blank: true, length: {maximum: MAX_LENGTHS[attribute]}
	end
	
	# If nothing entered, show a "required" error rather than a minimum character count error.
	[:provider_name, :description].each do |attribute|
		validates attribute, presence: true
		validates attribute, allow_blank: true, length: {minimum: MIN_LENGTHS[attribute], maximum: MAX_LENGTHS[attribute]}
	end
	
	scope :order_by_descending_id, -> { order('id DESC') }
	
	after_create :send_provider_suggestion_notice
	
	private
	
	def send_provider_suggestion_notice
		AdminMailer.provider_suggestion_notice(self).deliver
	end
end
