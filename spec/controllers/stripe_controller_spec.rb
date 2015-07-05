require 'spec_helper'

describe StripeController, type: :controller, payments: true do
	describe "GET webhook" do
		around(:example) do |example|
			original_logger = StripeController.logger
			example.run
			StripeController.logger = original_logger
		end
		
		it "returns a status of 200 no matter what" do
			get :webhook, provider_id: 'hank'
			expect(response.status).to eq 200
		end
		
		it "logs the passed data" do
			logger = double 'logger'
			expect(logger).to receive :info
			StripeController.logger = logger
			get :webhook, provider_id: 'hank'
		end
	end
end
