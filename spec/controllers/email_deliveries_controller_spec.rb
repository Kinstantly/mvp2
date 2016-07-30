require 'rails_helper'

RSpec.describe EmailDeliveriesController, type: :controller do

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

	describe "GET #new_list" do
		it "returns http success" do
			get :new_list
			expect(response).to have_http_status(:success)
		end
	end

	describe "GET #edit" do
		it "returns http success" do
			get :edit
			expect(response).to have_http_status(:success)
		end
	end

end
