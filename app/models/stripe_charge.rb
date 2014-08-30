class StripeCharge < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe charge record.
	
	attr_accessible :api_charge_id, :amount, :amount_refunded, :paid, :refunded, :captured, :deleted
	
	belongs_to :stripe_card
end
