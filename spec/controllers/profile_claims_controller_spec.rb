require 'spec_helper'

describe ProfileClaimsController, :type => :controller do
	let(:profile_claim) { FactoryGirl.create :profile_claim }
	let (:valid_attributes) { FactoryGirl.attributes_for :profile_claim}
	let(:published_profile) { FactoryGirl.create :published_profile }
	
	context "as not signed-in user" do
		describe "GET new" do
			it "assigns a new profile_claim as @profile_claim" do
				get :new, profile_id: published_profile.id
				expect(assigns(:profile_claim)).to be_a_new(ProfileClaim)
			end
		end

		describe "POST create" do
			describe "with valid params" do
				it "creates a new ProfileClaim" do
					expect {
						post :create, {:profile_claim => valid_attributes, :profile_id => published_profile.id}
					}.to change(ProfileClaim, :count).by(1)
				end

				it "assigns a newly created profile_claim as @profile_claim" do
					post :create, {:profile_claim => valid_attributes, :profile_id => published_profile.id}
					expect(assigns(:profile_claim)).to be_a(ProfileClaim)
					expect(assigns(:profile_claim)).to be_persisted
				end

				it "redirects to the created profile_claim" do
					post :create, {:profile_claim => valid_attributes, :profile_id => published_profile.id}
					expect(response).to render_template('create')
				end
			end

			describe "with invalid params" do
				it "assigns a newly created but unsaved profile_claim as @profile_claim" do
					# Trigger the behavior that occurs when invalid params are submitted
					allow_any_instance_of(ProfileClaim).to receive(:save).and_return(false)
					post :create, {:profile_claim => valid_attributes, :profile_id => published_profile.id}
					expect(assigns(:profile_claim)).to be_a_new(ProfileClaim)
				end

				it "renders the 'create' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					allow_any_instance_of(ProfileClaim).to receive(:save).and_return(false)
					post :create, {:profile_claim => valid_attributes, :profile_id => published_profile.id}
					expect(response).to render_template('create')
				end
				
				it "does not create a profile claim if no profile ID is supplied" do
					expect {
						post :create, {:profile_claim => valid_attributes}
					}.to change(ProfileClaim, :count).by(0)
				end
			end
			
			describe "attempting to modify protected attribute(s)" do
				it "cannot assign admin notes" do
					notes = 'Sneaky notes.'
					expect {
						post :create, profile_claim: valid_attributes.merge(admin_notes: notes), profile_id: published_profile.id
					}.to change(ProfileClaim, :count).by(1)
					expect(ProfileClaim.order(:id).last.admin_notes).not_to eq notes
				end

				it "cannot assign the claimant" do
					claimant = FactoryGirl.create :parent
					expect {
						post :create, profile_claim: valid_attributes.merge(claimant_id: claimant.to_param), profile_id: published_profile.id
					}.to change(ProfileClaim, :count).by(1)
					expect(ProfileClaim.order(:id).last.claimant).not_to eq claimant
				end

				it "cannot assign an arbitrary profile" do
					profile = FactoryGirl.create :profile
					expect {
						post :create, profile_claim: valid_attributes.merge(profile_id: profile.to_param), profile_id: published_profile.id
					}.to change(ProfileClaim, :count).by(1)
					expect(ProfileClaim.order(:id).last.profile).not_to eq profile
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
			it "assigns current user as claimant" do
				expect {
					post :create, {:profile_claim => valid_attributes, :profile_id => published_profile.id}
				}.to change(ProfileClaim, :count).by(1)
				expect(ProfileClaim.order(:id).last.claimant).to eq user
			end
		end

		describe "attempting to modify protected attribute(s)" do
			it "cannot assign admin notes" do
				notes = 'Sneaky notes.'
				expect {
					post :create, profile_claim: valid_attributes.merge(admin_notes: notes), profile_id: published_profile.id
				}.to change(ProfileClaim, :count).by(1)
				expect(ProfileClaim.order(:id).last.admin_notes).not_to eq notes
			end

			it "cannot assign the claimant" do
				claimant = FactoryGirl.create :parent, email: 'nottheone@example.org', username: 'nottheone'
				expect {
					post :create, profile_claim: valid_attributes.merge(claimant_id: claimant.to_param), profile_id: published_profile.id
				}.to change(ProfileClaim, :count).by(1)
				expect(ProfileClaim.order(:id).last.claimant).not_to eq claimant
			end

			it "cannot assign an arbitrary profile" do
				profile = FactoryGirl.create :profile
				expect {
					post :create, profile_claim: valid_attributes.merge(profile_id: profile.to_param), profile_id: published_profile.id
				}.to change(ProfileClaim, :count).by(1)
				expect(ProfileClaim.order(:id).last.profile).not_to eq profile
			end
		end
	end

	context "as admin user" do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'iris@example.com' }

		before (:each) do
			profile_claim # Make sure a persistent profile_claim exists.
			sign_in admin_user
		end

		describe "GET index" do
			it "assigns all profile_claims as @profile_claims" do
				get :index
				expect(assigns(:profile_claims)).to eq([profile_claim])
			end
		end

		describe "GET show" do
			it "assigns the requested profile_claim as @profile_claim" do
				get :show, {:id => profile_claim.to_param}
				expect(assigns(:profile_claim)).to eq(profile_claim)
			end
		end

		describe "GET edit" do
			it "assigns the requested profile_claim as @profile_claim" do
				get :edit, {:id => profile_claim.to_param}
				expect(assigns(:profile_claim)).to eq(profile_claim)
			end
		end

		describe "PUT update" do
			describe "with valid params" do
				it "updates the requested profile_claim" do
					# Assuming there are no other profile_claims in the database, this
					# specifies that the newly created ProfileClaim
					# receives the :update_attributes message with whatever params are
					# submitted in the request as the admin role.
					expect_any_instance_of(ProfileClaim).to receive(:update_attributes).with(valid_attributes)
					put :update, {:id => profile_claim.to_param, :profile_claim => valid_attributes}
				end

				it "assigns the requested profile_claim as @profile_claim" do
					put :update, {:id => profile_claim.to_param, :profile_claim => valid_attributes}
					expect(assigns(:profile_claim)).to eq(profile_claim)
				end

				it "redirects to the profile_claim" do
					put :update, {:id => profile_claim.to_param, :profile_claim => valid_attributes}
					expect(response).to redirect_to(profile_claim)
				end
			end

			describe "with invalid params" do
				it "assigns the profile_claim as @profile_claim" do
					# Trigger the behavior that occurs when invalid params are submitted
					allow_any_instance_of(ProfileClaim).to receive(:update_attributes).and_return(false)
					put :update, {:id => profile_claim.to_param, :profile_claim => valid_attributes}
					expect(assigns(:profile_claim)).to eq(profile_claim)
				end

				it "re-renders the 'edit' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					allow_any_instance_of(ProfileClaim).to receive(:update_attributes).and_return(false)
					put :update, {:id => profile_claim.to_param, :profile_claim => valid_attributes}
					expect(response).to render_template("edit")
				end
			end
			
			describe "admin can modify attribute(s) that are protected from the default role" do
				it "can assign admin notes" do
					notes = 'Good notes.'
					expect {
						put :update, id: profile_claim.to_param, profile_claim: {admin_notes: notes}
					}.to change { profile_claim.reload.admin_notes }.from(profile_claim.admin_notes).to(notes)
				end
			end
		end

		describe "DELETE destroy" do
			it "destroys the requested profile_claim" do
				expect {
					delete :destroy, {:id => profile_claim.to_param}
				}.to change(ProfileClaim, :count).by(-1)
			end

			it "redirects to the profile_claim list" do
				delete :destroy, {:id => profile_claim.to_param}
				expect(response).to redirect_to(profile_claims_url)
			end
		end
	end
end
