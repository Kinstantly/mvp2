def stripe_card_mock
	card = double('Stripe::Card').as_null_object
	allow(card).to receive(:exp_month).and_return(1)
	allow(card).to receive(:exp_year).and_return(2050)
	allow(card).to receive(:livemode).and_return(false)
	card
end

def stripe_customer_mock(options={})
	card = options[:card] || stripe_card_mock
	customer = double('Stripe::Customer').as_null_object
	cards = double 'Hash'
	allow(cards).to receive(:retrieve).with(any_args) { card }
	allow(customer).to receive(:cards).and_return(cards)
	allow(customer).to receive(:livemode).and_return(false)
	customer
end

def stripe_token_mock
	double('Stripe::Token').as_null_object
end

def stripe_charge_mock(options={})
	amount = options[:amount] || 1000
	description = options[:description]
	statement_descriptor = options[:statement_descriptor]
	refunds = options[:refunds] # default is nil
	charge = double('Stripe::Charge').as_null_object
	allow(charge).to receive(:amount).and_return(amount)
	allow(charge).to receive(:description).and_return(description)
	allow(charge).to receive(:statement_descriptor).and_return(statement_descriptor)
	allow(charge).to receive(:paid).and_return(true)
	allow(charge).to receive(:captured).and_return(true)
	allow(charge).to receive(:livemode).and_return(false)
	allow(charge).to receive(:refunded).and_return(false)
	allow(charge).to receive(:id).and_return('ch_XXXXXXXXXXXXXXXXXXXXXXXX')
	allow(charge).to receive(:balance_transaction).and_return('txn_XXXXXXXXXXXXXXXXXXXXXXXX')
	if refunds
		allow(charge).to receive(:refunds).and_return(refunds)
		allow(charge).to receive(:amount_refunded) { @stripe_amount_refunded }
	end
	charge
end

def stripe_refund_mock(options={})
	balance_transaction = options[:balance_transaction] || stripe_balance_transaction_mock
	refund = double('Stripe::Refund').as_null_object
	allow(refund).to receive(:balance_transaction).and_return(balance_transaction)
	allow(refund).to receive(:created).and_return(1419075210)
	refund
end

def stripe_charge_refunds_mock(options={})
	refund_mock = options[:refund_mock] || stripe_refund_mock
	Struct.new 'StripeRefunds' unless defined? Struct::StripeRefunds
	refunds = double('Struct::StripeRefunds').as_null_object
	allow(refunds).to receive(:create) do |refund_arguments, access_token|
		@stripe_amount_refunded ||= 0
		@stripe_amount_refunded += refund_arguments[:amount]
		refund_mock
	end
	refunds
end

def stripe_balance_transaction_mock(options={})
	fee_cents = options[:fee_cents] || 50
	fee_details = options[:fee_details] || []
	transaction = double('Stripe::BalanceTransaction').as_null_object
	allow(transaction).to receive(:fee).and_return(fee_cents)
	allow(transaction).to receive(:fee_details).and_return(fee_details)
	transaction
end

def application_fee_list_mock
	list = double('Stripe::ListObject').as_null_object
	allow(list).to receive(:data).and_return([])
	list
end

def stripe_account_mock(options={})
	verified = options.has_key?(:verified) ? options[:verified] : true
	{
		details_submitted: verified,
		transfer_enabled:  verified,
		charge_enabled:    verified
	}
end
