require 'spec_helper'

describe "home/contact", :type => :view do
	it "should show contact page content" do
		render
		expect(rendered).to have_content 'Ask us anything'
	end
end
