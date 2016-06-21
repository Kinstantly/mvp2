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
	allow(charge).to receive(:id).and_return('1234567890')
	allow(charge).to receive(:amount).and_return(charge_amount_cents)
	allow(charge).to receive(:description).and_return(charge_description)
	allow(charge).to receive(:statement_descriptor).and_return(charge_statement_description) # API attribute is now named statement_descriptor
	allow(charge).to receive(:balance_transaction).and_return('1234567890')
	allow(charge).to receive(:refunds).and_return(api_refunds)
	allow(charge).to receive(:amount_refunded) { charge_amount_refunded }
	allow(charge).to receive(:refunded) { charge_amount_refunded == charge_amount_cents }
	allow(charge).to receive(:paid).and_return(true)
	allow(charge).to receive(:captured).and_return(true)
	allow(charge).to receive(:livemode).and_return(false)
	charge
end

def api_balance_transaction
	transaction = double('Stripe::BalanceTransaction').as_null_object
	allow(transaction).to receive(:fee).and_return(charge_fee_cents)
	allow(transaction).to receive(:fee_details).and_return([])
	transaction
end

def api_refund
	refund = double('Stripe::Refund').as_null_object
	allow(refund).to receive(:balance_transaction).and_return(api_balance_transaction)
	allow(refund).to receive(:created).and_return(1419075210)
	refund
end

def api_refunds
	Struct.new 'StripeRefunds' unless defined? Struct::StripeRefunds
	refunds = double('Struct::StripeRefunds').as_null_object
	allow(refunds).to receive(:create) do |refund_arguments, access_token|
		@charge_amount_refunded = refund_arguments[:amount]
		api_refund
	end
	refunds
end

def api_application_fee_list
	list = double('Stripe::ListObject').as_null_object
	allow(list).to receive(:data).and_return([])
	list
end

def stripe_setup
	allow(Stripe::Token).to receive(:create).with(any_args) do
		api_token
	end
	allow(Stripe::Charge).to receive(:create).with(any_args) do
		api_charge
	end
	allow(Stripe::Charge).to receive(:retrieve).with(any_args) do
		api_charge
	end
	allow(Stripe::BalanceTransaction).to receive(:retrieve).with(any_args) do
		api_balance_transaction
	end
	allow(Stripe::ApplicationFee).to receive(:all).with(any_args) do
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
