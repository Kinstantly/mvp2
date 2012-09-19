require 'spec_helper'

describe "home/index.html.haml" do
	it "displays the home page messaging" do
		render
		rendered.should contain("Get Answers")
	end
end
