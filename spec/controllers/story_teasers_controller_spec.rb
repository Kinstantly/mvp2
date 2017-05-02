require 'spec_helper'

RSpec.describe StoryTeasersController, :type => :controller do

	# This should return the minimal set of attributes required to create a valid StoryTeaser.
	let(:valid_attributes) {
		FactoryGirl.attributes_for :story_teaser
	}

	let(:invalid_attributes) {
		FactoryGirl.attributes_for :story_teaser, display_order: nil
	}

	let(:admin_user) { FactoryGirl.create :admin_user, email: 'elina@example.com' }
	
	before (:each) do
		sign_in admin_user
	end
	
	describe "GET #index" do
		it "assigns all story_teasers as @story_teasers" do
			story_teaser = StoryTeaser.create! valid_attributes
			get :index
			expect(assigns(:story_teasers)).to eq([story_teaser])
		end
	end

	describe "GET #show" do
		it "assigns the requested story_teaser as @story_teaser" do
			story_teaser = StoryTeaser.create! valid_attributes
			get :show, {:id => story_teaser.to_param}
			expect(assigns(:story_teaser)).to eq(story_teaser)
		end
	end

	describe "GET #new" do
		it "assigns a new story_teaser as @story_teaser" do
			get :new
			expect(assigns(:story_teaser)).to be_a_new(StoryTeaser)
		end
	end

	describe "GET #edit" do
		it "assigns the requested story_teaser as @story_teaser" do
			story_teaser = StoryTeaser.create! valid_attributes
			get :edit, {:id => story_teaser.to_param}
			expect(assigns(:story_teaser)).to eq(story_teaser)
		end
	end

	describe "POST #create" do
		context "with valid params" do
			it "creates a new StoryTeaser" do
				expect {
					post :create, {:story_teaser => valid_attributes}
				}.to change(StoryTeaser, :count).by(1)
			end

			it "assigns a newly created story_teaser as @story_teaser" do
				post :create, {:story_teaser => valid_attributes}
				expect(assigns(:story_teaser)).to be_a(StoryTeaser)
				expect(assigns(:story_teaser)).to be_persisted
			end

			it "redirects to the created story_teaser" do
				post :create, {:story_teaser => valid_attributes}
				expect(response).to redirect_to(StoryTeaser.last)
			end
		end

		context "with invalid params" do
			it "assigns a newly created but unsaved story_teaser as @story_teaser" do
				post :create, {:story_teaser => invalid_attributes}
				expect(assigns(:story_teaser)).to be_a_new(StoryTeaser)
			end

			it "re-renders the 'new' template" do
				post :create, {:story_teaser => invalid_attributes}
				expect(response).to render_template("new")
			end
		end
	end

	describe "PUT #update" do
		context "with valid params" do
			let(:new_attributes) {
				{title: 'Attics of My Life'}
			}

			it "updates the requested story_teaser" do
				story_teaser = StoryTeaser.create! valid_attributes
				put :update, {:id => story_teaser.to_param, :story_teaser => new_attributes}
				story_teaser.reload
				expect(assigns(:story_teaser).title).to eq(new_attributes[:title])
			end

			it "assigns the requested story_teaser as @story_teaser" do
				story_teaser = StoryTeaser.create! valid_attributes
				put :update, {:id => story_teaser.to_param, :story_teaser => valid_attributes}
				expect(assigns(:story_teaser)).to eq(story_teaser)
			end

			it "redirects to the story_teaser" do
				story_teaser = StoryTeaser.create! valid_attributes
				put :update, {:id => story_teaser.to_param, :story_teaser => valid_attributes}
				expect(response).to redirect_to(story_teaser)
			end
		end

		context "with invalid params" do
			it "assigns the story_teaser as @story_teaser" do
				story_teaser = StoryTeaser.create! valid_attributes
				put :update, {:id => story_teaser.to_param, :story_teaser => invalid_attributes}
				expect(assigns(:story_teaser)).to eq(story_teaser)
			end

			it "re-renders the 'edit' template" do
				story_teaser = StoryTeaser.create! valid_attributes
				put :update, {:id => story_teaser.to_param, :story_teaser => invalid_attributes}
				expect(response).to render_template("edit")
			end
		end
	end

	describe 'PATCH #activate' do
		it 'activates the story_teaser' do
			story_teaser = StoryTeaser.create! valid_attributes.merge(active: false)
			expect {
				patch :activate, id: story_teaser.to_param
			}.to change {
				StoryTeaser.active_only.count
			}.by 1
		end
	end

	describe 'PATCH #deactivate' do
		it 'deactivates the story_teaser' do
			story_teaser = StoryTeaser.create! valid_attributes.merge(active: true)
			expect {
				patch :deactivate, id: story_teaser.to_param
			}.to change {
				StoryTeaser.active_only.count
			}.by -1
		end
	end

	describe "DELETE #destroy" do
		it "destroys the requested story_teaser" do
			story_teaser = StoryTeaser.create! valid_attributes
			expect {
				delete :destroy, {:id => story_teaser.to_param}
			}.to change(StoryTeaser, :count).by(-1)
		end

		it "redirects to the story_teasers list" do
			story_teaser = StoryTeaser.create! valid_attributes
			delete :destroy, {:id => story_teaser.to_param}
			expect(response).to redirect_to(story_teasers_url)
		end
	end

end
