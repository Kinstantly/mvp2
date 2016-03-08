class ProfileClaim < ActiveRecord::Base
	# Remove the following after upgrading to Rails 4.0 or greater.
	include ActiveModel::ForbiddenAttributesProtection
	
	has_paper_trail # Track changes to each profile claim.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [ :claimant_email, :claimant_phone ]
	EDITOR_ACCESSIBLE_ATTRIBUTES = [
		*DEFAULT_ACCESSIBLE_ATTRIBUTES,
		:admin_notes
	]
	
	attr_protected :id # config.active_record.whitelist_attributes=true but we want it to be effectively false for selected models for which we want strong parameters to do the work.

	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :claimant_email, :claimant_phone

	belongs_to :claimant, class_name: 'User'
	belongs_to :profile

	MAX_LENGTHS = {
		claimant_email: User::MAX_LENGTHS[:email],
		claimant_phone: PhoneNumberValidator::MAX_LENGTH
	}

	validates_presence_of :profile

	validates :claimant_email, email: true

	validates :claimant_phone, phone_number: true, allow_blank: true

	scope :order_by_descending_id, order('id DESC')

	after_create :send_profile_claim_notice

	private

	def send_profile_claim_notice
		AdminMailer.profile_claim_notice(self).deliver
	end
end
