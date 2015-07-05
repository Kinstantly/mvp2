require 'spec_helper'

describe ReviewsController, :type => :controller do
	let(:unpublished_profile) { FactoryGirl.create :unpublished_profile }
	let(:published_profile) { FactoryGirl.create :published_profile }
	let(:review_attributes) {
		FactoryGirl.attributes_for :review, profile_id: published_profile.id, body: 'Que bueno, que bueno, que bueno!'
	}
	let(:review_by_parent) { FactoryGirl.create :review_by_parent }
	let(:parent) { review_by_parent.reviewer }
	let(:provider) { FactoryGirl.create :provider, username: 'ProviderWhoReviews' }
	let(:provider_with_published_profile) { FactoryGirl.create :provider, profile: published_profile }
	
	context "as a non-administrator attempting to access admin actions" do
		before(:example) do
			sign_in parent
		end

		describe "POST admin_create" do
			it "cannot create a review via the admin action" do
				count = User.find(parent.id).reviews_given.count
				post :admin_create,
					review: review_attributes.merge(reviewer_email: parent.email, reviewer_username: parent.username)
				expect(response).not_to render_template('admin_create')
				expect(User.find(parent.id).reviews_given.count).to eq count
			end
		end
		
		describe "PUT admin_update" do
			it "cannot update a review via the admin action" do
				body = 'Best sweet potato pecan pie in the county!'
				put :admin_update, id: review_by_parent.id, review: review_attributes.merge(body: body)
				expect(response).not_to render_template('admin_update')
				expect(Review.find(review_by_parent.id).body).not_to eq body
			end
		end
		
		describe "DELETE destroy" do
			it "cannot delete a review" do
				review = FactoryGirl.create :review_by_parent, reviewer: parent
				delete :destroy, id: review.id
				expect(response).not_to redirect_to(controller: 'profiles', action: 'show', id: review.profile.id)
				expect(Review.find_by_id(review.id)).not_to be_nil
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
				expect(response).to render_template('admin_create')
				expect(profile = assigns[:review].profile).not_to be_nil
				expect(profile).to eq published_profile
			end
			
			it "creates a review with a new reviewer" do
				email, username = 'conchita@example.com', 'cbautista'
				post :admin_create, review: review_attributes.merge(reviewer_email: email, reviewer_username: username)
				expect(response).to render_template('admin_create')
				expect(reviewer = assigns[:review].reviewer).not_to be_nil
				expect(reviewer.email).to eq email
				expect(reviewer.username).to eq username
			end
			
			it "creates a review with an existing reviewer" do
				parent = FactoryGirl.create :parent
				post :admin_create, 
					review: review_attributes.merge(reviewer_email: parent.email, reviewer_username: parent.username)
				expect(response).to render_template('admin_create')
				expect(reviewer = assigns[:review].reviewer).not_to be_nil
				expect(reviewer.email).to eq parent.email
			end
			
			it "creates a review with an existing provider as reviewer with no previous username" do
				provider = FactoryGirl.create :provider_with_no_username
				username = 'EnzoGrimaldo'
				post :admin_create,
					review: review_attributes.merge(reviewer_email: provider.email, reviewer_username: username)
				expect(response).to render_template('admin_create')
				expect(reviewer = assigns[:review].reviewer).not_to be_nil
				expect(reviewer.username).to eq username
			end
		end
	
		describe "PUT admin_update" do
			it "updates a review" do
				body = 'Durme hermosa donzella'
				put :admin_update, id: review_by_parent.id, review: review_attributes.merge(body: body)
				expect(response).to render_template('admin_update')
				expect(assigns[:review].body).to eq body
			end
			
			it "updates a review with a new reviewer" do
				email, username = 'amina@example.com', 'amina'
				put :admin_update, id: review_by_parent.id,
					review: review_attributes.merge(reviewer_email: email, reviewer_username: username)
				expect(response).to render_template('admin_update')
				expect(reviewer = assigns[:review].reviewer).not_to be_nil
				expect(reviewer.email).to eq email
				expect(reviewer.username).to eq username
			end
		
			it "does not modify the reviewer username" do
				username = 'elvino'
				put :admin_update, id: review_by_parent.id,
					review: review_attributes.merge(reviewer_email: review_by_parent.reviewer.email, reviewer_username: username)
				expect(response).to render_template('admin_update')
				expect(reviewer = assigns[:review].reviewer).not_to be_nil
				expect(reviewer.username).not_to eq username
				expect(reviewer.username).to eq review_by_parent.reviewer.username
			end
		end
		
		describe "DELETE destroy" do
			it "deletes a review" do
				review = FactoryGirl.create :review_by_parent
				delete :destroy, id: review.id
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: review.profile.id)
				expect(Review.find_by_id(review.id)).to be_nil
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
				expect(response).not_to redirect_to(controller: 'profiles', action: 'show', id: published_profile.id)
				expect(Profile.find(published_profile.id).reviews.count).to eq count
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
				expect(response).not_to redirect_to(controller: 'profiles', action: 'show', id: published_profile.id)
				expect(Profile.find(published_profile.id).reviews.count).to eq count
			end
		end
	end

	context "as a non-provider member" do
		describe "POST create" do
			it "creates a review attached to a profile" do
				sign_in parent
				post :create, review: review_attributes
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: published_profile.id)
				expect(profile = assigns[:review].profile).not_to be_nil
				expect(profile).to eq published_profile
			end

			it "cannot create a review attached to an unpublished profile" do
				sign_in parent
				count = unpublished_profile.reviews.count
				post :create, review: review_attributes.merge(profile_id: unpublished_profile.id)
				expect(response).not_to redirect_to(controller: 'profiles', action: 'show', id: unpublished_profile.id)
				expect(Profile.find(unpublished_profile.id).reviews.count).to eq count
			end
		end
	end

	context "as a provider" do
		describe "POST create" do
			it "allows review of another provider" do
				sign_in provider
				count = published_profile.reviews.count
				post :create, review: review_attributes
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: published_profile.id)
				expect(Profile.find(published_profile.id).reviews.count).to eq(count + 1)
			end
			
			it "denies review of the selfsame provider" do
				sign_in provider_with_published_profile
				count = published_profile.reviews.count
				post :create, review: review_attributes
				expect(response).not_to redirect_to(controller: 'profiles', action: 'show', id: published_profile.id)
				expect(Profile.find(published_profile.id).reviews.count).to eq count
			end
		end
	end
end
