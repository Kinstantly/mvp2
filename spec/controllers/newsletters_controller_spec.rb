require 'spec_helper'

describe NewslettersController do
	describe "GET latest newsletter url" do
		it "redirects to mailchimp archive url" do
			get :latest, name: :parent_newsletters_stage1
			response.location.should =~ /us9.campaign-archive1.com/
		end
	end

	describe "GET newsletter archive page" do
		it "renders the view" do
			get :list
			response.should render_template('list')
		end
	end

	describe "GET single newsletter page" do
		it "renders the view" do
			get :show, id: :abc
			response.should render_template('show')
		end
	end
end
