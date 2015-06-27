require 'spec_helper'

describe NewslettersController do
	describe "GET latest newsletter url" do
		it "redirects to mailchimp archive url" do
			get :latest, name: :parent_newsletters_stage1
			response.should render_template('show')
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

	describe "GET newsletter sign-up page" do
		it "renders the view" do
			get :new
			response.should render_template('new')
		end
	end

	describe "POST subscribe" do
		it "should redirect to confirmation page after a successful update" do
			post :subscribe, { parent_newsletters_stage1: 1, email: 'subscriber@newsletter.com' }
			response.should redirect_to newsletters_subscribed_url({ nlsub: 't', parent_newsletters_stage1: 't' })
		end
		it "should re-render sign-up form if no email provided" do
			post :subscribe, { parent_newsletters_stage1: 1 }
			response.should render_template('new')
		end
		it "should re-render sign-up form if no subscription list selected" do
			post :subscribe, { email: 'subscriber@newsletter.com' }
			response.should render_template('new')
		end
	    it "sends a confirmation email" do
	        expect { post :subscribe, { parent_newsletters_stage1: 1, email: 'subscriber@newsletter.com' } }.to change {ActionMailer::Base.deliveries.count}.by(1)
	    end
	end
end
