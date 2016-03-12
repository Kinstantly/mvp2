class StripeCustomer < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe customer record.
	
	# attr_accessible :api_customer_id, :description, :deleted, :livemode
	
	belongs_to :stripe_info
	belongs_to :customer
	has_many :stripe_cards
	
	# Retrieve customer data from Stripe.
	def retrieve
		Stripe::Customer.retrieve(api_customer_id) if api_customer_id.present?
	end
end
