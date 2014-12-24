class StripeInfo < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe info record.
	
	belongs_to :user
	has_many :stripe_customers
	
	after_save :touch_profile
	after_destroy :touch_profile
	
	validates_presence_of :stripe_user_id, :access_token, :publishable_key
	
	private
	
	# Touch profile to invalidate fragment cache(s) in case we need to update payment info on the profile page.
	def touch_profile
		user.try(:profile).try(:touch)
	end
end
