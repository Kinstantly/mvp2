require "spec_helper"

describe "Not acceptable request", type: :request do
	context "not logged in" do
		
		# The following does not mix with other examples. Run stand-alone, e.g.,
		# bin/rspec --tag excluded_by_default spec/requests/not_acceptable_spec.rb
		context 'with production environment', excluded_by_default: true do
			around(:example) do |example|
				previous_env = Rails.env
				Rails.env = 'production'
				example.run
				Rails.env = previous_env
			end
			
			it "returns 406 response status when requesting a bad format" do
				get root_path, nil, {'HTTP_ACCEPT' => 'image/gif'}
				expect(response).to have_http_status 406
			end
		end
		
	end
end
