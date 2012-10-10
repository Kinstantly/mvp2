require 'spec_helper'

describe "home/index" do
	it "shows the home page headline" do
		render
		rendered.should =~ /Zatch/
	end
end
