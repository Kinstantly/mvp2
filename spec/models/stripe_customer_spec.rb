require 'spec_helper'

describe StripeCustomer, payments: true do
	let(:stripe_customer) { FactoryGirl.create :stripe_customer }
	let(:api_customer) { stripe_customer_mock }
	
	it "has an API ID" do
		stripe_customer.api_customer_id.should be_present
	end
	
	it "has a description" do
		stripe_customer.description.should be_present
	end
	
	it "can have a credit card" do
		expect {
			stripe_customer.stripe_cards << FactoryGirl.create(:stripe_card)
		}.to change { stripe_customer.stripe_cards.size }.by(1)
	end
	
	it "can have multiple credit cards" do
		expect {
			stripe_customer.stripe_cards << FactoryGirl.create(:stripe_card)
			stripe_customer.stripe_cards << FactoryGirl.create(:stripe_card)
		}.to change { stripe_customer.stripe_cards.size }.by(2)
	end
	
	it "can retrieve remote customer information" do
		Stripe::Customer.stub(:retrieve).with(any_args) do
			api_customer
		end
		stripe_customer.retrieve.should == api_customer
	end
end
