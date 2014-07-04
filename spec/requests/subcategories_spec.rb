require 'spec_helper'

describe "Subcategories" do
	context "not logged in" do
		describe "GET /subcategories" do
			it "index page should be inaccessible to non-administrators" do
				get subcategories_path
				response.status.should be(302)
			end
		end
	end

	context "logged in as an administrator" do
		let(:admin_user) { FactoryGirl.create :admin_user }
		
		before (:each) do
			# sign in as an administrator
			post user_session_path, user: { email: admin_user.email, password: admin_user.password }
		end
		
		describe "GET /subcategories" do
			it "has an index page" do
				get subcategories_path
				response.status.should be(200)
			end
		end
	end
end
