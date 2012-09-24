require 'spec_helper'

describe User do
	before(:each) do
		@annie = User.new
	end
	
	it "should not allow an email address with no @ character" do
		@annie.email = 'annie'
		@annie.should have(1).error_on(:email)
	end
	
	it "should be happy if we set an email address that includes an @ character" do
		@annie.email = 'annie@exmaple.com'
		@annie.should have(:no).errors_on(:email)
	end
	
	it "should not allow a password with fewer than 6 characters" do
		@annie.password = '12345'
		@annie.should have(1).error_on(:password)
	end
	
	it "should be happy if we set a password with at least 6 characters" do
		@annie.password = '123456'
		@annie.should have(:no).errors_on(:password)
	end
end
