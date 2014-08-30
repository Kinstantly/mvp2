class StripeInfo < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe info record.
	
	belongs_to :user
	has_many :stripe_customers
	
	validates_presence_of :stripe_user_id, :access_token, :publishable_key
end
