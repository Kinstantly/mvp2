require 'spec_helper'

describe Rack::Attack do
	it "returns a normal response by default" do
		get '/'
		response.status.should == 200
	end
	
	context "the requesting IP address is blocked" do
		before(:each) do
			Rails.cache.write 'deny_request_from_ip_address_127.0.0.1', true
		end
		
		after(:each) do
			Rails.cache.delete 'deny_request_from_ip_address_127.0.0.1'
		end
		
		it "returns a response forbidden code" do
			get '/'
			response.status.should == 403
		end
		
		it "does not return the page content" do
			get '/'
			response.body.should == "Forbidden\n"
		end
	end
end
