class ProviderSuggestion < ActiveRecord::Base
	has_paper_trail # Track changes to each provider suggestion.
	
	attr_accessible :description, :provider_name, :provider_url, :suggester_email, :suggester_name
	
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :description, :provider_name, :provider_url, :suggester_email, :suggester_name
	
	belongs_to :suggester, class_name: 'User'
	
	# Define minimum and/or maximum length of string and text attributes in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MIN_LENGTHS = {
		description: 20,
		provider_name: 4
	}
	MAX_LENGTHS = {
		description: 5000,
		provider_name: 250,
		provider_url: 250,
		suggester_name: 250,
		suggester_email: User::MAX_LENGTHS[:email]
	}
	
	[:description, :provider_name].each do |attribute|
		validates attribute, length: {minimum: MIN_LENGTHS[attribute], maximum: MAX_LENGTHS[attribute]}
	end
	[:provider_url, :suggester_name].each do |attribute|
		validates attribute, allow_blank: true, length: {maximum: MAX_LENGTHS[attribute]}
	end
	
	# Require either a suggester record or a suggester email address.
	validates :suggester_email, email: true, if: Proc.new { |provider_suggestion| provider_suggestion.suggester.nil? }
	validates :suggester, presence: true, if: Proc.new { |provider_suggestion| provider_suggestion.suggester_email.blank? }
end
