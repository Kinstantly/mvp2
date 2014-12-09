require 'spec_helper'

describe StripeChargesController do
	let(:charge_without_provider) { FactoryGirl.create :captured_stripe_charge }
	let(:charge) { FactoryGirl.create :captured_stripe_charge_with_customer }
	let(:provider) { charge.customer_file.provider }
	
	context "provider is not signed in" do
		describe "GET show" do
			it "cannot show the details of a charge" do
				get :show, id: charge.id
				response.status.should == 302 # Redirect.
				assigns(:stripe_charge).should be_nil # Never makes it to CanCan.
			end
		end
	end
	
	context "provider is signed in" do
		before(:each) do
			sign_in provider
		end
		
		describe "GET show" do
			it "can ONLY show the details of a charge made by the provider" do
				get :show, id: charge_without_provider.id
				response.status.should == 302 # Redirect.
			end
		end
		
		describe "GET show" do
			it "shows the details of a charge made by the provider" do
				get :show, id: charge.id
				assigns(:stripe_charge).should == charge
			end
		end
	end
end
