class StripeCustomer < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe customer record.
	
	attr_accessible :api_customer_id, :description, :deleted, :livemode
	
	belongs_to :stripe_info
	belongs_to :provider_customer
	has_many :stripe_cards
end
