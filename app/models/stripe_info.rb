class StripeInfo < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe info record.
	
	belongs_to :user
	has_many :stripe_customers
	
	after_save :touch_profile
	after_destroy :touch_profile
	
	validates_presence_of :stripe_user_id, :access_token, :publishable_key
	
	# Accepts authorization values obtained via the "omniauth.auth" request header.
	def configure_authorization(auth_values)
		self.stripe_user_id = auth_values.try(:[], :uid)
		self.access_token = auth_values.try(:[], :credentials).try(:[], :token)
		self.publishable_key = auth_values.try(:[], :extra).try(:[], :raw_info).try(:[], :stripe_publishable_key)
		save
	end
	
	private
	
	# Touch profile to invalidate fragment cache(s) in case we need to update payment info on the profile page.
	def touch_profile
		user.try(:profile).try(:touch)
	end
end
