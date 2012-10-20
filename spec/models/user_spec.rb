require 'spec_helper'

describe User do
	before(:each) do
		@kelly = User.new
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
	end
	
	context "roles" do
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
	end
end
