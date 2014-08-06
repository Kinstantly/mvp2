require 'spec_helper'

describe ProfileClaimsController do
  let(:profile_claim) { FactoryGirl.create :profile_claim }
  let (:valid_attributes) { FactoryGirl.attributes_for :profile_claim}
  let(:published_profile) { FactoryGirl.create :published_profile }
  
  context "as not signed-in user" do
    describe "GET new" do
      it "assigns a new profile_claim as @profile_claim" do
        get :new, id: published_profile.id
        assigns(:profile_claim).should be_a_new(ProfileClaim)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new ProfileClaim" do
          valid_attributes.merge(profile_id: published_profile.id)
          Rails.logger.debug valid_attributes
          Rails.logger.debug "valid_attributes"
          expect {
            post :create, {:profile_claim => valid_attributes, :profile_id => published_profile.id}
          }.to change(ProfileClaim, :count).by(1)
        end

        it "assigns a newly created profile_claim as @profile_claim" do
          valid_attributes.merge(profile_id: published_profile.id)
          post :create, {:profile_claim => valid_attributes, :profile_id => published_profile.id}
          assigns(:profile_claim).should be_a(ProfileClaim)
          assigns(:profile_claim).should be_persisted
        end

        it "redirects to the created profile_claim" do
          post :create, {:profile_claim => valid_attributes}
          response.should render_template('create')
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved profile_claim as @profile_claim" do
          # Trigger the behavior that occurs when invalid params are submitted
          ProfileClaim.any_instance.stub(:save).and_return(false)
          post :create, {:profile_claim => {}}
          assigns(:profile_claim).should be_a_new(ProfileClaim)
        end

        it "renders the 'create' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          ProfileClaim.any_instance.stub(:save).and_return(false)
          post :create, {:ProfileClaim => {}}
          response.should render_template('create')
        end
      end
      
      describe "attempting to modify protected attribute(s)" do
        it "cannot assign admin notes" do
          expect {
            post :create, profile_claim: valid_attributes.merge(admin_notes: 'Sneaky notes.')
          }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
        end

        it "cannot assign the claimant" do
          claimant = FactoryGirl.create :parent
          expect {
            post :create, profile_claim: valid_attributes.merge(claimant_id: claimant.to_param)
          }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
        end

        it "cannot assign profile" do
          profile = FactoryGirl.create :profile
          expect {
            post :create, profile_claim: valid_attributes.merge(profile_id: profile.to_param)
          }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
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
        post :create, {:profile_claim => valid_attributes}
        assigns[:profile_claim].claimant.should eq(user)
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
        assigns(:profile_claims).should eq([profile_claim])
      end
    end

    describe "GET show" do
      it "assigns the requested profile_claim as @profile_claim" do
        get :show, {:id => profile_claim.to_param}
        assigns(:profile_claim).should eq(profile_claim)
      end
    end

    describe "GET edit" do
      it "assigns the requested profile_claim as @profile_claim" do
        get :edit, {:id => profile_claim.to_param}
        assigns(:profile_claim).should eq(profile_claim)
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested profile_claim" do
          # Assuming there are no other profile_claims in the database, this
          # specifies that the newly created ProfileClaim
          # receives the :update_attributes message with whatever params are
          # submitted in the request as the admin role.
          ProfileClaim.any_instance.should_receive(:update_attributes).with({'these' => 'params'}, {as: :admin})
          put :update, {:id => profile_claim.to_param, :profile_claim => {'these' => 'params'}}
        end

        it "assigns the requested profile_claim as @profile_claim" do
          put :update, {:id => profile_claim.to_param, :profile_claim => valid_attributes}
          assigns(:profile_claim).should eq(profile_claim)
        end

        it "redirects to the profile_claim" do
          put :update, {:id => profile_claim.to_param, :profile_claim => valid_attributes}
          response.should redirect_to(profile_claim)
        end
      end

      describe "with invalid params" do
        it "assigns the profile_claim as @profile_claim" do
          # Trigger the behavior that occurs when invalid params are submitted
          ProfileClaim.any_instance.stub(:save).and_return(false)
          put :update, {:id => profile_claim.to_param, :profile_claim => {}}
          assigns(:profile_claim).should eq(profile_claim)
        end

        it "re-renders the 'edit' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          ProfileClaim.any_instance.stub(:update_attributes).and_return(false)
          put :update, {:id => profile_claim.to_param, :profile_claim => {}}
          response.should render_template("edit")
        end
      end
      
      describe "admin can modify attribute(s) that are protected from the default role" do
        it "can assign admin notes" do
          expect {
            put :update, id: profile_claim.to_param, profile_claim: {admin_notes: 'Good notes.'}
          }.to_not raise_error(ActiveModel::MassAssignmentSecurity::Error)
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
        response.should redirect_to(profile_claims_url)
      end
    end
  end
end
