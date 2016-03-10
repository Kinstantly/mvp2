class StripeCard < ActiveRecord::Base
	# Remove the following after upgrading to Rails 4.0 or greater.
	include ActiveModel::ForbiddenAttributesProtection
	
	has_paper_trail # Track changes to each Stripe credit card record.
	
	# attr_accessible :api_card_id, :deleted, :livemode, :brand, :funding, :exp_month, :exp_year, :last4
	
	attr_protected :id # config.active_record.whitelist_attributes=true but we want it to be effectively false for selected models for which we want strong parameters to do the work.
	
	belongs_to :stripe_customer
	has_many :stripe_charges
	
	# Retrieve card data from Stripe.
	def retrieve
		if api_card_id.present? and (api_customer = stripe_customer.try(:retrieve))
			api_customer.cards.retrieve(api_card_id)
		end
	end
end
