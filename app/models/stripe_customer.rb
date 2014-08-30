class StripeCustomer < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe customer record.
	
	attr_accessible :api_customer_id, :description, :deleted
	
	belongs_to :stripe_info
	has_many :stripe_cards
end
