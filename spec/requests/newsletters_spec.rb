require 'spec_helper'

describe "Newsletters" do
	
	describe "request latest sample url" do
		it "responds successfully" do
			get latest_newsletter_path(:parent_newsletters_stage1)
			response.status.should eq(200)
		end
	end

	describe "request newsletter archive page" do
		it "responds successfully" do
			get newsletter_list_path
			response.status.should eq(200)
		end
	end

	describe "request newsletter 'abc' edition page" do
		it "responds successfully" do
			get newsletter_path(:abc)
			response.status.should eq(200)
		end
	end

	describe "newsletter signup page" do
		it "responds successfully" do
			get newsletters_url
			response.status.should eq(200)
		end
		it "renders to the sign-up confirmation page" do
			post newsletters_subscribe_path, { parent_newsletters_stage1: 1, email: 'subscriber@example.com' }
			response.should render_template('subscribed')
		end
	end
end
