require 'spec_helper'

describe "home/about" do
	it "should have some text about us" do
		render
		rendered.should have_content('Zatch')
	end
end
