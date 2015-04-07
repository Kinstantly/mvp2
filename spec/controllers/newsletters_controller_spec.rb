require 'spec_helper'

describe NewslettersController do
	describe "GET latest newsletter url" do
		it "redirects to mailchimp archive url" do
			get :latest, name: :parent_newsletters_stage1
			response.location.should =~ /us9.campaign-archive1.com/
		end
	end
end
