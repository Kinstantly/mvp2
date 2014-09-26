require 'spec_helper'

describe CustomerFile do
	let(:customer_file) { FactoryGirl.create :customer_file }
	
	it "belongs to a provider" do
		customer_file.provider.should_not be_nil
	end
	
	it "references a customer" do
		customer_file.customer.should_not be_nil
	end
	
	it "specifies the amount authorized by the customer that the provider can charge" do
		customer_file.authorization_amount = 2500
		customer_file.should have(:no).errors_on(:authorization_amount)
	end
	
	it "should create a charge" do
		pending 'stub of Stripe::Charge.create'
	end
end
