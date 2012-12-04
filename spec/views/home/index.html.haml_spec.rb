require 'spec_helper'

describe "home/index" do
	it "shows the home page headline" do
		render
		rendered.should have_content(company_name)
	end
end
