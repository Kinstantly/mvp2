require 'spec_helper'

describe CustomerFilesController do
	let(:customer_file_1) { FactoryGirl.create :customer_file, authorization_amount: 10000 }
	let(:provider) { customer_file_1.provider }
	let(:customer_file_2) { FactoryGirl.create :second_customer_file, provider: provider }
	let(:customer_1) { customer_file_1.customer }
	let(:parent_1) { customer_1.user }
	
	before(:each) do
		customer_file_1
		customer_file_2
	end
		
	context "customer or provider is not signed in" do
		describe "GET new" do
			it "is prevented from viewing a list of customer files" do
				get :index
				response.status.should == 302 # Redirect.
				assigns(:customer_files).should be_nil
			end
		end

		describe "GET show" do
			it "is prevented from viewing a customer file" do
				get :show, id: customer_file_1.id
				response.status.should == 302 # Redirect.
				assigns(:customer_file).should be_nil
			end
		end
	end
	
	context "customer is signed in" do
		before(:each) do
			sign_in parent_1
		end
		
		describe "GET new" do
			it "assigns a list of the customer's files" do
				get :index
				assigns(:customer_files).include?(customer_file_1).should be_true
			end
			
			it "does not list another customer's file" do
				get :index
				assigns(:customer_files).include?(customer_file_2).should be_false
			end
		end

		describe "GET show" do
			it "assigns the customer's file" do
				get :show, id: customer_file_1.id
				assigns(:customer_file).should == customer_file_1
			end

			it "does not show another customer's file" do
				get :show, id: customer_file_2.id
				response.status.should == 302 # Redirect.
			end
		end
	end
	
	context "provider is signed in" do
		before(:each) do
			sign_in provider
		end
		
		describe "GET new" do
			it "assigns a list of the provider's customer files" do
				get :index
				assigns(:customer_files).include?(customer_file_1).should be_true
				assigns(:customer_files).include?(customer_file_2).should be_true
			end
		end

		describe "GET show" do
			it "assigns a customer file" do
				get :show, id: customer_file_1.id
				assigns(:customer_file).should == customer_file_1
			end
		end
		
		describe "GET new_charge" do
			it "assigns a customer file" do
				get :new_charge, id: customer_file_1.id
				assigns(:customer_file).should == customer_file_1
			end
		end
		
		describe "PUT create_charge" do
			it "creates a charge record" do
				pending 'stub of CustomerFile#create_charge'
				expect {
					amount = customer_file_1.authorization_amount / 2
					put :create_charge, id: customer_file_1.id, charge_amount: amount, charge_description: 'test', charge_statement_description: 'test'
				}.to change(StripeCharge, :count).by(1)
			end
		end
	end
end
