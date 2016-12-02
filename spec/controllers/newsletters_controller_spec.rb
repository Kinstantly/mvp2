require 'spec_helper'

describe NewslettersController, type: :controller, mailchimp: true do
	describe 'newsletter' do
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

		describe "GET old newsletter sign-up page" do
			it "renders the view" do
				get :new, oldnewsletters: true
				expect(response).to render_template('new')
			end
		end

		describe "POST subscribe" do
			it "should redirect to confirmation page after a successful update" do
				post :subscribe, { parent_newsletters: 1, email: 'rspec@kinstantly.com' }
				expect(response).to redirect_to newsletters_subscribed_url({ nlsub: 't', parent_newsletters: 't' })
			end
			
			it "should re-render sign-up form if no email provided" do
				post :subscribe, { parent_newsletters: 1 }
				expect(response).to render_template('new')
			end
			
			it "should re-render sign-up form if no subscription list selected" do
				post :subscribe, { email: 'rspec@kinstantly.com' }
				expect(response).to render_template('new')
			end
			
			it "sends a confirmation email" do
					expect {
						post :subscribe, { parent_newsletters: 1, email: 'rspec@kinstantly.com' }
					}.to change {ActionMailer::Base.deliveries.count}.by(1)
			end
		end
	end

	describe 'alerts', alerts: true do
		describe "GET alerts sign-up page" do
			it "renders the view" do
				get :new, alerts: true
				expect(response).to render_template('new')
			end
		end

		describe "GET redirect to alerts sign-up page" do
			it "renders the view" do
				get :new
				expect(response).to redirect_to alerts_url
			end
		end

		describe "POST subscribe" do
			it "should redirect to confirmation page after a successful update" do
				post :subscribe, {
					parent_newsletters: 1, email: 'rspec@kinstantly.com', duebirth1: '04/01/2015', alerts: true
				}
				expect(response).to redirect_to alerts_subscribed_url({ nlsub: 't', parent_newsletters: 't' })
			end

			it "should redirect to confirmation page even if no birth date was supplied" do
				post :subscribe, {
					parent_newsletters: 1, email: 'rspec@kinstantly.com', alerts: true
				}
				expect(response).to redirect_to alerts_subscribed_url({ nlsub: 't', parent_newsletters: 't' })
			end
			
			it "should re-render sign-up form if no email provided" do
				post :subscribe, {
					parent_newsletters: 1, duebirth1: '04/01/2015', alerts: true
				}
				expect(response).to render_template('new')
			end
			
			it "should re-render sign-up form if no subscription list selected" do
				post :subscribe, {
					email: 'rspec@kinstantly.com', duebirth1: '04/01/2015', alerts: true
				}
				expect(response).to render_template('new')
			end
			
			it "sends a confirmation email" do
					expect {
						post :subscribe, {
							parent_newsletters: 1, email: 'rspec@kinstantly.com', duebirth1: '04/01/2015', alerts: true
						}
					}.to change {ActionMailer::Base.deliveries.count}.by(1)
			end
		end
	end
end
