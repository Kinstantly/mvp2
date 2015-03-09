require "spec_helper"

describe Users::RegistrationsController do
	describe "routing" do

		it '"/newsletter" routes to newsletter sign-up page' do
			get('/newsletter').should route_to('users/registrations#new', nlsub: 't')
		end
	end
end
