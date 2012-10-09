require 'spec_helper'

describe "home/request_expert" do
	it "should have an iframe" do
		render
		rendered.should have_css('.request_expert iframe')
	end
end
