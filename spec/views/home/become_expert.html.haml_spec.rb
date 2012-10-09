require 'spec_helper'

describe "home/become_expert" do
	it "should have an iframe" do
		render
		rendered.should have_css('.become_expert iframe')
	end
end
