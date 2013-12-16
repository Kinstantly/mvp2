require 'spec_helper'

describe ReviewsController do
	let(:unpublished_profile) { FactoryGirl.create :unpublished_profile }
	let(:published_profile) { FactoryGirl.create :published_profile }
	let(:review_attributes) {
		FactoryGirl.attributes_for :review, profile_id: published_profile.id, body: 'Que bueno, que bueno, que bueno!'
	}
	let(:review_by_parent) { FactoryGirl.create :review_by_parent }
	let(:parent) { review_by_parent.reviewer }
	let(:provider) { FactoryGirl.create :provider }
	let(:provider_with_published_profile) { FactoryGirl.create :provider, profile: published_profile }
	
	context "as a non-administrator attempting to access admin actions" do
		before(:each) do
			sign_in parent
		end

		describe "POST admin_create" do
			it "cannot create a review via the admin action" do
				count = User.find(parent.id).reviews_given.count
				post :admin_create,
					review: review_attributes.merge(reviewer_email: parent.email, reviewer_username: parent.username)
				response.should_not render_template('admin_create')
				User.find(parent.id).reviews_given.count.should == count
			end
		end
		
		describe "PUT admin_update" do
			it "cannot update a review via the admin action" do
				body = 'Best sweet potato pecan pie in the county!'
				put :admin_update, id: review_by_parent.id, review: review_attributes.merge(body: body)
				response.should_not render_template('admin_update')
				Review.find(review_by_parent.id).body.should_not == body
			end
		end
		
		describe "DELETE destroy" do
			it "cannot delete a review" do
				review = FactoryGirl.create :review_by_parent, reviewer: parent
				delete :destroy, id: review.id
				response.should_not redirect_to(controller: 'profiles', action: 'show', id: review.profile.id)
				Review.find_by_id(review.id).should_not be_nil
			end
		end
	end
	
	context "as admin user" do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'iris@example.com' }

		before (:each) do
			sign_in admin_user
		end

		describe "POST admin_create" do
			it "creates a review attached to a profile" do
				email, username = 'conchita@example.com', 'cbautista'
				post :admin_create, review: review_attributes.merge(reviewer_email: email, reviewer_username: username)
				response.should render_template('admin_create')
				(profile = assigns[:review].profile).should_not be_nil
				profile.should == published_profile
			end
			
			it "creates a review with a new reviewer" do
				email, username = 'conchita@example.com', 'cbautista'
				post :admin_create, review: review_attributes.merge(reviewer_email: email, reviewer_username: username)
				response.should render_template('admin_create')
				(reviewer = assigns[:review].reviewer).should_not be_nil
				reviewer.email.should == email
				reviewer.username.should == username
			end
			
			it "creates a review with an existing reviewer" do
				parent = FactoryGirl.create :parent
				post :admin_create, 
					review: review_attributes.merge(reviewer_email: parent.email, reviewer_username: parent.username)
				response.should render_template('admin_create')
				(reviewer = assigns[:review].reviewer).should_not be_nil
				reviewer.email.should == parent.email
			end
			
			it "creates a review with an existing provider as reviewer with no previous username" do
				provider = FactoryGirl.create :provider_with_no_username
				username = 'EnzoGrimaldo'
				post :admin_create,
					review: review_attributes.merge(reviewer_email: provider.email, reviewer_username: username)
				response.should render_template('admin_create')
				(reviewer = assigns[:review].reviewer).should_not be_nil
				reviewer.username.should == username
			end
		end
	
		describe "PUT admin_update" do
			it "updates a review" do
				body = 'Durme hermosa donzella'
				put :admin_update, id: review_by_parent.id, review: review_attributes.merge(body: body)
				response.should render_template('admin_update')
				assigns[:review].body.should == body
			end
			
			it "updates a review with a new reviewer" do
				email, username = 'amina@example.com', 'amina'
				put :admin_update, id: review_by_parent.id,
					review: review_attributes.merge(reviewer_email: email, reviewer_username: username)
				response.should render_template('admin_update')
				(reviewer = assigns[:review].reviewer).should_not be_nil
				reviewer.email.should == email
				reviewer.username.should == username
			end
		
			it "does not modify the reviewer username" do
				username = 'elvino'
				put :admin_update, id: review_by_parent.id,
					review: review_attributes.merge(reviewer_email: review_by_parent.reviewer.email, reviewer_username: username)
				response.should render_template('admin_update')
				(reviewer = assigns[:review].reviewer).should_not be_nil
				reviewer.username.should_not == username
				reviewer.username.should == review_by_parent.reviewer.username
			end
		end
		
		describe "DELETE destroy" do
			it "deletes a review" do
				review = FactoryGirl.create :review_by_parent
				delete :destroy, id: review.id
				response.should redirect_to(controller: 'profiles', action: 'show', id: review.profile.id)
				Review.find_by_id(review.id).should be_nil
			end
		end
	end

	context "as site visitor attempting to review a published profile" do
		describe "POST create" do
			it "cannot create a review without registration" do
				count = published_profile.reviews.count
				email, username = 'example@example.com', 'example'
				post :create,
					review: review_attributes.merge(reviewer_email: email, reviewer_username: username)
				response.should_not redirect_to(controller: 'profiles', action: 'show', id: published_profile.id)
				Profile.find(published_profile.id).reviews.count.should == count
			end
		end
	end

	context "as unconfirmed member attempting to review a published profile" do
		describe "POST create" do
			it "cannot create a review without registration" do
				sign_in parent
				parent.confirmed_at = nil
				parent.save
				count = published_profile.reviews.count
				post :create, review: review_attributes
				response.should_not redirect_to(controller: 'profiles', action: 'show', id: published_profile.id)
				Profile.find(published_profile.id).reviews.count.should == count
			end
		end
	end

	context "as a non-provider member" do
		describe "POST create" do
			it "creates a review attached to a profile" do
				sign_in parent
				post :create, review: review_attributes
				response.should redirect_to(controller: 'profiles', action: 'show', id: published_profile.id)
				(profile = assigns[:review].profile).should_not be_nil
				profile.should == published_profile
			end

			it "cannot create a review attached to an unpublished profile" do
				sign_in parent
				count = unpublished_profile.reviews.count
				post :create, review: review_attributes.merge(profile_id: unpublished_profile.id)
				response.should_not redirect_to(controller: 'profiles', action: 'show', id: unpublished_profile.id)
				Profile.find(unpublished_profile.id).reviews.count.should == count
			end
		end
	end

	context "as a provider" do
		describe "POST create" do
			it "allows review of another provider" do
				sign_in provider
				count = published_profile.reviews.count
				post :create, review: review_attributes
				response.should redirect_to(controller: 'profiles', action: 'show', id: published_profile.id)
				Profile.find(published_profile.id).reviews.count.should == (count + 1)
			end
			
			it "denies review of the selfsame provider" do
				sign_in provider_with_published_profile
				count = published_profile.reviews.count
				post :create, review: review_attributes
				response.should_not redirect_to(controller: 'profiles', action: 'show', id: published_profile.id)
				Profile.find(published_profile.id).reviews.count.should == count
			end
		end
	end
end
