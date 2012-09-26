require 'spec_helper'

describe User do
	before(:each) do
		@annie = User.new
	end
	
	context "email address" do
		it "should not allow an email address with no @ character" do
			@annie.email = 'annie'
			@annie.should have(1).error_on(:email)
		end
	
		it "should be happy if we set an email address that includes an @ character" do
			@annie.email = 'annie@exmaple.com'
			@annie.should have(:no).errors_on(:email)
		end
	
		it "should fail if saved without an email address" do
			@annie.password = '123456'
			status = @annie.save
			status.should == false
		end
	end
	
	context "password" do
		it "should not allow a password with fewer than 6 characters" do
			@annie.password = '12345'
			@annie.should have(1).error_on(:password)
		end
	
		it "should be happy if we set a password with at least 6 characters" do
			@annie.password = '123456'
			@annie.should have(:no).errors_on(:password)
		end
	
		it "should fail if saved without a password" do
			@annie.email = 'annie@exmaple.com'
			status = @annie.save
			status.should == false
		end
	end
	
	it "should succeed if saved with both an email address and a password" do
		@annie.email = 'annie@exmaple.com'
		@annie.password = '123456'
		status = @annie.save
		status.should == true
	end
	
	context "profile" do
		it "should have no profile if new" do
			@annie.profile.should be_nil
		end
	
		it "should have a profile if profile is built" do
			@annie.build_profile
			@annie.profile.should_not be_nil
		end
	end
end
