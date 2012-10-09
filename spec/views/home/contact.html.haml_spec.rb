require 'spec_helper'

describe "home/contact" do
	it "should have an iframe" do
		render
		rendered.should have_css('.contact iframe')
	end
end
