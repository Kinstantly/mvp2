require 'spec_helper'

describe Users::RegistrationsController do
	before(:each) do
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end
	
	context "as a non-provider member" do
		before (:each) do
			@mimi = FactoryGirl.create(:client_user)
			sign_in @mimi
		end
	
		describe "PUT update" do
			it "updates email address for confirmation" do
				put :update, user: {email: 'mimi@la.boheme.it', current_password: @mimi.password}
				response.should redirect_to '/'
				flash[:notice].should_not be_nil
			end
		
			it "fails to update email address with double quote" do
				put :update, user: {email: 'mimi@la.boheme.it"', current_password: @mimi.password}
				response.should render_template('edit')
			end
		
			it "fails to update email address with single quote" do
				put :update, user: {email: "mimi@la.boheme.it'", current_password: @mimi.password}
				response.should render_template('edit')
			end
		end
	end
end
