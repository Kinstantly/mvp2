require 'spec_helper'

describe "home/privacy" do
	it "should show our privacy policy" do
		render
		rendered.should have_content 'Our Privacy Policy'
	end
end
