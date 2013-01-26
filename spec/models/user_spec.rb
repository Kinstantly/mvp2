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
	
			it "should fail if saved without an email address" do
				@kelly.password = '123456'
				status = @kelly.save
				status.should == false
			end
		end
	
		context "password" do
			it "should not allow a password with fewer than 6 characters" do
				@kelly.password = '12345'
				@kelly.should have(1).error_on(:password)
			end
	
			it "should be happy if we set a password with at least 6 characters" do
				@kelly.password = '123456'
				@kelly.should have(:no).errors_on(:password)
			end
	
			it "should fail if saved without a password" do
				@kelly.email = 'kelly@example.com'
				status = @kelly.save
				status.should == false
			end
		end
	
		it "should succeed if saved with both an email address and a password" do
			@kelly.email = 'kelly@example.com'
			@kelly.password = '123456'
			status = @kelly.save
			status.should == true
		end
	
		context "profile" do
			it "should have no profile if new" do
				@kelly.profile.should be_nil
			end
	
			it "should have a profile if profile is built" do
				@kelly.build_profile
				@kelly.profile.should_not be_nil
			end
		
			context "claiming" do
				before(:each) do
					@token = '2857251c-64e2-11e2-93ca-00264afffe0a'
					FactoryGirl.create(:profile, invitation_email: 'Ralph@VaughanWilliams.com', invitation_token: @token)
					@ralph = FactoryGirl.create(:expert_user, email: 'Ralph@VaughanWilliams.com')
				end
			
				it "should fail if this user already has a persistent profile" do
					@ralph.claim_profile(@token).should_not be_true
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
			end
		end
	end
	
	context "non-expert" do
		before(:each) do
			@kelly = User.new
			@kelly.add_role :client
		end
		
		context "username" do
			it "should not allow a username with fewer than 4 characters" do
				@kelly.username = 'kel'
				@kelly.should have(1).error_on(:username)
			end
	
			it "should be happy if we set a username with at least 4 characters" do
				@kelly.username = 'kell'
				@kelly.should have(:no).errors_on(:username)
			end
	
			it "should fail if saved without a username" do
				@kelly.email = 'kelly@example.com'
				@kelly.password = '123456'
				status = @kelly.save
				status.should == false
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
end
