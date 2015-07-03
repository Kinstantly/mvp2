require "spec_helper"

describe "Stripe API", type: :request, payments: true do
	# Run the following manually with "--no-drb --tag excluded_by_default".
	# We don't want to hit the Stripe API too often with an invalid key at the risk of getting blocked.
	context "Without valid Stripe API keys", excluded_by_default: true do
		it "throws an authorization error" do
			expect {
				Stripe::Token.create(
					{
						customer: 'CustomerId',
						card:     'CardId'
					},
					'TestInvalidAccessToken'
				)
			}.to raise_error(Stripe::AuthenticationError)
		end
	end
end
