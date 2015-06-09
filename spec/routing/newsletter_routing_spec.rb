require "spec_helper"

describe Users::RegistrationsController do
	describe "routing" do

		# it 'routes "/newsletter" to newsletter sign-up page' do
		# 	get('/newsletter').should route_to('users/registrations#new', nlsub: 't')
		# end

		# it 'routes "/newsletters" to newsletter sign-up page' do
		# 	get('/newsletters').should route_to('users/registrations#new', nlsub: 't')
		# end

		it 'routes "/newsletter/latest/parent_newsletters_stage1" to most recent parent_newsletters_stage1 campaign' do
			get('/newsletter/latest/parent_newsletters_stage1').should route_to('newsletters#latest', name: 'parent_newsletters_stage1')
		end

		it 'routes "/newsletter/list" to newsletter archive page' do
			get('/newsletter/list').should route_to('newsletters#list')
		end

		it 'routes "/newsletter/1234" to newsletter 1234' do
			get('/newsletter/1234').should route_to('newsletters#show', id: '1234')
		end
	end
end

describe NewslettersController do
	describe "routing" do
		it 'routes "/newsletter" to #new' do
			get('/newsletter').should route_to('newsletters#new')
		end

		it 'routes "/newsletters" to #new' do
			get('/newsletters').should route_to('newsletters#new')
		end

		it 'routes "/newsletters/subscribed" to #subscribed' do
			get('/newsletters/subscribed').should route_to('newsletters#subscribed', nlsub: true)
		end

		it 'routes to #subscribe' do
			post('newsletters/subscribe').should route_to('newsletters#subscribe')
		end
	end
end
