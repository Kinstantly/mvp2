require 'spec_helper'

describe "home/privacy", :type => :view do
	it "should show our privacy policy" do
		render
		expect(rendered).to have_content 'Our Privacy Policy'
	end
end
