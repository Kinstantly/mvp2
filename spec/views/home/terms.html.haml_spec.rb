require 'spec_helper'

describe "home/terms", :type => :view do
	it "should show our terms of use" do
		render
		expect(rendered).to have_content 'Our Terms of Use'
	end
end
