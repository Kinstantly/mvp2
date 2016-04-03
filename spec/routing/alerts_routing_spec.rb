require "spec_helper"

describe NewslettersController, type: :routing, alerts: true do
	describe "routing" do
		# singular form
		it 'routes "/kidnote" to #new' do
			expect(get('/kidnote')).to route_to('newsletters#new', alerts: true)
		end

		# plural form
		it 'routes "/kidnotes" to #new' do
			expect(get('/kidnotes')).to route_to('newsletters#new', alerts: true)
		end

		it 'routes "/kidnotes/subscribed" to #subscribed' do
			expect(get('/kidnotes/subscribed')).to route_to('newsletters#subscribed', alerts: true)
		end

		it 'routes to #subscribe' do
			expect(post('kidnotes/subscribe')).to route_to('newsletters#subscribe', alerts: true)
		end
	end
end
