require 'spec_helper'

describe Rack::Attack, :type => :request do
	it "returns a normal response by default" do
		get '/'
		expect(response.status).to eq 200
	end
	
	context "the requesting IP address is blocked" do
		before(:example) do
			Rails.cache.write 'deny_request_from_ip_address_127.0.0.1', true
		end
		
		after(:example) do
			Rails.cache.delete 'deny_request_from_ip_address_127.0.0.1'
		end
		
		it "returns a response forbidden code" do
			get '/'
			expect(response.status).to eq 403
		end
		
		it "does not return the page content" do
			get '/'
			expect(response.body).to eq "Forbidden\n"
		end
	end
	
	context "anything in the requesting class C network is blocked" do
		before(:example) do
			Rails.cache.write 'deny_request_from_ip_address_127.0.0', true
		end
		
		after(:example) do
			Rails.cache.delete 'deny_request_from_ip_address_127.0.0'
		end
		
		it "returns a response forbidden code" do
			get '/'
			expect(response.status).to eq 403
		end
		
		it "does not return the page content" do
			get '/'
			expect(response.body).to eq "Forbidden\n"
		end
	end
	
	context "unblocked IP addresses are allowed" do
		before(:example) do
			Rails.cache.write 'deny_request_from_ip_address_10.100.0.1', true # not our IP address
		end
		
		after(:example) do
			Rails.cache.delete 'deny_request_from_ip_address_10.100.0.1'
		end
		
		it "returns a normal response" do
			get '/'
			expect(response.status).to eq 200
		end
		
		it 'does not return the "Forbidden" text' do
			get '/'
			expect(response.body).to_not eq "Forbidden\n"
		end
	end
end
