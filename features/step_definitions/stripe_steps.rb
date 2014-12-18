# Tip: to view the page, use: save_and_open_page

def charge_amount_usd
	@charge_amount_usd.presence || '$1.00'
end

def charge_amount_cents
	Monetize.parse(charge_amount_usd).cents
end

def charge_fee_cents
	(charge_amount_cents * 0.05).to_i
end

def charge_description
	@charge_description
end

def charge_statement_description
	@charge_statement_description
end

def charge_amount_refunded
	@charge_amount_refunded
end

def api_token
	double('Stripe::Token').as_null_object
end

def api_charge
	charge = double('Stripe::Charge').as_null_object
	charge.stub(
		id:                    '1234567890',
		amount:                charge_amount_cents,
		description:           charge_description,
		statement_description: charge_statement_description,
		balance_transaction:   '1234567890',
		refunds: api_refunds
	)
	charge.stub(:amount_refunded) { charge_amount_refunded }
	charge.stub(:refunded) { charge_amount_refunded == charge_amount_cents }
	charge
end

def api_balance_transaction
	transaction = double('Stripe::BalanceTransaction').as_null_object
	transaction.stub fee: charge_fee_cents, fee_details: []
	transaction
end

def api_refund
	refund = double('Stripe::Refund').as_null_object
	refund.stub balance_transaction: api_balance_transaction
	refund
end

def api_refunds
	Struct.new 'StripeRefunds' unless defined? Struct::StripeRefunds
	refunds = double('Struct::StripeRefunds').as_null_object
	refunds.stub(:create) do |refund_arguments, access_token|
		@charge_amount_refunded = refund_arguments[:amount]
		api_refund
	end
	refunds
end

def api_application_fee_list
	list = double('Stripe::ListObject').as_null_object
	list.stub data: []
	list
end

def stripe_setup
	Stripe::Token.stub(:create).with(any_args) do
		api_token
	end
	Stripe::Charge.stub(:create).with(any_args) do
		api_charge
	end
	Stripe::Charge.stub(:retrieve).with(any_args) do
		api_charge
	end
	Stripe::BalanceTransaction.stub(:retrieve).with(any_args) do
		api_balance_transaction
	end
	Stripe::ApplicationFee.stub(:all).with(any_args) do
		api_application_fee_list
	end
end

### GIVEN ###

Given /^We are using Stripe for payments$/ do
	stripe_setup
end

### WHEN ###

When /^I want to charge "(.*?)"$/ do |amount|
	@charge_amount_usd = amount
	fill_in 'customer_file[charge_amount_usd]', with: amount
end

When /^I want the charge description to be "(.*?)"$/ do |text|
	@charge_description = text
	fill_in 'customer_file[charge_description]', with: text
end

When /^I want the description on the charge statement to be "(.*?)"$/ do |text|
	@charge_statement_description = text
	fill_in 'customer_file[charge_statement_description]', with: text
end
