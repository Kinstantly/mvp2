require 'spec_helper'

describe ProviderSuggestionsController, :type => :controller do

	# This should return at least the minimal set of attributes required to create a valid ProviderSuggestion.
	let (:valid_attributes) { FactoryGirl.attributes_for :provider_suggestion }

	let(:provider_suggestion) { FactoryGirl.create :provider_suggestion }

	context "not signed in" do
		describe "GET new" do
			it "assigns a new provider_suggestion as @provider_suggestion" do
				get :new
				expect(assigns(:provider_suggestion)).to be_a_new(ProviderSuggestion)
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
					expect(assigns(:provider_suggestion)).to be_a(ProviderSuggestion)
					expect(assigns(:provider_suggestion)).to be_persisted
				end

				it "redirects to the created provider_suggestion" do
					post :create, {:provider_suggestion => valid_attributes}
					expect(response).to render_template('create')
				end
			end

			describe "with invalid params" do
				it "assigns a newly created but unsaved provider_suggestion as @provider_suggestion" do
					# Trigger the behavior that occurs when invalid params are submitted
					allow_any_instance_of(ProviderSuggestion).to receive(:save).and_return(false)
					post :create, {:provider_suggestion => valid_attributes}
					expect(assigns(:provider_suggestion)).to be_a_new(ProviderSuggestion)
				end

				it "renders the 'create' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					allow_any_instance_of(ProviderSuggestion).to receive(:save).and_return(false)
					post :create, {:provider_suggestion => valid_attributes}
					expect(response).to render_template('create')
				end
			end
			
			describe "attempting to modify protected attribute(s)" do
				it "cannot assign admin notes" do
					notes = 'Sneaky notes.'
					expect {
						post :create, provider_suggestion: valid_attributes.merge(admin_notes: notes)
					}.to change(ProviderSuggestion, :count).by(1)
					expect(ProviderSuggestion.order(:id).last.admin_notes).not_to eq notes
				end

				it "cannot assign the suggester" do
					suggester = FactoryGirl.create :parent, email: 'nottheone@example.org', username: 'nottheone'
					expect {
						post :create, provider_suggestion: valid_attributes.merge(suggester_id: suggester.to_param)
					}.to change(ProviderSuggestion, :count).by(1)
					expect(ProviderSuggestion.order(:id).last.suggester).not_to eq suggester
				end
			end
		end
	end
	
	context "as signed-in user" do
		let(:user) { FactoryGirl.create :parent}
		
		before (:each) do
			sign_in user
		end

		describe "POST create" do
			it "assigns current user as the suggester" do
				expect {
					post :create, provider_suggestion: valid_attributes
				}.to change(ProviderSuggestion, :count).by(1)
				expect(ProviderSuggestion.order(:id).last.suggester).to eq user
			end
		end

		describe "attempting to modify protected attribute(s)" do
			it "cannot assign admin notes" do
				notes = 'Sneaky notes.'
				expect {
					post :create, provider_suggestion: valid_attributes.merge(admin_notes: notes)
				}.to change(ProviderSuggestion, :count).by(1)
				expect(ProviderSuggestion.order(:id).last.admin_notes).not_to eq notes
			end

			it "cannot assign an arbitrary suggester" do
				suggester = FactoryGirl.create :parent, email: 'nottheone@example.org', username: 'nottheone'
				expect {
					post :create, provider_suggestion: valid_attributes.merge(suggester_id: suggester.to_param)
				}.to change(ProviderSuggestion, :count).by(1)
				expect(ProviderSuggestion.order(:id).last.suggester).not_to eq suggester
			end
		end
	end

	context "as admin user" do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'iris@example.com' }

		before (:each) do
			provider_suggestion # Make sure a persistent provider_suggestion exists.
			sign_in admin_user
		end

		describe "GET index" do
			it "assigns all provider_suggestions as @provider_suggestions" do
				get :index
				expect(assigns(:provider_suggestions)).to eq([provider_suggestion])
			end
		end

		describe "GET show" do
			it "assigns the requested provider_suggestion as @provider_suggestion" do
				get :show, {:id => provider_suggestion.to_param}
				expect(assigns(:provider_suggestion)).to eq(provider_suggestion)
			end
		end

		describe "GET edit" do
			it "assigns the requested provider_suggestion as @provider_suggestion" do
				get :edit, {:id => provider_suggestion.to_param}
				expect(assigns(:provider_suggestion)).to eq(provider_suggestion)
			end
		end

		describe "PUT update" do
			describe "with valid params" do
				it "updates the requested provider_suggestion" do
					# Assuming there are no other provider_suggestions in the database, this
					# specifies that the newly created ProviderSuggestion
					# receives the :update_attributes message with whatever params are
					# submitted in the request as the admin role.
					expect_any_instance_of(ProviderSuggestion).to receive(:update_attributes).with(valid_attributes)
					put :update, {:id => provider_suggestion.to_param, :provider_suggestion => valid_attributes}
				end

				it "assigns the requested provider_suggestion as @provider_suggestion" do
					put :update, {:id => provider_suggestion.to_param, :provider_suggestion => valid_attributes}
					expect(assigns(:provider_suggestion)).to eq(provider_suggestion)
				end

				it "redirects to the provider_suggestion" do
					put :update, {:id => provider_suggestion.to_param, :provider_suggestion => valid_attributes}
					expect(response).to redirect_to(provider_suggestion)
				end
			end

			describe "with invalid params" do
				it "assigns the provider_suggestion as @provider_suggestion" do
					# Trigger the behavior that occurs when invalid params are submitted
					allow_any_instance_of(ProviderSuggestion).to receive(:update_attributes).and_return(false)
					put :update, {:id => provider_suggestion.to_param, :provider_suggestion => valid_attributes}
					expect(assigns(:provider_suggestion)).to eq(provider_suggestion)
				end

				it "re-renders the 'edit' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					allow_any_instance_of(ProviderSuggestion).to receive(:update_attributes).and_return(false)
					put :update, {:id => provider_suggestion.to_param, :provider_suggestion => valid_attributes}
					expect(response).to render_template("edit")
				end
			end
			
			describe "admin can modify attribute(s) that are protected from the default role" do
				it "can assign admin notes" do
					notes = 'Good notes.'
					expect {
						put :update, id: provider_suggestion.to_param,
							provider_suggestion: valid_attributes.merge(admin_notes: notes)
					}.to change { provider_suggestion.reload.admin_notes }.from(provider_suggestion.admin_notes).to(notes)
				end
			end
		end

		describe "DELETE destroy" do
			it "destroys the requested provider_suggestion" do
				expect {
					delete :destroy, {:id => provider_suggestion.to_param}
				}.to change(ProviderSuggestion, :count).by(-1)
			end

			it "redirects to the provider_suggestions list" do
				delete :destroy, {:id => provider_suggestion.to_param}
				expect(response).to redirect_to(provider_suggestions_url)
			end
		end
	end
end
