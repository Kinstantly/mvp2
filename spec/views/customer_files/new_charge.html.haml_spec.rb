require 'spec_helper'

describe "customer_files/new_charge", type: :view, payments: true do
	let(:customer_file) { FactoryGirl.create :customer_file }
	let(:provider) { customer_file.provider }
	
	before (:each) do
		sign_in provider
	end
	
	it "should show the remaining authorized amount" do
		assign :customer_file, customer_file
		controller.request.path_parameters[:id] = customer_file.to_param # Needed for the form_for URL. Go figure.
		render
		expect(rendered).to have_content display_currency_amount(customer_file.authorized_amount_usd)
	end
end
