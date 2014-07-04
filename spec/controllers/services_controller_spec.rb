require 'spec_helper'

describe ServicesController do

	# This should return at least the minimal set of attributes required to create a valid Service.
	let (:valid_attributes) { FactoryGirl.attributes_for :service }

	let(:service) { FactoryGirl.create :service }

	context "not signed in" do
		describe "GET index" do
			it "cannot view services" do
				get :index
				assigns(:services).should be_nil
			end
		end

		describe "GET new" do
			it "cannot get a new service" do
				get :new
				assigns(:service).should be_nil
			end
		end

		describe "GET edit" do
			it "cannot get a service to edit" do
				get :edit, id: service.to_param
				assigns(:service).should be_nil
			end
		end

		describe "POST create" do
			it "cannot create a new Service" do
				expect {
					post :create, service: valid_attributes
				}.to change(Service, :count).by(0)
			end
		end


		describe "PUT update" do
			it "cannot update a service" do
				put :update, {id: service.to_param, service: valid_attributes}
				assigns(:service).should be_nil
			end
		end

		describe "DELETE destroy" do
			it "cannot destroy the requested service" do
				# First instantiate a service.
				id = service.to_param
				expect {
					delete :destroy, id: id
				}.to change(Service, :count).by(0)
			end
		end
	end

	context "as admin user" do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'fairuz@example.com' }

		before (:each) do
			service # Make sure a persistent service exists.
			sign_in admin_user
		end

		describe "GET index" do
			it "assigns all services as @services" do
				get :index
				Service.all.each do |svc|
					assigns(:services).should include(svc)
				end
			end
		end

		describe "GET new" do
			it "assigns a new service as @service" do
				get :new
				assigns(:service).should be_a_new(Service)
			end
		end

		describe "GET edit" do
			it "assigns the requested service as @service" do
				get :edit, id: service.to_param
				assigns(:service).should eq(service)
			end
		end

		describe "POST create" do
			describe "with valid params" do
				it "creates a new Service" do
					expect {
						post :create, service: valid_attributes
					}.to change(Service, :count).by(1)
				end

				it "assigns a newly created service as @service" do
					post :create, service: valid_attributes
					assigns(:service).should be_a(Service)
					assigns(:service).should be_persisted
				end

				it "redirects to the edit page for the created service" do
					post :create, service: valid_attributes
					response.should redirect_to(edit_service_url Service.last)
				end
			end

			describe "with invalid params" do
				it "assigns a newly created but unsaved service as @service" do
					# Trigger the behavior that occurs when invalid params are submitted
					Service.any_instance.stub(:save).and_return(false)
					post :create, service: {}
					assigns(:service).should be_a_new(Service)
				end

				it "re-renders the 'new' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					Service.any_instance.stub(:save).and_return(false)
					post :create, service: {}
					response.should render_template("new")
				end
			end
		end

		describe "PUT update" do
			describe "with valid params" do
				it "updates the requested service" do
					# Assuming there are no other services in the database, this specifies that service
					# receives the :update_attributes message with whatever params are submitted in the request.
					Service.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
					put :update, {id: service.to_param, service: {'these' => 'params'}}
				end

				it "assigns the requested service as @service" do
					put :update, {id: service.to_param, service: valid_attributes}
					assigns(:service).should eq(service)
				end

				it "redirects to the service" do
					put :update, {id: service.to_param, service: valid_attributes}
					response.should redirect_to(edit_service_url service)
				end
			end

			describe "with invalid params" do
				it "assigns the service as @service" do
					# Trigger the behavior that occurs when invalid params are submitted
					Service.any_instance.stub(:save).and_return(false)
					put :update, {id: service.to_param, service: {}}
					assigns(:service).should eq(service)
				end

				it "re-renders the 'edit' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					Service.any_instance.stub(:save).and_return(false)
					put :update, {id: service.to_param, service: {}}
					response.should render_template("edit")
				end
			end
		end

		describe "DELETE destroy" do
			it "destroys the requested service" do
				expect {
					delete :destroy, id: service.to_param
				}.to change(Service, :count).by(-1)
			end

			it "redirects to the services list" do
				delete :destroy, id: service.to_param
				response.should redirect_to(services_url)
			end
		end
	end
end