require 'spec_helper'

describe User do
	context "expert" do
		before(:each) do
			@kelly = User.new
			@kelly.add_role :expert
		end
	
		context "email address" do
			it "should not allow an email address with no @ character" do
				@kelly.email = 'kelly'
				@kelly.should have(1).error_on(:email)
			end
	
			it "should be happy if we set an email address that includes an @ character" do
				@kelly.email = 'kelly@example.com'
				@kelly.should have(:no).errors_on(:email)
			end
	
			it "should require an email address" do
				@kelly.email = nil
				@kelly.should have(1).error_on(:email)
			end
			
			it "should reject an email input field that is too long" do
				email = 'example@example.com'
				@kelly.email = ('a' * (User::MAX_LENGTHS[:email] - email.length)) + email
				@kelly.should have(:no).errors_on(:email)
				@kelly.email = 'a' + @kelly.email
				@kelly.should have(1).error_on(:email)
			end
		end
	
		context "password" do
			it "should require a password" do
				@kelly.password = nil
				@kelly.should have(1).error_on(:password)
			end
			
			it "should not allow a password that is too short" do
				@kelly.password = 'a' * (User::MIN_LENGTHS[:password] - 1)
				@kelly.should have(1).error_on(:password)
				@kelly.password += 'a'
				@kelly.should have(:no).errors_on(:password)
			end
			
			it "should not allow a password that is too long" do
				@kelly.password = 'a' * User::MAX_LENGTHS[:password]
				@kelly.should have(:no).errors_on(:password)
				@kelly.password += 'a'
				@kelly.should have(1).error_on(:password)
			end
		end
	
		it "should succeed if saved with both an email address and a password" do
			@kelly.email = 'kelly@example.com'
			@kelly.password = '1Two&Tres'
			@kelly.save.should be_true
		end
		
		context "phone number" do
			it "is happy with a valid US phone number and extension" do
				@kelly.phone = '(800) 555-1234 x56'
				@kelly.should have(:no).errors_on(:phone)
			end
			
			it "should fail with an invalid US phone number" do
				@kelly.phone = '(111) 555-1234'
				@kelly.should have(1).error_on(:phone)
			end
			
			it "should reject a phone input field that is too long" do
				phone = '(800) 555-1234 x56'
				@kelly.phone = phone + ('0' * (User::MAX_LENGTHS[:phone] - phone.length))
				@kelly.should have(:no).errors_on(:phone)
				@kelly.phone += '0'
				@kelly.should have(1).error_on(:phone)
			end
		end
		
		context "registration special code" do
			it "should allow a blank code" do
				@kelly.registration_special_code = ''
				@kelly.should have(:no).errors_on(:registration_special_code)
			end
			
			it "should not allow a code that is too long" do
				@kelly.registration_special_code = 'a' * User::MAX_LENGTHS[:registration_special_code]
				@kelly.should have(:no).errors_on(:registration_special_code)
				@kelly.registration_special_code += 'a'
				@kelly.should have(1).error_on(:registration_special_code)
			end
		end
	
		context "profile" do
			it "should have no profile if new" do
				@kelly.profile.should be_nil
			end
	
			it "should have a profile if profile is built" do
				@kelly.build_profile
				@kelly.profile.should_not be_nil
			end
			
			it "should not have a persisted profile if new" do
				@kelly.has_persisted_profile?.should_not be_true
			end
			
			it "should not have a persisted profile if merely built" do
				@kelly.build_profile
				@kelly.has_persisted_profile?.should_not be_true
			end
			
			it "should have a persisted profile if it was created" do
				@kelly.create_profile
				@kelly.has_persisted_profile?.should be_true
			end
			
			it "should load a profile" do
				@kelly.load_profile
				@kelly.profile.should_not be_nil
			end
			
			it "should have a published profile" do
				@kelly.load_profile
				@kelly.profile.is_published.should be_true
			end
		
			context "claiming" do
				before(:each) do
					@token = '2857251c-64e2-11e2-93ca-00264afffe0a'
					@profile_to_claim = FactoryGirl.create(:profile, invitation_email: 'Ralph@VaughanWilliams.com', invitation_token: @token)
					@ralph = FactoryGirl.create(:expert_user, email: 'Ralph@VaughanWilliams.com')
				end
			
				it "should fail if this user already has a persistent profile" do
					@ralph.claim_profile(@token).should_not be_true
				end
				
				it "should succeed if we force a claim of the profile even if the user already has an existing profile" do
					@ralph.claim_profile(@token, true).should be_true
				end
			
				context "this user does not already have a persistent profile" do
					before(:each) do
						@ralph.profile = nil
						@ralph.save
					end
				
					it "should claim the profile specified by the given token" do
						@ralph.claim_profile(@token).should be_true
					end
				
					it "should fail if the token does not match a profile" do
						@ralph.claim_profile('nonsense').should_not be_true
					end
				
					it "should fail if the profile is already claimed" do
						@ralph.claim_profile(@token).should be_true
						@ralph.claim_profile(@token).should_not be_true
					end
				end
				
				it "should declare that this user is in the process of claiming their profile" do
					@ralph.claiming_profile! @token
					@ralph.should be_claiming_profile
					@ralph.profile_to_claim.should == @profile_to_claim
				end
			end
		end
	end
	
	context "unconfirmed provider" do
		let(:provider) { FactoryGirl.create :provider, require_confirmation: true, admin_confirmation_sent_at: nil }
		
		context "administrator sending the registration confirmation email" do
			let(:admin) { FactoryGirl.create :admin_user }
			
			it "should have no errors for a valid email address" do
				result = User.send_confirmation_instructions email: provider.email, admin_confirmation_sent_by_id: admin.id
				result.errors[:email].should_not be_present
				result.errors[:admin_confirmation_sent_at].should_not be_present
			end
			
			it "should have an error for an invalid email address" do
				result = User.send_confirmation_instructions email: 'no_one@example.org', admin_confirmation_sent_by_id: admin.id
				result.errors[:email].should be_present
			end
			
			it "should track who triggered the email" do
				User.send_confirmation_instructions email: provider.email, admin_confirmation_sent_by_id: admin.id
				provider.reload.admin_confirmation_sent_by.should == admin
			end
			
			it "should track when admin sent the email" do
				User.send_confirmation_instructions email: provider.email, admin_confirmation_sent_by_id: admin.id
				provider.reload.admin_confirmation_sent_at.to_f.should be_within(10).of(Time.now.utc.to_f)
			end
			
			context "when running as a private site", private_site: true do
				it "admin should be able to send confirmation instructions" do
					result = User.send_confirmation_instructions email: provider.email, admin_mode: true
					result.errors[:email].should_not be_present
					result.errors[:admin_confirmation_sent_at].should_not be_present
				end
			end
		end
		
		context "non-admin when running as a private site", private_site: true do
			context "BEFORE admin approval" do
				it "should NOT send confirmation instructions" do
					result = User.send_confirmation_instructions email: provider.email
					result.errors[:admin_confirmation_sent_at].should be_present
				end
				
				it "should NOT confirm" do
					result = User.confirm_by_token provider.confirmation_token
					result.should_not be_confirmed
					result.errors[:admin_confirmation_sent_at].should be_present
				end

				it "should NOT send password reset instructions" do
					result = User.send_reset_password_instructions email: provider.email
					result.errors[:admin_confirmation_sent_at].should be_present
				end
				
				it "should NOT reset password" do
					token = User.reset_password_token
					provider.reset_password_token = token
					provider.reset_password_sent_at = Time.now.utc
					provider.save
					old_encrypted_password = provider.encrypted_password
					new_password = User.generate_password
					result = User.reset_password_by_token reset_password_token: token, password: new_password, password_confirmation: new_password
					result.encrypted_password.should == old_encrypted_password
					result.errors[:admin_confirmation_sent_at].should be_present
				end
			end

			context "AFTER admin approval" do
				before(:each) do
					provider.admin_confirmation_sent_at = Time.now.utc
					provider.save
				end
				
				it "should send confirmation instructions" do
					result = User.send_confirmation_instructions email: provider.email
					result.errors[:admin_confirmation_sent_at].should_not be_present
				end
				
				it "should confirm" do
					result = User.confirm_by_token provider.confirmation_token
					result.should be_confirmed
					result.errors[:admin_confirmation_sent_at].should_not be_present
				end

				it "should send password reset instructions" do
					result = User.send_reset_password_instructions email: provider.email
					result.errors[:admin_confirmation_sent_at].should_not be_present
				end
				
				it "should reset password" do
					token = User.reset_password_token
					provider.reset_password_token = token
					provider.reset_password_sent_at = Time.now.utc
					provider.save
					old_encrypted_password = provider.encrypted_password
					new_password = User.generate_password
					result = User.reset_password_by_token reset_password_token: token, password: new_password, password_confirmation: new_password
					result.encrypted_password.should_not == old_encrypted_password
					result.errors[:admin_confirmation_sent_at].should_not be_present
				end
			end
		end
	end
	
	context "non-expert" do
		before(:each) do
			@kelly = User.new
			@kelly.add_role :client
		end
		
		context "username" do
			it "should not allow a username that is too short" do
				@kelly.username = 'a' * (User::MIN_LENGTHS[:username] - 1)
				@kelly.should have(1).error_on(:username)
				@kelly.username += 'a'
				@kelly.should have(:no).errors_on(:username)
			end
			
			it "should not allow a username that is too long" do
				@kelly.username = 'a' * User::MAX_LENGTHS[:username]
				@kelly.should have(:no).errors_on(:username)
				@kelly.username += 'a'
				@kelly.should have(1).error_on(:username)
			end
			
			it "should allow only alphanumeric and underscore characters in the username" do
				@kelly.username = 'kel&ly'
				@kelly.should have(1).error_on(:username)
			end
	
			it "should require a username if a client" do
				@kelly.username = nil
				@kelly.should have(1).error_on(:username)
			end
			
			it "should require a unique username" do
				username = 'gotta_be_me'
				FactoryGirl.create(:client_user, username: username)
				@kelly.username = username
				@kelly.should have(1).error_on(:username)
			end
		end
	end
	
	context "roles" do
		before(:each) do
			@kelly = User.new
		end
		
		it "should have no roles if new" do
			@kelly.roles.should be_empty
		end
		
		it "should be an admin if the admin role is added" do
			@kelly.add_role 'admin'
			@kelly.should be_admin
		end
		
		it "should not be an admin if the admin role is removed" do
			@kelly.add_role 'admin'
			@kelly.remove_role 'admin'
			@kelly.should_not be_admin
		end
		
		it "should be an expert if the expert role is added" do
			@kelly.add_role 'expert'
			@kelly.should be_expert
		end
		
		it "should be a client if the client role is added" do
			@kelly.add_role 'client'
			@kelly.should be_client
		end
		
		it "should be a profile editor if the profile_editor role is added" do
			@kelly.add_role 'profile_editor'
			@kelly.should be_profile_editor
		end
	end
	
	it "automatically strips leading and trailing whitespace from selected attributes" do
		user = User.new
		username = 'SteveEarle'
		user.username = " #{username} "
		user.should have(:no).errors_on(:username)
		user.username.should == username
	end
	
	context "email subscriptions" do
		let(:parent) { FactoryGirl.create :parent }
		
		it "can subscribe to mailing lists" do
			parent.parent_marketing_emails = true
			parent.parent_newsletters = true
			parent.save
			parent.reload
			parent.parent_marketing_emails.should be_true
			parent.parent_newsletters.should be_true
		end
		
		it "cannot subscribe to mailing lists if previously blocked" do
			FactoryGirl.create :contact_blocker, email: parent.email
			parent.parent_marketing_emails = true
			parent.parent_newsletters = true
			parent.save
			parent.reload
			parent.parent_marketing_emails.should be_false
			parent.parent_newsletters.should be_false
		end

		context "unconfirmed user", mailchimp: true do
			let(:user) { FactoryGirl.create :client_user, require_confirmation: true, parent_marketing_emails: true, parent_newsletters: true }
				
			it "should not be added to mailing list before confirmation" do
				user.subscriber_euid.should be_false
				user.subscriber_euid.should be_false
			end

			it "should be added to mailing list after confirmation" do
				user.confirm!
				user.save
				user.reload
				user.subscriber_euid.should_not be_nil
				user.subscriber_euid.should_not be_nil
			end
		end

		context "parent", mailchimp: true do
			it "should set mailchimp subscriber name to username" do
				parent.parent_marketing_emails = true
				parent.parent_newsletters = true
				merge_vars = {groupings: [name: 'parent', groups: ['marketing_emails', 'newsletters']],
						FNAME: parent.username,
						LNAME: ""}
				opts = {
					email: {euid: parent.subscriber_euid, leid: parent.subscriber_leid, email: parent.email},
					id: Rails.configuration.mailchimp_list_id,
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				parent.subscribe_to_mailing_list
			end

			it "should set mailchimp subscriber name to email if username is empty" do
				parent.parent_marketing_emails = true
				parent.parent_newsletters = true
				parent.username = nil
				merge_vars = {groupings: [name: 'parent', groups: ['marketing_emails', 'newsletters']],
						FNAME: parent.email,
						LNAME: ""}
				opts = {
					email: {euid: parent.subscriber_euid, leid: parent.subscriber_leid, email: parent.email},
					id: Rails.configuration.mailchimp_list_id,
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				parent.subscribe_to_mailing_list
			end

			it "should be subscribed to a correct group" do
				parent.parent_marketing_emails = true
				merge_vars = {groupings: [name: 'parent', groups: ['marketing_emails']],
						FNAME: parent.username,
						LNAME: ""}
				opts = {
					email: {euid: parent.subscriber_euid, leid: parent.subscriber_leid, email: parent.email},
					id: Rails.configuration.mailchimp_list_id,
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				parent.subscribe_to_mailing_list
			end

			it "should notify mailchimp to update existing subscription if user subscribed" do
				parent.parent_marketing_emails = true
				parent.parent_newsletters = true
				parent.subscriber_euid = "123"
				parent.subscriber_leid = "123"
				merge_vars = {groupings: [name: 'parent', groups: ['marketing_emails', 'newsletters']],
						FNAME: parent.username,
						LNAME: "",
						'new-email' => parent.email}
				opts = {
					id: Rails.configuration.mailchimp_list_id,
					email: {euid: parent.subscriber_euid, leid: parent.subscriber_leid},
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				parent.subscribe_to_mailing_list
			end
		end

		context "provider", mailchimp: true do
			let(:provider) { FactoryGirl.create :provider_with_username }
		
			it "should set mailchimp subscriber name to profile first and last name" do
				provider.provider_marketing_emails = true
				provider.provider_newsletters = true
				merge_vars = {groupings: [name: 'provider', groups: ['marketing_emails', 'newsletters']],
						FNAME: provider.profile.first_name,
						LNAME: provider.profile.last_name}
				opts = {
					id: Rails.configuration.mailchimp_list_id,
					email: {euid: provider.subscriber_euid, leid: provider.subscriber_leid, email: provider.email},
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				provider.subscribe_to_mailing_list
			end

			it "should set mailchimp subscriber name to username if profile first is empty" do
				provider.provider_marketing_emails = true
				provider.provider_newsletters = true
				provider.profile.first_name = ''
				merge_vars = {groupings: [name: 'provider', groups: ['marketing_emails', 'newsletters']],
						FNAME: provider.username,
						LNAME: ""}
				opts = {
					id: Rails.configuration.mailchimp_list_id,
					email: {euid: provider.subscriber_euid, leid: provider.subscriber_leid, email: provider.email},
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				provider.subscribe_to_mailing_list
			end

			it "should set mailchimp subscriber name to email if profile first name and username are empty" do
				provider.provider_marketing_emails = true
				provider.provider_newsletters = true
				provider.profile.first_name = ''
				provider.username = nil
				merge_vars = {groupings: [name: 'provider', groups: ['marketing_emails', 'newsletters']],
						FNAME: provider.email,
						LNAME: ''}
				opts = {
					id: Rails.configuration.mailchimp_list_id,
					email: {euid: provider.subscriber_euid, leid: provider.subscriber_leid, email: provider.email},
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				provider.subscribe_to_mailing_list
			end

			it "should be subscribed to a correct group" do
				provider.provider_marketing_emails = true
				merge_vars = {groupings: [name: 'provider', groups: ['marketing_emails']],
						FNAME: provider.profile.first_name,
						LNAME: provider.profile.last_name}
				opts = {
					id: Rails.configuration.mailchimp_list_id,
					email: {euid: provider.subscriber_euid, leid: provider.subscriber_leid, email: provider.email},
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				provider.subscribe_to_mailing_list
			end

			it "should notify mailchimp to update existing subscription if user subscribed" do
				provider.provider_marketing_emails = true
				provider.provider_newsletters = true
				provider.subscriber_euid = "123"
				provider.subscriber_leid = "123"
				merge_vars = {groupings: [name: 'provider', groups: ['marketing_emails', 'newsletters']],
						FNAME: provider.profile.first_name,
						LNAME: provider.profile.last_name,
						'new-email' => provider.email}
				opts = {
					id: Rails.configuration.mailchimp_list_id,
					email: {euid: provider.subscriber_euid, leid: provider.subscriber_leid},
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				provider.subscribe_to_mailing_list
			end
		end
	end
	
	context "Payment" do
		context "As a customer" do
			let(:parent) { FactoryGirl.create :parent }
			let(:paying_parent) { FactoryGirl.create(:customer_file).customer.user }
			
			it "should indicate that this user has no paid providers" do
				parent.should_not have_paid_providers
			end
			
			it "should indicate that this user has paid providers" do
				paying_parent.should have_paid_providers
			end
		end
		
		context "As a provider" do
			let(:provider) { FactoryGirl.create :provider }
			let(:paid_provider) { FactoryGirl.create(:customer_file).provider }
			
			it "should indicate that this provider has no paying customers" do
				provider.should_not have_paying_customers
			end
			
			it "should indicate that this provider has paying customers" do
				paid_provider.should have_paying_customers
			end
		end
	end
end
