require 'spec_helper'

describe "home/index" do
	it "displays the home page messaging" do
		render
		rendered.should contain("Get Answers")
	end
	
	it "displays a sign-up link" do
		render template: 'home/index', layout: 'layouts/application'
		rendered.should have_selector('a.sign_up')
	end
	
	it "displays a sign-in link" do
		render template: 'home/index', layout: 'layouts/application'
		rendered.should have_selector('a.sign_in')
	end
end
