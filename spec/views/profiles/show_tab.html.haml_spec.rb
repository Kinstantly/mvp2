require 'spec_helper'

describe "profiles/show_tab" do
	let(:provider) { FactoryGirl.create(:provider, email: 'me@example.com') }
	let(:profile) { provider.profile }
	
	before (:each) do
		sign_in provider
	end
	
	it "should show the provider first name" do
		assign :profile, profile
		render
		rendered.should have_content(profile.first_name)
	end
end
