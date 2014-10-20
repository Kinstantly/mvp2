require 'spec_helper'

describe "profiles/about_payments" do
	let(:customer_file) { FactoryGirl.create :customer_file }
	let(:provider) { customer_file.provider }
	let(:profile) { provider.profile }
	
	it "should have some text about payments" do
		assign :profile, profile
		controller.request.path_parameters[:id] = profile.to_param
		render
		rendered.should have_content 'Kinstantly Pre-Authorized Payments lets you'
	end
end
