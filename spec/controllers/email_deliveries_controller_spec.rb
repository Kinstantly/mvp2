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

		# describe "GET #new_list" do
		# 	it "does not allow access" do
		# 		get :new_list
		# 		expect(response).to redirect_to new_user_session_url
		# 	end
		# end

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

		before (:each) do
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

		# describe "GET #new_list" do
		# 	it "returns http success" do
		# 		get :new_list
		# 		expect(response).to have_http_status(:success)
		# 	end
		# end

		describe "GET #edit" do
			it "returns http success" do
				get :edit, id: email_delivery.id
				expect(response).to have_http_status(:success)
			end
		end
	end

end
