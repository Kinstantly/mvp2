require 'spec_helper'

describe EmailDeliveriesController, type: :controller do

	context 'not signed in' do
		let(:email_delivery) { FactoryGirl.create :email_delivery }
		
		describe "GET #index" do
			it "does not allow access" do
				get :index
				expect(response).to redirect_to new_user_session_url
			end
		end

		describe "GET #new" do
			it "does not allow access" do
				get :new
				expect(response).to redirect_to new_user_session_url
			end
		end

		describe "GET #new_list" do
			it "does not allow access" do
				get :new_list
				expect(response).to redirect_to new_user_session_url
			end
		end

		describe "GET #edit" do
			it "does not allow access" do
				get :edit, id: email_delivery.id
				expect(response).to redirect_to new_user_session_url
			end
		end
	end

	context "as admin user" do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'iris@example.com' }
		let(:email_delivery) { FactoryGirl.create :email_delivery }

		before(:each) do
			sign_in admin_user
		end

		describe "GET #index" do
			it "returns http success" do
				get :index
				expect(response).to have_http_status(:success)
			end
		end

		describe "GET #new" do
			it "returns http success" do
				get :new
				expect(response).to have_http_status(:success)
			end
		end

		describe "GET #edit" do
			it "returns http success" do
				get :edit, id: email_delivery.id
				expect(response).to have_http_status(:success)
			end
		end

		describe "GET #new_list" do
			it "returns http success" do
				get :new_list
				expect(response).to have_http_status(:success)
			end
		end
		
		describe 'POST #create_list' do
			let(:email_1) { 'a@example.org' }
			let(:email_2) { 'b@example.com' }
			let(:email_3) { 'c@example.org' }
			let(:create_list_params) { {
				sender: 'me@example.com',
				email_type: 'provider_sell',
				email_list: "#{email_1}\n#{email_2}\n#{email_3}"
			} }
			
			context 'successfully' do
				it 'should create email delivery records' do
					expect {
						post :create_list, create_list_params
					}.to change(EmailDelivery, :count).by(3)
				end
				
				it 'should return a list' do
					post :create_list, create_list_params
					expect(assigns :email_unsubscribe_list).to include(email_1, email_2, email_3)
				end
			end
			
			context 'with errors' do
				let(:create_list_invalid_params) {
					create_list_params.merge email_list: "#{email_1}\n@expect.com\n#{email_3}"
				}
				
				it 'should not create email delivery records' do
					expect {
						post :create_list, create_list_invalid_params
					}.not_to change(EmailDelivery, :count)
				end
				
				it 'should return an error message' do
					post :create_list, create_list_invalid_params
					expect(assigns :alert).to be_present
				end
			end
			
			context 'with a blocked recipient' do
				before(:each) do
					FactoryGirl.create :contact_blocker, email: email_2
				end
				
				it 'should not return the blocked recipient' do
					post :create_list, create_list_params
					expect(assigns :email_unsubscribe_list).not_to include(email_2)
				end
			end
		end
	end

end
