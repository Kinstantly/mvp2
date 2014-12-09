class StripeCharge < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe charge record.
	
	after_create :notify_customer
	
	attr_accessible :api_charge_id, :amount, :amount_refunded, :paid, :refunded, :captured, :deleted, :livemode,
		:balance_transaction, :fee, :stripe_fee, :application_fee, :description, :statement_description
	
	belongs_to :stripe_card
	belongs_to :customer_file
	
	scope :all_for_provider, lambda { |provider| joins(:customer_file).where(customer_files: {user_id: provider.id}) }
	
	monetize :amount, as: 'amount_usd', allow_nil: true
	monetize :amount_refunded, as: 'amount_refunded_usd', allow_nil: true
	monetize :stripe_fee, as: 'stripe_fee_usd', allow_nil: true
	monetize :application_fee, as: 'application_fee_usd', allow_nil: true
	
	# Define maximum length of each string or text attribute in a publicly accessible way.
	# This allows them to be used by other models or at the view layer for character counts.
	MAX_LENGTHS = {
		description: 250,
		statement_description: 15 # See https://stripe.com/docs/api#create_charge
	}
	
	[:description, :statement_description].each do |attribute|
		validates attribute, allow_blank: true, length: {maximum: MAX_LENGTHS[attribute]}
	end
	
	private
	
	# If there is a customer, notify them of the new charge.
	def notify_customer
		StripeChargeMailer.notify_customer(self).deliver if customer_file.try(:has_customer_account?)
	end
end
