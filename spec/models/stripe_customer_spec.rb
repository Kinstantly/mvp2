require 'spec_helper'

describe StripeCustomer, type: :model, payments: true do
	let(:stripe_customer) { FactoryGirl.create :stripe_customer }
	let(:api_customer) { stripe_customer_mock }
	
	it "has an API ID" do
		expect(stripe_customer.api_customer_id).to be_present
	end
	
	it "has a description" do
		expect(stripe_customer.description).to be_present
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
		allow(Stripe::Customer).to receive(:retrieve).with(any_args) do
			api_customer
		end
		expect(stripe_customer.retrieve).to eq api_customer
	end
end
