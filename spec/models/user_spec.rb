require 'spec_helper'

describe User, :type => :model do
	it 'can be ordered by ID' do
		id1 = (FactoryGirl.create :parent).id
		id2 = (FactoryGirl.create :second_parent).id
		expect(User.order_by_id.first.id).to eq (id1 < id2 ? id1 : id2)
		expect(User.order_by_id.last.id).to eq (id1 > id2 ? id1 : id2)
	end
	
	it 'can be ordered by descending ID' do
		id1 = (FactoryGirl.create :parent).id
		id2 = (FactoryGirl.create :second_parent).id
		expect(User.order_by_descending_id.first.id).to eq (id1 > id2 ? id1 : id2)
		expect(User.order_by_descending_id.last.id).to eq (id1 < id2 ? id1 : id2)
	end
	
	it 'can be ordered by email address' do
		eugenio = FactoryGirl.create :parent, email: 'eugenio@example.com'
		consuelo = FactoryGirl.create :second_parent, email: 'consuelo@example.com'
		expect(User.order_by_email.first).to eq consuelo
		expect(User.order_by_email.last).to eq eugenio
	end
	
	context "provider" do
		let(:provider) { FactoryGirl.build :provider, password_confirmation: nil, profile: nil }
		
		context "email address" do
			it "should not allow an email address with no @ character" do
				provider.email = 'kelly'
				expect(provider.error_on(:email).size).to eq 1
			end
	
			it "should be happy if we set an email address that includes an @ character" do
				provider.email = 'kelly@example.com'
				expect(provider.errors_on(:email).size).to eq 0
			end
	
			it "should require an email address" do
				provider.email = nil
				expect(provider.error_on(:email).size).to eq 1
			end
			
			it "should reject an email input field that is too long" do
				email = 'example@example.com'
				provider.email = ('a' * (User::MAX_LENGTHS[:email] - email.length)) + email
				expect(provider.errors_on(:email).size).to eq 0
				provider.email = 'a' + provider.email
				expect(provider.error_on(:email).size).to eq 1
			end
		end
	
		context "password" do
			it "should require a password" do
				provider.password = nil
				expect(provider.error_on(:password).size).to eq 1
			end
			
			it "should not allow a password that is too short" do
				provider.password = 'a' * (User::MIN_LENGTHS[:password] - 1)
				expect(provider.error_on(:password).size).to eq 1
				provider.password += 'a'
				expect(provider.errors_on(:password).size).to eq 0
			end
			
			it "should not allow a password that is too long" do
				provider.password = 'a' * User::MAX_LENGTHS[:password]
				expect(provider.errors_on(:password).size).to eq 0
				provider.password += 'a'
				expect(provider.error_on(:password).size).to eq 1
			end
		end
	
		it "should succeed if saved with both an email address and a password" do
			provider.email = 'kelly@example.com'
			provider.password = '1Two&Tres'
			expect(provider.save).to be_truthy
		end
		
		context "phone number" do
			it "is happy with a valid US phone number and extension" do
				provider.phone = '(800) 555-1234 x56'
				expect(provider.errors_on(:phone).size).to eq 0
			end
			
			it "should fail with an invalid US phone number" do
				provider.phone = '(111) 555-1234'
				expect(provider.error_on(:phone).size).to eq 1
			end
			
			it "should reject a phone input field that is too long" do
				phone = '(800) 555-1234 x56'
				provider.phone = phone + ('0' * (User::MAX_LENGTHS[:phone] - phone.length))
				expect(provider.errors_on(:phone).size).to eq 0
				provider.phone += '0'
				expect(provider.error_on(:phone).size).to eq 1
			end
		end
		
		context "registration special code" do
			it "should allow a blank code" do
				provider.registration_special_code = ''
				expect(provider.errors_on(:registration_special_code).size).to eq 0
			end
			
			it "should not allow a code that is too long" do
				provider.registration_special_code = 'a' * User::MAX_LENGTHS[:registration_special_code]
				expect(provider.errors_on(:registration_special_code).size).to eq 0
				provider.registration_special_code += 'a'
				expect(provider.error_on(:registration_special_code).size).to eq 1
			end
		end
	
		context "profile" do
			it "should have no profile if new" do
				expect(provider.profile).to be_nil
			end
	
			it "should have a profile if profile is built" do
				provider.build_profile
				expect(provider.profile).not_to be_nil
			end
			
			it "should not have a persisted profile if new" do
				expect(provider.has_persisted_profile?).not_to be_truthy
			end
			
			it "should not have a persisted profile if merely built" do
				provider.build_profile
				expect(provider.has_persisted_profile?).not_to be_truthy
			end
			
			it "should have a persisted profile if it was created" do
				provider.create_profile
				expect(provider.has_persisted_profile?).to be_truthy
			end
			
			it "should load a profile" do
				provider.load_profile
				expect(provider.profile).not_to be_nil
			end
			
			it "should have a published profile" do
				provider.load_profile
				expect(provider.profile.is_published).to be_truthy
			end
		
			context "claiming" do
				let(:token) { '2857251c-64e2-11e2-93ca-00264afffe0a' }
				let(:profile_to_claim) {
					FactoryGirl.create :profile, invitation_email: 'Ralph@VaughanWilliams.com', invitation_token: token
				}
				let(:ralph) { FactoryGirl.create :provider, email: 'Ralph@VaughanWilliams.com' }
				
				before(:example) do
					profile_to_claim.reload.user = nil
					profile_to_claim.save
				end
			
				it "should fail if this user already has a persistent profile" do
					expect(ralph.claim_profile(token)).not_to be_truthy
				end
				
				it "should succeed if we force a claim of the profile even if the user already has an existing profile" do
					expect(ralph.claim_profile(token, true)).to be_truthy
				end
			
				context "this user does not already have a persistent profile" do
					before(:example) do
						ralph.profile = nil
						ralph.save
					end
				
					it "should claim the profile specified by the given token" do
						expect(ralph.claim_profile(token)).to be_truthy
					end
				
					it "should fail if the token does not match a profile" do
						expect(ralph.claim_profile('nonsense')).not_to be_truthy
					end
				
					it "should fail if the profile is already claimed" do
						expect(ralph.claim_profile(token)).to be_truthy
						expect(ralph.claim_profile(token)).not_to be_truthy
					end
				end
				
				it "should declare that this user is in the process of claiming their profile" do
					ralph.claiming_profile! token
					expect(ralph).to be_claiming_profile
					expect(ralph.profile_to_claim).to eq profile_to_claim
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
				expect(result.errors[:email]).not_to be_present
				expect(result.errors[:admin_confirmation_sent_at]).not_to be_present
			end
			
			it "should have an error for an invalid email address" do
				result = User.send_confirmation_instructions email: 'no_one@example.org', admin_confirmation_sent_by_id: admin.id
				expect(result.errors[:email]).to be_present
			end
			
			it "should track who triggered the email" do
				User.send_confirmation_instructions email: provider.email, admin_confirmation_sent_by_id: admin.id
				expect(provider.reload.admin_confirmation_sent_by).to eq admin
			end
			
			it "should track when admin sent the email" do
				User.send_confirmation_instructions email: provider.email, admin_confirmation_sent_by_id: admin.id
				expect(provider.reload.admin_confirmation_sent_at.to_f).to be_within(10).of(Time.now.utc.to_f)
			end
			
			context "when running as a private site", private_site: true do
				it "admin should be able to send confirmation instructions" do
					result = User.send_confirmation_instructions email: provider.email, admin_confirmation_sent_by_id: admin.id
					expect(result.errors[:email]).not_to be_present
					expect(result.errors[:admin_confirmation_sent_at]).not_to be_present
				end
			end
		end
		
		context "non-admin when running as a private site", private_site: true do
			context "BEFORE admin approval" do
				it "should NOT send confirmation instructions" do
					result = User.send_confirmation_instructions email: provider.email
					expect(result.errors[:admin_confirmation_sent_at]).to be_present
				end
				
				it "should NOT confirm" do
					result = User.confirm_by_token devise_raw_confirmation_token(provider)
					expect(result).not_to be_confirmed
					expect(result.errors[:admin_confirmation_sent_at]).to be_present
				end

				it "should NOT send password reset instructions" do
					result = User.send_reset_password_instructions email: provider.email
					expect(result.errors[:admin_confirmation_sent_at]).to be_present
				end
				
				it "should NOT reset password" do
					old_encrypted_password = provider.encrypted_password
					new_password = User.generate_password
					token = devise_raw_reset_password_token(provider)
					result = User.reset_password_by_token reset_password_token: token, password: new_password, password_confirmation: new_password
					expect(result.encrypted_password).to eq old_encrypted_password
					expect(result.errors[:admin_confirmation_sent_at]).to be_present
				end
			end

			context "AFTER admin approval" do
				before(:example) do
					provider.admin_confirmation_sent_at = Time.now.utc
					provider.save
				end
				
				it "should send confirmation instructions" do
					result = User.send_confirmation_instructions email: provider.email
					expect(result.errors[:admin_confirmation_sent_at]).not_to be_present
				end
				
				it "should confirm" do
					result = User.confirm_by_token devise_raw_confirmation_token(provider)
					expect(result).to be_confirmed
					expect(result.errors[:admin_confirmation_sent_at]).not_to be_present
				end

				it "should send password reset instructions" do
					result = User.send_reset_password_instructions email: provider.email
					expect(result.errors[:admin_confirmation_sent_at]).not_to be_present
				end
				
				it "should reset password" do
					old_encrypted_password = provider.encrypted_password
					new_password = User.generate_password
					token = devise_raw_reset_password_token(provider)
					result = User.reset_password_by_token reset_password_token: token, password: new_password, password_confirmation: new_password
					expect(result.encrypted_password).not_to eq old_encrypted_password
					expect(result.errors[:admin_confirmation_sent_at]).not_to be_present
				end
			end
		end
	end
	
	context "parent" do
		let(:parent) { FactoryGirl.build :parent, password_confirmation: nil }
		
		context "username" do
			it "should not allow a username that is too short" do
				parent.username = 'a' * (User::MIN_LENGTHS[:username] - 1)
				expect(parent.error_on(:username).size).to eq 1
				parent.username += 'a'
				expect(parent.errors_on(:username).size).to eq 0
			end
			
			it "should not allow a username that is too long" do
				parent.username = 'a' * User::MAX_LENGTHS[:username]
				expect(parent.errors_on(:username).size).to eq 0
				parent.username += 'a'
				expect(parent.error_on(:username).size).to eq 1
			end
			
			it "should allow only alphanumeric and underscore characters in the username" do
				parent.username = 'kel&ly'
				expect(parent.error_on(:username).size).to eq 1
			end
	
			it "should not require a username if a client" do
				parent.username = nil
				expect(parent.errors_on(:username).size).to eq 0
			end
			
			it "should require a unique username" do
				username = 'gotta_be_me'
				FactoryGirl.create(:client_user, username: username)
				parent.username = username
				expect(parent.error_on(:username).size).to eq 1
			end
		end
	end
	
	context "roles" do
		let(:user) { User.new }

		it "should have no roles if new" do
			expect(user.roles).to be_empty
		end
		
		it "should be an admin if the admin role is added" do
			user.add_role 'admin'
			expect(user).to be_admin
		end
		
		it "should not be an admin if the admin role is removed" do
			user.add_role 'admin'
			user.remove_role 'admin'
			expect(user).not_to be_admin
		end
		
		it "should be an expert if the expert role is added" do
			user.add_role 'expert'
			expect(user).to be_expert
		end
		
		it "should be a client if the client role is added" do
			user.add_role 'client'
			expect(user).to be_client
		end
		
		it "should be a profile editor if the profile_editor role is added" do
			user.add_role 'profile_editor'
			expect(user).to be_profile_editor
		end
	end
	
	it "automatically strips leading and trailing whitespace from selected attributes" do
		user = User.new
		username = 'SteveEarle'
		user.username = " #{username} "
		expect(user.errors_on(:username).size).to eq 0
		expect(user.username).to eq username
	end
	
	context "email subscriptions", mailchimp: true do
		let(:parent) { FactoryGirl.create :parent }
		let(:new_parent) { FactoryGirl.build :parent }
		
		it "mailing lists exist in MailChimp account", contact_mailchimp: true do
			mailchimp_list_ids.values.each do |list_id|
				r = Gibbon::Request.lists(list_id).retrieve
				expect(r).to be_present
				expect(r['id']).to eq list_id
			end
		end

		it "can subscribe to mailing lists" do
			parent.parent_newsletters = true
			parent.save
			parent.reload
			expect(parent.parent_newsletters).to be_truthy
		end
		
		it "cannot subscribe to mailing lists if previously blocked" do
			FactoryGirl.create :contact_blocker, email: parent.email
			parent.parent_newsletters = true
			parent.save
			parent.reload
			expect(parent.parent_newsletters).to be_falsey
		end
		
		it "requires a subscription to at least one list if signing up for the newsletter" do
			new_parent.signed_up_for_mailing_lists = true
			new_parent.parent_newsletters = false
			expect(new_parent.error_on(:base).size).to eq 1
		end

		context "confirmation not required for newsletter subscription to take effect" do
			let(:user) { FactoryGirl.create :client_user, require_confirmation: true, parent_newsletters: true }
				
			it "should be added to mailing list before confirmation" do
				expect(user.parent_newsletters_leid).to be_present
			end

			it "should be added to mailing list after confirmation" do
				user.confirm
				user.save
				user.reload
				expect(user.parent_newsletters_leid).to be_present
			end
		end

		context "parent" do
			let(:parent_newsletters_id) { mailchimp_list_ids[:parent_newsletters] }		
			
			it "should not attempt to set the mailchimp subscriber name (because there are no name fields in the user record)", use_gibbon_mocks: true do
				merge_vars = { 'SUBSOURCE' => 'directory_user_create_or_update' }
				body = {
					body: {
						email_address: parent.email,
						status: 'subscribed',
						merge_fields: merge_vars
					}
				}
				email_hash = Digest::MD5.hexdigest parent.email.downcase
				# We can do the following because we are mocking the lists API.
				expect(Gibbon::Request.lists(parent_newsletters_id).members(email_hash)).to receive(:upsert).with(body).once
				
				parent.parent_newsletters = true
				parent.save
			end
		end

		context "provider" do
			let(:provider) { FactoryGirl.create :provider_with_username }
			let(:provider_newsletters_list_id) { mailchimp_list_ids[:provider_newsletters] }
			
			it "should set mailchimp subscriber first and last name to profile first and last name", use_gibbon_mocks: true do
				merge_vars = {
					'SUBSOURCE' => 'directory_user_create_or_update',
					FNAME: provider.profile.first_name,
					LNAME: provider.profile.last_name
				}
				body = {
					body: {
						email_address: provider.email,
						status: 'subscribed',
						merge_fields: merge_vars
					}
				}
				email_hash = Digest::MD5.hexdigest provider.email.downcase
				# We can do the following because we are mocking the lists API.
				expect(Gibbon::Request.lists(provider_newsletters_list_id).members(email_hash)).to receive(:upsert).with(body).once

				provider.provider_newsletters = true
				provider.save
			end

			it "should set mailchimp subscriber first name to blank if profile first name is empty", use_gibbon_mocks: true do
				merge_vars = {
					'SUBSOURCE' => 'directory_user_create_or_update',
					FNAME: '',
					LNAME: provider.profile.last_name
				}
				body = {
					body: {
						email_address: provider.email,
						status: 'subscribed',
						merge_fields: merge_vars
					}
				}
				email_hash = Digest::MD5.hexdigest provider.email.downcase
				# We can do the following because we are mocking the lists API.
				expect(Gibbon::Request.lists(provider_newsletters_list_id).members(email_hash)).to receive(:upsert).with(body).once
				
				provider.provider_newsletters = true
				provider.profile.first_name = ''
				provider.save
			end

			it "should set mailchimp subscriber last name to blank if profile last name is empty", use_gibbon_mocks: true do
				merge_vars = {
					'SUBSOURCE' => 'directory_user_create_or_update',
					FNAME: provider.profile.first_name,
					LNAME: ''
				}
				body = {
					body: {
						email_address: provider.email,
						status: 'subscribed',
						merge_fields: merge_vars
					}
				}
				email_hash = Digest::MD5.hexdigest provider.email.downcase
				# We can do the following because we are mocking the lists API.
				expect(Gibbon::Request.lists(provider_newsletters_list_id).members(email_hash)).to receive(:upsert).with(body).once

				provider.provider_newsletters = true
				provider.profile.last_name = ''
				provider.save
			end
		end
	end
	
	context "Payment" do
		context "As a customer" do
			let(:parent) { FactoryGirl.create :parent }
			let(:paying_parent) { FactoryGirl.create(:customer_file).customer.user }
			
			it "should indicate that this user has no paid providers" do
				expect(parent).not_to have_paid_providers
			end
			
			it "should indicate that this user has paid providers" do
				expect(paying_parent).to have_paid_providers
			end
		end
		
		context "As a provider" do
			let(:provider) { FactoryGirl.create :provider }
			let(:paid_provider) { FactoryGirl.create(:customer_file).provider }
			
			it "should indicate that this provider has no paying customers" do
				expect(provider).not_to have_paying_customers
			end
			
			it "should indicate that this provider has paying customers" do
				expect(paid_provider).to have_paying_customers
			end
		end
	end
end
