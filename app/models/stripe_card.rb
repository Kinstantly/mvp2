class StripeCard < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe credit card record.
	
	attr_accessible :api_card_id, :deleted, :livemode
	
	belongs_to :stripe_customer
	has_many :stripe_charges
end
