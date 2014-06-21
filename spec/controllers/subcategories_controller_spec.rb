require 'spec_helper'

describe SubcategoriesController do

	# This should return at least the minimal set of attributes required to create a valid Subcategory.
	let (:valid_attributes) { FactoryGirl.attributes_for :subcategory }

	let(:subcategory) { FactoryGirl.create :subcategory }

	context "not signed in" do
		describe "GET index" do
			it "cannot view subcategories" do
				get :index
				assigns(:subcategories).should be_nil
			end
		end

		describe "GET new" do
			it "cannot get a new subcategory" do
				get :new
				assigns(:subcategory).should be_nil
			end
		end

		describe "GET edit" do
			it "cannot get a subcategory to edit" do
				get :edit, id: subcategory.to_param
				assigns(:subcategory).should be_nil
			end
		end

		describe "POST create" do
			it "cannot create a new Subcategory" do
				expect {
					post :create, subcategory: valid_attributes
				}.to change(Subcategory, :count).by(0)
			end
		end


		describe "PUT update" do
			it "cannot update a subcategory" do
				put :update, {id: subcategory.to_param, subcategory: valid_attributes}
				assigns(:subcategory).should be_nil
			end
		end

		describe "DELETE destroy" do
			it "cannot destroy the requested subcategory" do
				# First instantiate a subcategory.
				id = subcategory.to_param
				expect {
					delete :destroy, id: id
				}.to change(Subcategory, :count).by(0)
			end
		end
	end

	context "as admin user" do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'iris@example.com' }

		before (:each) do
			subcategory # Make sure a persistent subcategory exists.
			sign_in admin_user
		end

		describe "GET index" do
			it "assigns all subcategories as @subcategories" do
				get :index
				assigns(:subcategories).should eq([subcategory])
			end
		end

		describe "GET new" do
			it "assigns a new subcategory as @subcategory" do
				get :new
				assigns(:subcategory).should be_a_new(Subcategory)
			end
		end

		describe "GET edit" do
			it "assigns the requested subcategory as @subcategory" do
				get :edit, id: subcategory.to_param
				assigns(:subcategory).should eq(subcategory)
			end
		end

		describe "POST create" do
			describe "with valid params" do
				it "creates a new Subcategory" do
					expect {
						post :create, subcategory: valid_attributes
					}.to change(Subcategory, :count).by(1)
				end

				it "assigns a newly created subcategory as @subcategory" do
					post :create, subcategory: valid_attributes
					assigns(:subcategory).should be_a(Subcategory)
					assigns(:subcategory).should be_persisted
				end

				it "redirects to the edit page for the created subcategory" do
					post :create, subcategory: valid_attributes
					response.should redirect_to(edit_subcategory_url Subcategory.last)
				end
			end

			describe "with invalid params" do
				it "assigns a newly created but unsaved subcategory as @subcategory" do
					# Trigger the behavior that occurs when invalid params are submitted
					Subcategory.any_instance.stub(:save).and_return(false)
					post :create, subcategory: {}
					assigns(:subcategory).should be_a_new(Subcategory)
				end

				it "re-renders the 'new' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					Subcategory.any_instance.stub(:save).and_return(false)
					post :create, subcategory: {}
					response.should render_template("new")
				end
			end
		end

		describe "PUT update" do
			describe "with valid params" do
				it "updates the requested subcategory" do
					# Assuming there are no other subcategories in the database, this specifies that subcategory
					# receives the :update_attributes message with whatever params are submitted in the request.
					Subcategory.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
					put :update, {id: subcategory.to_param, subcategory: {'these' => 'params'}}
				end

				it "assigns the requested subcategory as @subcategory" do
					put :update, {id: subcategory.to_param, subcategory: valid_attributes}
					assigns(:subcategory).should eq(subcategory)
				end

				it "redirects to the subcategory" do
					put :update, {id: subcategory.to_param, subcategory: valid_attributes}
					response.should redirect_to(edit_subcategory_url subcategory)
				end
			end

			describe "with invalid params" do
				it "assigns the subcategory as @subcategory" do
					# Trigger the behavior that occurs when invalid params are submitted
					Subcategory.any_instance.stub(:save).and_return(false)
					put :update, {id: subcategory.to_param, subcategory: {}}
					assigns(:subcategory).should eq(subcategory)
				end

				it "re-renders the 'edit' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					Subcategory.any_instance.stub(:save).and_return(false)
					put :update, {id: subcategory.to_param, subcategory: {}}
					response.should render_template("edit")
				end
			end
		end

		describe "DELETE destroy" do
			it "destroys the requested subcategory" do
				expect {
					delete :destroy, id: subcategory.to_param
				}.to change(Subcategory, :count).by(-1)
			end

			it "redirects to the subcategories list" do
				delete :destroy, id: subcategory.to_param
				response.should redirect_to(subcategories_url)
			end
		end
		
		describe "PUT add_service" do
			it "redirects to the subcategory" do
				put :add_service, id: subcategory.to_param, name: 'Didgeridoo instructor'
				response.should redirect_to(edit_subcategory_url subcategory)
			end

			it "adds a service" do
				service = FactoryGirl.create :service, name: 'Guitar teacher'
				put :add_service, id: subcategory.to_param, name: service.name
				assigns(:subcategory).services.should include(service)
			end

			it "adds an existing service" do
				service = FactoryGirl.create :service, name: 'Guitar teacher'
				expect {
					put :add_service, id: subcategory.to_param, name: service.name
				}.to change(Service, :count).by(0)
			end

			it "adds an existing service with a display order" do
				service = FactoryGirl.create :service, name: 'Guitar teacher'
				order = 5
				put :add_service, id: subcategory.to_param, name: service.name, service_display_order: order
				assigns(:subcategory).service_subcategory(service).service_display_order.should eq(order)
			end
			
			it "creates a service" do
				expect {
					put :add_service, id: subcategory.to_param, name: 'Piano teacher'
				}.to change(Service, :count).by(1)
			end
			
			it "adds a created service" do
				name = 'Mandolin teacher'
				put :add_service, id: subcategory.to_param, name: name
				assigns(:subcategory).services.should include(Service.find_by_name name)
			end
			
			it "does not add a duplicate service" do
				name = 'Unique music teacher'
				expect {
					put :add_service, id: subcategory.to_param, name: name
					put :add_service, id: subcategory.to_param, name: name
				}.to change(subcategory.services, :count).by(1)
			end
		end
		
		describe "PUT update_service" do
			let(:service) { FactoryGirl.create :service, name: 'Shpongle teacher' }
			let(:display_order) { 7 }
			
			before(:each) do
				subcategory.services << service
			end
			
			it "redirects to the subcategory" do
				put :update_service, id: subcategory.to_param, service_id: service.to_param, service_display_order: display_order
				response.should redirect_to(edit_subcategory_url subcategory)
			end
			
			it "modifies the display order of a service" do
				put :update_service, id: subcategory.to_param, service_id: service.to_param, service_display_order: display_order
				assigns(:subcategory).service_subcategory(service).service_display_order.should eq(display_order)
			end
		end
		
		describe "PUT remove_service" do
			let(:service) { FactoryGirl.create :service, name: 'Shpongle teacher' }
			
			before(:each) do
				subcategory.services << service
			end
			
			it "redirects to the subcategory" do
				put :remove_service, id: subcategory.to_param, service_id: service.to_param
				response.should redirect_to(edit_subcategory_url subcategory)
			end

			it "removes a service" do
				put :remove_service, id: subcategory.to_param, service_id: service.to_param
				assigns(:subcategory).services.should_not include(service)
			end
		end
	end
end
