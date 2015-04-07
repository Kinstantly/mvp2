require "spec_helper"

describe Users::RegistrationsController do
	describe "routing" do

		it '"/newsletter" routes to newsletter sign-up page' do
			get('/newsletter').should route_to('users/registrations#new', nlsub: 't')
		end

		it '"/newsletter/latest/parent_newsletters_stage1" routes to newsletters#latest' do
			get('/newsletter/latest/parent_newsletters_stage1').should route_to('newsletters#latest', name: 'parent_newsletters_stage1')
		end
	end
end
