require 'spec_helper'

describe User do
	context "provider" do
		let(:provider) { FactoryGirl.build :provider, password_confirmation: nil, profile: nil }
		
		context "email address" do
			it "should not allow an email address with no @ character" do
				provider.email = 'kelly'
				provider.should have(1).error_on(:email)
			end
	
			it "should be happy if we set an email address that includes an @ character" do
				provider.email = 'kelly@example.com'
				provider.should have(:no).errors_on(:email)
			end
	
			it "should require an email address" do
				provider.email = nil
				provider.should have(1).error_on(:email)
			end
			
			it "should reject an email input field that is too long" do
				email = 'example@example.com'
				provider.email = ('a' * (User::MAX_LENGTHS[:email] - email.length)) + email
				provider.should have(:no).errors_on(:email)
				provider.email = 'a' + provider.email
				provider.should have(1).error_on(:email)
			end
		end
	
		context "password" do
			it "should require a password" do
				provider.password = nil
				provider.should have(1).error_on(:password)
			end
			
			it "should not allow a password that is too short" do
				provider.password = 'a' * (User::MIN_LENGTHS[:password] - 1)
				provider.should have(1).error_on(:password)
				provider.password += 'a'
				provider.should have(:no).errors_on(:password)
			end
			
			it "should not allow a password that is too long" do
				provider.password = 'a' * User::MAX_LENGTHS[:password]
				provider.should have(:no).errors_on(:password)
				provider.password += 'a'
				provider.should have(1).error_on(:password)
			end
		end
	
		it "should succeed if saved with both an email address and a password" do
			provider.email = 'kelly@example.com'
			provider.password = '1Two&Tres'
			provider.save.should be_true
		end
		
		context "phone number" do
			it "is happy with a valid US phone number and extension" do
				provider.phone = '(800) 555-1234 x56'
				provider.should have(:no).errors_on(:phone)
			end
			
			it "should fail with an invalid US phone number" do
				provider.phone = '(111) 555-1234'
				provider.should have(1).error_on(:phone)
			end
			
			it "should reject a phone input field that is too long" do
				phone = '(800) 555-1234 x56'
				provider.phone = phone + ('0' * (User::MAX_LENGTHS[:phone] - phone.length))
				provider.should have(:no).errors_on(:phone)
				provider.phone += '0'
				provider.should have(1).error_on(:phone)
			end
		end
		
		context "registration special code" do
			it "should allow a blank code" do
				provider.registration_special_code = ''
				provider.should have(:no).errors_on(:registration_special_code)
			end
			
			it "should not allow a code that is too long" do
				provider.registration_special_code = 'a' * User::MAX_LENGTHS[:registration_special_code]
				provider.should have(:no).errors_on(:registration_special_code)
				provider.registration_special_code += 'a'
				provider.should have(1).error_on(:registration_special_code)
			end
		end
	
		context "profile" do
			it "should have no profile if new" do
				provider.profile.should be_nil
			end
	
			it "should have a profile if profile is built" do
				provider.build_profile
				provider.profile.should_not be_nil
			end
			
			it "should not have a persisted profile if new" do
				provider.has_persisted_profile?.should_not be_true
			end
			
			it "should not have a persisted profile if merely built" do
				provider.build_profile
				provider.has_persisted_profile?.should_not be_true
			end
			
			it "should have a persisted profile if it was created" do
				provider.create_profile
				provider.has_persisted_profile?.should be_true
			end
			
			it "should load a profile" do
				provider.load_profile
				provider.profile.should_not be_nil
			end
			
			it "should have a published profile" do
				provider.load_profile
				provider.profile.is_published.should be_true
			end
		
			context "claiming" do
				let(:token) { '2857251c-64e2-11e2-93ca-00264afffe0a' }
				let(:profile_to_claim) {
					FactoryGirl.create :profile, invitation_email: 'Ralph@VaughanWilliams.com', invitation_token: token
				}
				let(:ralph) { FactoryGirl.create :provider, email: 'Ralph@VaughanWilliams.com' }
				
				before(:each) do
					profile_to_claim.reload.user = nil
					profile_to_claim.save
				end
			
				it "should fail if this user already has a persistent profile" do
					ralph.claim_profile(token).should_not be_true
				end
				
				it "should succeed if we force a claim of the profile even if the user already has an existing profile" do
					ralph.claim_profile(token, true).should be_true
				end
			
				context "this user does not already have a persistent profile" do
					before(:each) do
						ralph.profile = nil
						ralph.save
					end
				
					it "should claim the profile specified by the given token" do
						ralph.claim_profile(token).should be_true
					end
				
					it "should fail if the token does not match a profile" do
						ralph.claim_profile('nonsense').should_not be_true
					end
				
					it "should fail if the profile is already claimed" do
						ralph.claim_profile(token).should be_true
						ralph.claim_profile(token).should_not be_true
					end
				end
				
				it "should declare that this user is in the process of claiming their profile" do
					ralph.claiming_profile! token
					ralph.should be_claiming_profile
					ralph.profile_to_claim.should == profile_to_claim
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
					result = User.send_confirmation_instructions email: provider.email, admin_confirmation_sent_by_id: admin.id
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
	
	context "parent" do
		let(:parent) { FactoryGirl.build :parent, password_confirmation: nil }
		
		context "username" do
			it "should not allow a username that is too short" do
				parent.username = 'a' * (User::MIN_LENGTHS[:username] - 1)
				parent.should have(1).error_on(:username)
				parent.username += 'a'
				parent.should have(:no).errors_on(:username)
			end
			
			it "should not allow a username that is too long" do
				parent.username = 'a' * User::MAX_LENGTHS[:username]
				parent.should have(:no).errors_on(:username)
				parent.username += 'a'
				parent.should have(1).error_on(:username)
			end
			
			it "should allow only alphanumeric and underscore characters in the username" do
				parent.username = 'kel&ly'
				parent.should have(1).error_on(:username)
			end
	
			it "should not require a username if a client" do
				parent.username = nil
				parent.should have(:no).errors_on(:username)
			end
			
			it "should require a unique username" do
				username = 'gotta_be_me'
				FactoryGirl.create(:client_user, username: username)
				parent.username = username
				parent.should have(1).error_on(:username)
			end
		end
	end
	
	context "roles" do
		let(:user) { User.new }

		it "should have no roles if new" do
			user.roles.should be_empty
		end
		
		it "should be an admin if the admin role is added" do
			user.add_role 'admin'
			user.should be_admin
		end
		
		it "should not be an admin if the admin role is removed" do
			user.add_role 'admin'
			user.remove_role 'admin'
			user.should_not be_admin
		end
		
		it "should be an expert if the expert role is added" do
			user.add_role 'expert'
			user.should be_expert
		end
		
		it "should be a client if the client role is added" do
			user.add_role 'client'
			user.should be_client
		end
		
		it "should be a profile editor if the profile_editor role is added" do
			user.add_role 'profile_editor'
			user.should be_profile_editor
		end
	end
	
	context "updating attributes" do
		let(:user) { FactoryGirl.create :user, profile: nil }
		let(:newsletter_subscriptions) {
			{
				provider_newsletters: '1',
				parent_newsletters_stage1: '1', 
				parent_newsletters_stage2: '1',
				parent_newsletters_stage3: '1'
			}
		}
		
		it "does not require the current password to update newsletter subscriptions" do
			user.update_attributes(newsletter_subscriptions, as: :passwordless).should be_true
		end
		
		it "requires the current password to update the email address" do
			expect {
				user.update_attributes({email: 'leontyne@example.org'}, as: :passwordless)
			}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
		
		it "requires the current password to update the password" do
			expect {
				user.update_attributes({password: 'ju4&8gswopl3'}, as: :passwordless)
			}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
		
		it "does not update an attribute that is not accessible at all" do
			expect {
				user.update_attributes({failed_attempts: 0})
			}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
	end
	
	it "automatically strips leading and trailing whitespace from selected attributes" do
		user = User.new
		username = 'SteveEarle'
		user.username = " #{username} "
		user.should have(:no).errors_on(:username)
		user.username.should == username
	end
	
	context "email subscriptions", mailchimp: true do
		let(:parent) { FactoryGirl.create :parent }
		let(:new_parent) { FactoryGirl.build :parent }
		
		it "can request MailChimp and mailing lists exist in MailChimp account" do
			system_list_ids = Rails.configuration.mailchimp_list_id.values
			gb = Gibbon::API.new
			r = gb.lists.list
			r.present?.should be_true
			mailchimp_list_ids = r['data'].collect { |list_data| list_data['id'] }   
			(system_list_ids - mailchimp_list_ids).empty?.should be_true
		end

		it "can subscribe to mailing lists", empty_mailing_lists: true do
			parent.parent_newsletters_stage1 = true
			parent.parent_newsletters_stage2 = true
			parent.parent_newsletters_stage3 = true
			parent.save
			parent.reload
			parent.parent_newsletters_stage1.should be_true
			parent.parent_newsletters_stage2.should be_true
			parent.parent_newsletters_stage3.should be_true
		end
		
		it "cannot subscribe to mailing lists if previously blocked", empty_mailing_lists: true do
			FactoryGirl.create :contact_blocker, email: parent.email
			parent.parent_newsletters_stage1 = true
			parent.parent_newsletters_stage2 = true
			parent.parent_newsletters_stage3 = true
			parent.save
			parent.reload
			parent.parent_newsletters_stage1.should be_false
			parent.parent_newsletters_stage2.should be_false
			parent.parent_newsletters_stage3.should be_false
		end
		
		it "requires a subscription to at least one edition if signing up for the newsletter" do
			new_parent.signed_up_for_mailing_lists = true
			new_parent.parent_newsletters_stage1 = false
			new_parent.parent_newsletters_stage2 = false
			new_parent.parent_newsletters_stage3 = false
			new_parent.should have(1).error_on(:base)
		end

		context "confirmation not required for newsletter subscription to take effect", empty_mailing_lists: true do
			let(:user) { FactoryGirl.create :client_user, require_confirmation: true, parent_newsletters_stage1: true, parent_newsletters_stage2: true, parent_newsletters_stage3: true }
				
			it "should be added to mailing list before confirmation" do
				user.parent_newsletters_stage1_leid.should be_present
				user.parent_newsletters_stage2_leid.should be_present
				user.parent_newsletters_stage3_leid.should be_present
			end

			it "should be added to mailing list after confirmation" do
				user.confirm!
				user.save
				user.reload
				user.parent_newsletters_stage1_leid.should be_present
				user.parent_newsletters_stage2_leid.should be_present
				user.parent_newsletters_stage3_leid.should be_present
			end
		end

		context "parent", empty_mailing_lists: true do
			let(:parent_newsletters_stage1_id) { Rails.configuration.mailchimp_list_id[:parent_newsletters_stage1] }		
			let(:parent_newsletters_stage2_id) { Rails.configuration.mailchimp_list_id[:parent_newsletters_stage2] }
			let(:parent_newsletters_stage3_id) { Rails.configuration.mailchimp_list_id[:parent_newsletters_stage3] }
			
			it "should set mailchimp subscriber name to username" do
				parent.parent_newsletters_stage1 = true
				merge_vars = { FNAME: parent.username, LNAME: "" }
				opts = {
					email: { leid: parent.parent_newsletters_stage1_leid, email: parent.email },
					id: parent_newsletters_stage1_id,
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				parent.save
			end

			it "should set mailchimp subscriber name to email if username is empty" do
				parent.parent_newsletters_stage2 = true
				parent.username = "updated_username"
				merge_vars = { FNAME: parent.username, LNAME: "" }
				opts = {
					email: { leid: parent.parent_newsletters_stage2_leid, email: parent.email },
					id: parent_newsletters_stage2_id,
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				parent.save
			end
		end

		context "provider", empty_mailing_lists: true do
			let(:provider) { FactoryGirl.create :provider_with_username }
			let(:provider_newsletters_list_id) { Rails.configuration.mailchimp_list_id[:provider_newsletters] }
			
			it "should set mailchimp subscriber name to profile first and last name" do
				provider.provider_newsletters = true
				merge_vars = { FNAME: provider.profile.first_name, LNAME: provider.profile.last_name }
				opts = {
					id: provider_newsletters_list_id,
					email: { leid: provider.provider_newsletters_leid, email: provider.email },
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				provider.save
			end

			it "should set mailchimp subscriber name to username if profile first is empty" do
				provider.provider_newsletters = true
				provider.profile.first_name = ''
				merge_vars = { FNAME: provider.username, LNAME: "" }
				opts = {
					id: provider_newsletters_list_id,
					email: { leid: provider.provider_newsletters_leid, email: provider.email },
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				}
				gb_obj = Gibbon::API.new.lists.class
				gb_obj.any_instance.should_receive(:subscribe).with(opts).once
				provider.save
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
