require 'spec_helper'

describe "home/about", :type => :view do
	it "should have some text about us" do
		render
		expect(rendered).to have_content 'Meet the Founders'
	end
end
