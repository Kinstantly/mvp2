class StripeCustomer < ActiveRecord::Base
	# Remove the following after upgrading to Rails 4.0 or greater.
	include ActiveModel::ForbiddenAttributesProtection
	
	has_paper_trail # Track changes to each Stripe customer record.
	
	# attr_accessible :api_customer_id, :description, :deleted, :livemode
	
	attr_protected :id # config.active_record.whitelist_attributes=true but we want it to be effectively false for selected models for which we want strong parameters to do the work.
	
	belongs_to :stripe_info
	belongs_to :customer
	has_many :stripe_cards
	
	# Retrieve customer data from Stripe.
	def retrieve
		Stripe::Customer.retrieve(api_customer_id) if api_customer_id.present?
	end
end
