require "spec_helper"

describe Users::RegistrationsController do
	describe "routing" do

		it 'routes "/newsletter" to newsletter sign-up page' do
			get('/newsletter').should route_to('users/registrations#new', nlsub: 't')
		end

		it 'routes "/newsletters" to newsletter sign-up page' do
			get('/newsletters').should route_to('users/registrations#new', nlsub: 't')
		end

		it 'routes "/newsletter/latest/parent_newsletters_stage1" to most recent parent_newsletters_stage1 campaign' do
			get('/newsletter/latest/parent_newsletters_stage1').should route_to('newsletters#latest', name: 'parent_newsletters_stage1')
		end
	end
end
