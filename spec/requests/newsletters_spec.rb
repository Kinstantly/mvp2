require 'spec_helper'

describe "Newsletters", :type => :request do
	
	describe "request latest sample url" do
		it "responds successfully" do
			get latest_newsletter_url(:parent_newsletters)
			expect(response.status).to eq(200)
		end
	end

	describe "request newsletter archive page" do
		it "responds successfully" do
			get newsletter_list_url
			expect(response.status).to eq(200)
		end
	end

	describe "request newsletter 'abc' edition page" do
		it "responds successfully" do
			get newsletter_url(:abc)
			expect(response.status).to eq(200)
		end
	end

	describe "old newsletter sign-up page" do
		it "responds successfully" do
			get newsletters_url, oldnewsletters: true
			expect(response.status).to eq(200)
		end
		
		it "redirects to the sign-up confirmation page" do
			post newsletters_subscribe_url, { parent_newsletters: 1, email: 'subscriber@example.com' }
			expect(response.status).to eq(302)
			expect(response.redirect_url).to eq newsletters_subscribed_url({ nlsub: 't', parent_newsletters: 't' })
		end
	end

	describe "alerts sign-up page", alerts: true do
		it "responds successfully" do
			get alerts_url
			expect(response.status).to eq(200)
		end
		
		it "redirects to the alerts sign-up page" do
			get newsletters_url
			expect(response.status).to eq(302)
			expect(response.redirect_url).to eq alerts_url
		end
		
		it "redirects to the sign-up confirmation page" do
			post alerts_subscribe_url, { parent_newsletters: 1, email: 'subscriber@example.com', duebirth1: '7/5/2014' }
			expect(response.status).to eq(302)
			expect(response.redirect_url).to eq alerts_subscribed_url({ nlsub: 't', parent_newsletters: 't' })
		end
	end
end
