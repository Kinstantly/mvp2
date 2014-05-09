require 'spec_helper'

describe ProviderSuggestionsController do

	# This should return at least the minimal set of attributes required to create a valid ProviderSuggestion.
	let (:valid_attributes) { FactoryGirl.attributes_for :provider_suggestion }

	context "not signed in" do
		describe "GET new" do
			it "assigns a new provider_suggestion as @provider_suggestion" do
				get :new
				assigns(:provider_suggestion).should be_a_new(ProviderSuggestion)
			end
		end

		describe "POST create" do
			describe "with valid params" do
				it "creates a new ProviderSuggestion" do
					expect {
						post :create, {:provider_suggestion => valid_attributes}
					}.to change(ProviderSuggestion, :count).by(1)
				end

				it "assigns a newly created provider_suggestion as @provider_suggestion" do
					post :create, {:provider_suggestion => valid_attributes}
					assigns(:provider_suggestion).should be_a(ProviderSuggestion)
					assigns(:provider_suggestion).should be_persisted
				end

				it "redirects to the created provider_suggestion" do
					post :create, {:provider_suggestion => valid_attributes}
					response.should render_template('create')
				end
			end

			describe "with invalid params" do
				it "assigns a newly created but unsaved provider_suggestion as @provider_suggestion" do
					# Trigger the behavior that occurs when invalid params are submitted
					ProviderSuggestion.any_instance.stub(:save).and_return(false)
					post :create, {:provider_suggestion => {}}
					assigns(:provider_suggestion).should be_a_new(ProviderSuggestion)
				end

				it "renders the 'create' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					ProviderSuggestion.any_instance.stub(:save).and_return(false)
					post :create, {:provider_suggestion => {}}
					response.should render_template('create')
				end
			end
		end
	end

	context "as admin user" do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'iris@example.com' }

		before (:each) do
			sign_in admin_user
		end

		describe "GET index" do
			it "assigns all provider_suggestions as @provider_suggestions" do
				provider_suggestion = FactoryGirl.create :provider_suggestion
				get :index
				assigns(:provider_suggestions).should eq([provider_suggestion])
			end
		end

		describe "GET show" do
			it "assigns the requested provider_suggestion as @provider_suggestion" do
				provider_suggestion = FactoryGirl.create :provider_suggestion
				get :show, {:id => provider_suggestion.to_param}
				assigns(:provider_suggestion).should eq(provider_suggestion)
			end
		end

		describe "GET edit" do
			it "assigns the requested provider_suggestion as @provider_suggestion" do
				provider_suggestion = FactoryGirl.create :provider_suggestion
				get :edit, {:id => provider_suggestion.to_param}
				assigns(:provider_suggestion).should eq(provider_suggestion)
			end
		end

		describe "PUT update" do
			describe "with valid params" do
				it "updates the requested provider_suggestion" do
					provider_suggestion = FactoryGirl.create :provider_suggestion
					# Assuming there are no other provider_suggestions in the database, this
					# specifies that the ProviderSuggestion created on the previous line
					# receives the :update_attributes message with whatever params are
					# submitted in the request.
					ProviderSuggestion.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
					put :update, {:id => provider_suggestion.to_param, :provider_suggestion => {'these' => 'params'}}
				end

				it "assigns the requested provider_suggestion as @provider_suggestion" do
					provider_suggestion = FactoryGirl.create :provider_suggestion
					put :update, {:id => provider_suggestion.to_param, :provider_suggestion => valid_attributes}
					assigns(:provider_suggestion).should eq(provider_suggestion)
				end

				it "redirects to the provider_suggestion" do
					provider_suggestion = FactoryGirl.create :provider_suggestion
					put :update, {:id => provider_suggestion.to_param, :provider_suggestion => valid_attributes}
					response.should redirect_to(provider_suggestion)
				end
			end

			describe "with invalid params" do
				it "assigns the provider_suggestion as @provider_suggestion" do
					provider_suggestion = FactoryGirl.create :provider_suggestion
					# Trigger the behavior that occurs when invalid params are submitted
					ProviderSuggestion.any_instance.stub(:save).and_return(false)
					put :update, {:id => provider_suggestion.to_param, :provider_suggestion => {}}
					assigns(:provider_suggestion).should eq(provider_suggestion)
				end

				it "re-renders the 'edit' template" do
					provider_suggestion = FactoryGirl.create :provider_suggestion
					# Trigger the behavior that occurs when invalid params are submitted
					ProviderSuggestion.any_instance.stub(:update_attributes).and_return(false)
					put :update, {:id => provider_suggestion.to_param, :provider_suggestion => {}}
					response.should render_template("edit")
				end
			end
		end

		describe "DELETE destroy" do
			it "destroys the requested provider_suggestion" do
				provider_suggestion = FactoryGirl.create :provider_suggestion
				expect {
					delete :destroy, {:id => provider_suggestion.to_param}
				}.to change(ProviderSuggestion, :count).by(-1)
			end

			it "redirects to the provider_suggestions list" do
				provider_suggestion = FactoryGirl.create :provider_suggestion
				delete :destroy, {:id => provider_suggestion.to_param}
				response.should redirect_to(provider_suggestions_url)
			end
		end
	end
end
