require 'spec_helper'

describe "profiles/about_payments", type: :view, payments: true do
	let(:customer_file) { FactoryGirl.create :customer_file }
	let(:provider) { customer_file.provider }
	let(:profile) { provider.profile }
	
	it "should have some text about payments" do
		assign :profile, profile
		controller.request.path_parameters[:id] = profile.to_param
		render
		expect(rendered).to have_content 'Kinstantly gives you a better way to pay your favorite providers'
	end
end
