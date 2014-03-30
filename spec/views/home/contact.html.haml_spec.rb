require 'spec_helper'

describe "home/contact" do
	it "should show contact page content" do
		render
		rendered.should have_content 'Ask us anything'
	end
end
