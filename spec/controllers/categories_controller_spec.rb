require 'spec_helper'

describe CategoriesController do

	# This should return at least the minimal set of attributes required to create a valid Category.
	let (:valid_attributes) { FactoryGirl.attributes_for :category }

	let(:category) { FactoryGirl.create :category }

	context "not signed in" do
		describe "GET index" do
			it "cannot view categories" do
				get :index
				assigns(:categories).should be_nil
			end
		end

		describe "GET new" do
			it "cannot get a new category" do
				get :new
				assigns(:category).should be_nil
			end
		end

		describe "GET edit" do
			it "cannot get a category to edit" do
				get :edit, id: category.to_param
				assigns(:category).should be_nil
			end
		end

		describe "POST create" do
			it "cannot create a new Category" do
				expect {
					post :create, category: valid_attributes
				}.to change(Category, :count).by(0)
			end
		end


		describe "PUT update" do
			it "cannot update a category" do
				put :update, {id: category.to_param, category: valid_attributes}
				assigns(:category).should be_nil
			end
		end

		describe "DELETE destroy" do
			it "cannot destroy the requested category" do
				# First instantiate a category.
				id = category.to_param
				expect {
					delete :destroy, id: id
				}.to change(Category, :count).by(0)
			end
		end
	end

	context "as admin user" do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'elina@example.com' }

		before (:each) do
			category # Make sure a persistent category exists.
			sign_in admin_user
		end

		describe "GET index" do
			it "assigns all categories as @categories" do
				get :index
				Category.all.each do |cat|
					assigns(:categories).should include(cat)
				end
			end
		end

		describe "GET new" do
			it "assigns a new category as @category" do
				get :new
				assigns(:category).should be_a_new(Category)
			end
		end

		describe "GET edit" do
			it "assigns the requested category as @category" do
				get :edit, id: category.to_param
				assigns(:category).should eq(category)
			end
		end

		describe "POST create" do
			describe "with valid params" do
				it "creates a new Category" do
					expect {
						post :create, category: valid_attributes
					}.to change(Category, :count).by(1)
				end

				it "assigns a newly created category as @category" do
					post :create, category: valid_attributes
					assigns(:category).should be_a(Category)
					assigns(:category).should be_persisted
				end

				it "redirects to the edit page for the created category" do
					post :create, category: valid_attributes
					response.should redirect_to(edit_category_url Category.last)
				end
			end

			describe "with invalid params" do
				it "assigns a newly created but unsaved category as @category" do
					# Trigger the behavior that occurs when invalid params are submitted
					Category.any_instance.stub(:save).and_return(false)
					post :create, category: {}
					assigns(:category).should be_a_new(Category)
				end

				it "re-renders the 'new' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					Category.any_instance.stub(:save).and_return(false)
					post :create, category: {}
					response.should render_template("new")
				end
			end
		end

		describe "PUT update" do
			describe "with valid params" do
				it "updates the requested category" do
					# Assuming there are no other categories in the database, this specifies that category
					# receives the :update_attributes message with whatever params are submitted in the request.
					Category.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
					put :update, {id: category.to_param, category: {'these' => 'params'}}
				end

				it "assigns the requested category as @category" do
					put :update, {id: category.to_param, category: valid_attributes}
					assigns(:category).should eq(category)
				end

				it "redirects to the category" do
					put :update, {id: category.to_param, category: valid_attributes}
					response.should redirect_to(edit_category_url category)
				end
			end

			describe "with invalid params" do
				it "assigns the category as @category" do
					# Trigger the behavior that occurs when invalid params are submitted
					Category.any_instance.stub(:save).and_return(false)
					put :update, {id: category.to_param, category: {}}
					assigns(:category).should eq(category)
				end

				it "re-renders the 'edit' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					Category.any_instance.stub(:save).and_return(false)
					put :update, {id: category.to_param, category: {}}
					response.should render_template("edit")
				end
			end
		end

		describe "DELETE destroy" do
			it "destroys the requested category" do
				expect {
					delete :destroy, id: category.to_param
				}.to change(Category, :count).by(-1)
			end

			it "redirects to the categories list" do
				delete :destroy, id: category.to_param
				response.should redirect_to(categories_url)
			end
		end
		
		describe "PUT add_subcategory" do
			it "redirects to the category" do
				put :add_subcategory, id: category.to_param, name: 'Australian Music Instruction'
				response.should redirect_to(edit_category_url category)
			end

			it "adds a subcategory" do
				subcategory = FactoryGirl.create :subcategory, name: 'Outback Activities'
				put :add_subcategory, id: category.to_param, name: subcategory.name
				assigns(:category).subcategories.should include(subcategory)
			end

			it "adds an existing subcategory" do
				subcategory = FactoryGirl.create :subcategory, name: 'Desert Opera'
				expect {
					put :add_subcategory, id: category.to_param, name: subcategory.name
				}.to change(Subcategory, :count).by(0)
			end

			it "adds an existing subcategory with a display order" do
				subcategory = FactoryGirl.create :subcategory, name: 'Violetta Divas'
				order = 5
				put :add_subcategory, id: category.to_param, name: subcategory.name, subcategory_display_order: order
				assigns(:category).category_subcategory(subcategory).subcategory_display_order.should eq(order)
			end
			
			it "creates a subcategory" do
				expect {
					put :add_subcategory, id: category.to_param, name: 'Vegemite Recipes'
				}.to change(Subcategory, :count).by(1)
			end
			
			it "adds a created subcategory" do
				name = 'Didgeridoo Clubs'
				put :add_subcategory, id: category.to_param, name: name
				assigns(:category).subcategories.should include(Subcategory.find_by_name name)
			end
			
			it "does not add a duplicate subcategory" do
				name = 'Roo Zoos'
				expect {
					put :add_subcategory, id: category.to_param, name: name
					put :add_subcategory, id: category.to_param, name: name
				}.to change(category.subcategories, :count).by(1)
			end
		end
		
		describe "PUT update_subcategory" do
			let(:subcategory) { FactoryGirl.create :subcategory, name: 'Billabongs' }
			let(:display_order) { 7 }
			
			before(:each) do
				category.subcategories << subcategory
			end
			
			it "redirects to the category" do
				put :update_subcategory, id: category.to_param, subcategory_id: subcategory.to_param, subcategory_display_order: display_order
				response.should redirect_to(edit_category_url category)
			end
			
			it "modifies the display order of a subcategory" do
				put :update_subcategory, id: category.to_param, subcategory_id: subcategory.to_param, subcategory_display_order: display_order
				assigns(:category).category_subcategory(subcategory).subcategory_display_order.should eq(display_order)
			end
		end
		
		describe "PUT remove_subcategory" do
			let(:subcategory) { FactoryGirl.create :subcategory, name: 'How to Lean on the Everlasting Arms' }
			
			before(:each) do
				category.subcategories << subcategory
			end
			
			it "redirects to the category" do
				put :remove_subcategory, id: category.to_param, subcategory_id: subcategory.to_param
				response.should redirect_to(edit_category_url category)
			end

			it "removes a subcategory" do
				put :remove_subcategory, id: category.to_param, subcategory_id: subcategory.to_param
				assigns(:category).subcategories.should_not include(subcategory)
			end
		end
	end
end