require 'spec_helper'

describe ContactBlockersController, :type => :controller do

	# This should return at least the minimal set of attributes required to create a valid ContactBlocker.
	let (:valid_attributes) { FactoryGirl.attributes_for :contact_blocker }
	let (:valid_attributes_with_email_delivery) { FactoryGirl.attributes_for :contact_blocker_with_email_delivery }

	let(:contact_blocker) { FactoryGirl.create :contact_blocker }
	let(:contact_blocker_with_email_delivery) { FactoryGirl.create :contact_blocker_with_email_delivery }
	let(:email_delivery) { FactoryGirl.create :email_delivery }

	context "recipient unsubscribing; not signed in" do
		describe "GET new_from_email_delivery" do
			it "assigns a new contact_blocker as @contact_blocker" do
				get :new_from_email_delivery, email_delivery_token: email_delivery.token
				expect(assigns(:contact_blocker)).to be_a_new(ContactBlocker)
			end

			it "new contact_blocker is associated with an email delivery" do
				get :new_from_email_delivery, email_delivery_token: email_delivery.token
				expect(assigns(:contact_blocker).email_delivery).to be_present
			end
			
			it "goes to recovery page with invalid email delivery token" do
				get :new_from_email_delivery, email_delivery_token: email_delivery.token+'a'
				expect(response).to redirect_to email_delivery_not_found_url
			end
		end

		describe "POST create_from_email_delivery" do
			describe "with valid params" do
				it "creates one new ContactBlocker if recipient is blocking the email delivered to" do
					expect {
						post :create_from_email_delivery, email_delivery_token: email_delivery.token, contact_blocker: valid_attributes_with_email_delivery.merge(email: email_delivery.recipient)
					}.to change(ContactBlocker, :count).by(1)
				end

				it "creates two new ContactBlockers if recipient is blocking an email other than the one delivered to" do
					expect {
						post :create_from_email_delivery, email_delivery_token: email_delivery.token, contact_blocker: valid_attributes_with_email_delivery.merge(email: 'Other'+email_delivery.recipient)
					}.to change(ContactBlocker, :count).by(2)
				end

				it "assigns a newly created contact_blocker as @contact_blocker" do
					post :create_from_email_delivery, email_delivery_token: email_delivery.token, contact_blocker: valid_attributes_with_email_delivery
					expect(assigns(:contact_blocker)).to be_a(ContactBlocker)
					expect(assigns(:contact_blocker)).to be_persisted
				end

				it "redirects to the confirmation view" do
					post :create_from_email_delivery, email_delivery_token: email_delivery.token, contact_blocker: valid_attributes_with_email_delivery
					expect(response).to redirect_to contact_blocker_confirmation_url
				end
			end

			describe "with invalid params" do
				it "assigns a newly created but unsaved contact_blocker as @contact_blocker" do
					# Trigger the behavior that occurs when invalid params are submitted
					allow_any_instance_of(ContactBlocker).to receive(:update_attributes_from_email_delivery).and_return(false)
					post :create_from_email_delivery, email_delivery_token: email_delivery.token, contact_blocker: valid_attributes
					expect(assigns(:contact_blocker)).to be_a_new(ContactBlocker)
				end

				it "renders the 'new_from_email_delivery' template" do
					# Trigger the behavior that occurs when invalid params are submitted
					allow_any_instance_of(ContactBlocker).to receive(:update_attributes_from_email_delivery).and_return(false)
					post :create_from_email_delivery, email_delivery_token: email_delivery.token, contact_blocker: valid_attributes
					expect(response).to render_template('new_from_email_delivery')
				end
			end
			
			describe "attempting to modify protected attribute(s)" do
				let(:correct_email_delivery) {
					FactoryGirl.create :email_delivery, recipient: 'one@example.org', token: 'tokenone'
				}
				let(:incorrect_email_delivery) {
					FactoryGirl.create :email_delivery, recipient: 'two@example.org', token: 'tokentwo'
				}
				
				it "can assign the email delivery token (proof of test)" do
					expect {
						post :create_from_email_delivery, email_delivery_token: correct_email_delivery.token,
							contact_blocker: valid_attributes.merge(email: correct_email_delivery.recipient)
					}.to change(ContactBlocker.where(email_delivery_id: correct_email_delivery), :count).by(1)
				end
				
				it "cannot assign the email delivery record" do
					expect {
						post :create_from_email_delivery, email_delivery_token: correct_email_delivery.token,
							contact_blocker: valid_attributes_with_email_delivery.merge(email_delivery_id: incorrect_email_delivery.to_param)
					}.to change(ContactBlocker.where(email_delivery_id: incorrect_email_delivery), :count).by(0)
				end
			end
		end
	end

	context "as admin user" do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'iris@example.com' }

		before (:each) do
			sign_in admin_user
		end
		
		context "creating a new record manually" do
			describe "GET new" do
				it "assigns a new contact_blocker as @contact_blocker" do
					get :new
					expect(assigns(:contact_blocker)).to be_a_new(ContactBlocker)
				end
			end

			describe "POST create" do
				describe "with valid params" do
					it "creates a new ContactBlocker" do
						expect {
							post :create, {contact_blocker: valid_attributes}
						}.to change(ContactBlocker, :count).by(1)
					end

					it "assigns a newly created contact_blocker as @contact_blocker" do
						post :create, {contact_blocker: valid_attributes}
						expect(assigns(:contact_blocker)).to be_a(ContactBlocker)
						expect(assigns(:contact_blocker)).to be_persisted
					end

					it "redirects to the created contact_blocker" do
						post :create, {contact_blocker: valid_attributes}
						expect(response).to redirect_to ContactBlocker.order('id').last
					end
				end

				describe "with invalid params" do
					it "assigns a newly created but unsaved contact_blocker as @contact_blocker" do
						# Trigger the behavior that occurs when invalid params are submitted
						allow_any_instance_of(ContactBlocker).to receive(:save).and_return(false)
						post :create, {contact_blocker: valid_attributes}
						expect(assigns(:contact_blocker)).to be_a_new(ContactBlocker)
					end

					it "renders the 'new' template" do
						# Trigger the behavior that occurs when invalid params are submitted
						allow_any_instance_of(ContactBlocker).to receive(:save).and_return(false)
						post :create, {contact_blocker: valid_attributes}
						expect(response).to render_template 'new'
					end
				end
			
				describe "attempting to modify protected attribute(s)" do
					it "cannot assign the email delivery record" do
						expect {
							post :create, contact_blocker: valid_attributes.merge(email_delivery_id: email_delivery.to_param)
						}.to change(ContactBlocker.where(email_delivery_id: email_delivery), :count).by(0)
					end
				end
			end
		end
		
		context "editing existing records" do
			before (:each) do
				contact_blocker # Make sure a persistent contact_blocker exists.
			end
		
			describe "GET index" do
				it "assigns all contact_blockers as @contact_blockers" do
					get :index
					expect(assigns(:contact_blockers)).to eq([contact_blocker])
				end
				
				it "renders 'index'" do
					get :index
					expect(response).to render_template 'index'
				end
			end

			describe "GET show" do
				it "assigns the requested contact_blocker as @contact_blocker" do
					get :show, {id: contact_blocker.to_param}
					expect(assigns(:contact_blocker)).to eq(contact_blocker)
				end
			end

			describe "GET edit" do
				it "assigns the requested contact_blocker as @contact_blocker" do
					get :edit, {id: contact_blocker.to_param}
					expect(assigns(:contact_blocker)).to eq(contact_blocker)
				end
			end

			describe "PUT update" do
				describe "with valid params" do
					it "updates the requested contact_blocker" do
						# Assuming there are no other contact_blockers in the database, this
						# specifies that the newly created ContactBlocker
						# receives the :update_attributes message with whatever params are
						# submitted in the request as the admin role.
						expect_any_instance_of(ContactBlocker).to receive(:update_attributes).with(valid_attributes)
						put :update, {id: contact_blocker.to_param, contact_blocker: valid_attributes}
					end

					it "assigns the requested contact_blocker as @contact_blocker" do
						put :update, {id: contact_blocker.to_param, contact_blocker: valid_attributes}
						expect(assigns(:contact_blocker)).to eq(contact_blocker)
					end

					it "redirects to the contact_blocker" do
						put :update, {id: contact_blocker.to_param, contact_blocker: valid_attributes}
						expect(response).to redirect_to(contact_blocker)
					end
				end

				describe "with invalid params" do
					it "assigns the contact_blocker as @contact_blocker" do
						# Trigger the behavior that occurs when invalid params are submitted
						allow_any_instance_of(ContactBlocker).to receive(:save).and_return(false)
						put :update, {id: contact_blocker.to_param, contact_blocker: valid_attributes}
						expect(assigns(:contact_blocker)).to eq(contact_blocker)
					end

					it "re-renders the 'edit' template" do
						# Trigger the behavior that occurs when invalid params are submitted
						allow_any_instance_of(ContactBlocker).to receive(:update_attributes).and_return(false)
						put :update, {id: contact_blocker.to_param, contact_blocker: valid_attributes}
						expect(response).to render_template 'edit'
					end
				end
			end

			describe "DELETE destroy" do
				it "destroys the requested contact_blocker" do
					expect {
						delete :destroy, {id: contact_blocker.to_param}
					}.to change(ContactBlocker, :count).by(-1)
				end

				it "redirects to the contact_blockers list" do
					delete :destroy, {id: contact_blocker.to_param}
					expect(response).to redirect_to(contact_blockers_url)
				end
			end
		end
	end

end
