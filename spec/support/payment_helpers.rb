def stripe_card_mock
	card = double('Stripe::Card').as_null_object
	card.stub exp_month: 1, exp_year: 2050
	card
end

def stripe_customer_mock(options={})
	card = options[:card] || stripe_card_mock
	customer = double('Stripe::Customer').as_null_object
	cards = double 'Hash'
	cards.stub(:retrieve).with(any_args) { card }
	customer.stub cards: cards
	customer
end

def stripe_token_mock
	double('Stripe::Token').as_null_object
end

def stripe_charge_mock(options={})
	amount_cents = options[:amount_cents] || 1000
	refunds = options[:refunds] # default is nil
	charge = double('Stripe::Charge').as_null_object
	charge.stub amount: amount_cents
	if refunds
		charge.stub refunds: refunds
		charge.stub(:amount_refunded) { @stripe_amount_refunded }
	end
	charge
end

def stripe_refund_mock(options={})
	balance_transaction = options[:balance_transaction] || stripe_balance_transaction_mock
	refund = double('Stripe::Refund').as_null_object
	refund.stub balance_transaction: balance_transaction, created: 1419075210
	refund
end

def stripe_charge_refunds_mock(options={})
	refund_mock = options[:refund_mock] || stripe_refund_mock
	Struct.new 'StripeRefunds' unless defined? Struct::StripeRefunds
	refunds = double('Struct::StripeRefunds').as_null_object
	refunds.stub(:create) do |refund_arguments, access_token|
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
	transaction.stub fee: fee_cents, fee_details: fee_details
	transaction
end

def application_fee_list_mock
	list = double('Stripe::ListObject').as_null_object
	list.stub data: []
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
