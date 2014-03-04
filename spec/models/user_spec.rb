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
			@kelly.password = '123456'
			@kelly.save.should be_true
		end
		
		context "phone number" do
			it "he happy with a valid US phone number and extension" do
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
					@ralph.profile_claiming.should == @profile_to_claim
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
end
