require 'spec_helper'

describe "customer_files/new_charge" do
	let(:customer_file) { FactoryGirl.create :customer_file }
	let(:provider) { customer_file.provider }
	
	before (:each) do
		sign_in provider
	end
	
	it "should show the remaining authorized amount" do
		assign :customer_file, customer_file
		render
		rendered.should have_content MyHelpers::display_currency_amount(customer_file.authorized_amount)
	end
end
