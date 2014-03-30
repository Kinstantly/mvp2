require 'spec_helper'

describe "home/terms" do
	it "should show our terms of use" do
		render
		rendered.should have_content 'Our Terms of Use'
	end
end
