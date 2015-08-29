require 'spec_helper'

describe NewslettersController, :type => :controller do
	describe "GET latest newsletter url" do
		it "redirects to mailchimp archive url" do
			get :latest, name: :parent_newsletters
			expect(response).to render_template('show')
		end
	end

	describe "GET newsletter archive page" do
		it "renders the view" do
			get :list
			expect(response).to render_template('list')
		end
	end

	describe "GET single newsletter page" do
		it "renders the view" do
			get :show, id: :abc
			expect(response).to render_template('show')
		end
	end

	describe "GET newsletter sign-up page" do
		it "renders the view" do
			get :new
			expect(response).to render_template('new')
		end
	end

	describe "POST subscribe" do
		it "should redirect to confirmation page after a successful update" do
			post :subscribe, { parent_newsletters: 1, email: 'subscriber@newsletter.com' }
			expect(response).to redirect_to newsletters_subscribed_url({ nlsub: 't', parent_newsletters: 't' })
		end
		it "should re-render sign-up form if no email provided" do
			post :subscribe, { parent_newsletters: 1 }
			expect(response).to render_template('new')
		end
		it "should re-render sign-up form if no subscription list selected" do
			post :subscribe, { email: 'subscriber@newsletter.com' }
			expect(response).to render_template('new')
		end
	    it "sends a confirmation email" do
	        expect { post :subscribe, { parent_newsletters: 1, email: 'subscriber@newsletter.com' } }.to change {ActionMailer::Base.deliveries.count}.by(1)
	    end
	end
end
