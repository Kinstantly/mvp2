require 'spec_helper'

describe "Newsletters", :type => :request do
	
	describe "request latest sample url" do
		it "responds successfully" do
			get latest_newsletter_path(:parent_newsletters_stage1)
			expect(response.status).to eq(200)
		end
	end

	describe "request newsletter archive page" do
		it "responds successfully" do
			get newsletter_list_path
			expect(response.status).to eq(200)
		end
	end

	describe "request newsletter 'abc' edition page" do
		it "responds successfully" do
			get newsletter_path(:abc)
			expect(response.status).to eq(200)
		end
	end

	describe "newsletter signup page" do
		it "responds successfully" do
			get newsletters_url
			expect(response.status).to eq(200)
		end
		it "redirects to the sign-up confirmation page" do
			post newsletters_subscribe_path, { parent_newsletters_stage1: 1, email: 'subscriber@example.com' }
			expect(response.status).to eq(302)
			expect(response.redirect_url).to eq newsletters_subscribed_url({ nlsub: 't', parent_newsletters_stage1: 't' })
		end
	end
end
