class StripeCharge < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe charge record.
	
	attr_accessible :api_charge_id, :amount, :amount_refunded, :paid, :refunded, :captured, :deleted, :livemode
	
	belongs_to :stripe_card
	belongs_to :customer_file
end
