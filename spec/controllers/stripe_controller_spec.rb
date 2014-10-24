require 'spec_helper'

describe StripeController do
	describe "GET webhook" do
		around(:each) do |example|
			original_logger = StripeController.logger
			example.run
			StripeController.logger = original_logger
		end
		
		it "returns a status of 200 no matter what" do
			get :webhook, provider_id: 'hank'
			response.status.should == 200
		end
		
		it "logs the passed data" do
			(logger = double 'logger').should_receive :info
			StripeController.logger = logger
			get :webhook, provider_id: 'hank'
		end
	end
end
