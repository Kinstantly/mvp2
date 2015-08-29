require "spec_helper"

describe Users::RegistrationsController, :type => :routing do
	describe "routing" do

		# it 'routes "/newsletter" to newsletter sign-up page' do
		# 	get('/newsletter').should route_to('users/registrations#new', nlsub: 't')
		# end

		# it 'routes "/newsletters" to newsletter sign-up page' do
		# 	get('/newsletters').should route_to('users/registrations#new', nlsub: 't')
		# end

		it 'routes "/newsletter/latest/parent_newsletters" to most recent parent_newsletters campaign' do
			expect(get('/newsletter/latest/parent_newsletters')).to route_to('newsletters#latest', name: 'parent_newsletters')
		end

		it 'routes "/newsletter/list" to newsletter archive page' do
			expect(get('/newsletter/list')).to route_to('newsletters#list')
		end

		it 'routes "/newsletter/1234" to newsletter 1234' do
			expect(get('/newsletter/1234')).to route_to('newsletters#show', id: '1234')
		end
	end
end

describe NewslettersController, :type => :routing do
	describe "routing" do
		it 'routes "/newsletter" to #new' do
			expect(get('/newsletter')).to route_to('newsletters#new')
		end

		it 'routes "/newsletters" to #new' do
			expect(get('/newsletters')).to route_to('newsletters#new')
		end

		it 'routes "/newsletters/subscribed" to #subscribed' do
			expect(get('/newsletters/subscribed')).to route_to('newsletters#subscribed')
		end

		it 'routes to #subscribe' do
			expect(post('newsletters/subscribe')).to route_to('newsletters#subscribe')
		end
	end
end
