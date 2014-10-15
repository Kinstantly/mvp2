class StripeCharge < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe charge record.
	
	attr_accessible :api_charge_id, :amount, :amount_refunded, :paid, :refunded, :captured, :deleted, :livemode,
		:balance_transaction, :fee, :stripe_fee, :application_fee, :description, :statement_description
	
	belongs_to :stripe_card
	belongs_to :customer_file
	
	monetize :amount, as: 'amount_usd', allow_nil: true
	
	# Define maximum length of each string or text attribute in a publicly accessible way.
	# This allows them to be used by other models or at the view layer for character counts.
	MAX_LENGTHS = {
		description: 250,
		statement_description: 15 # See https://stripe.com/docs/api#create_charge
	}
	
	[:description, :statement_description].each do |attribute|
		validates attribute, allow_blank: true, length: {maximum: MAX_LENGTHS[attribute]}
	end
end
