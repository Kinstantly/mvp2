class StripeCard < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe credit card record.
	
	attr_accessible :api_card_id, :deleted, :livemode, :brand, :funding, :exp_month, :exp_year
	
	belongs_to :stripe_customer
	has_many :stripe_charges
	
	# Retrieve card data from Stripe.
	def retrieve
		if api_card_id.present? and (api_customer = stripe_customer.try(:retrieve))
			api_customer.cards.retrieve(api_card_id)
		end
	end
end
