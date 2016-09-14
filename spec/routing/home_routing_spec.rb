require "spec_helper"

describe HomeController, type: :routing do
	describe "routing" do
		it 'routes "/blog" to #blog' do
			expect(get '/blog').to route_to 'home#blog'
		end
		
		it 'routes "/pro" to #pro' do
			expect(get '/pro').to route_to 'home#pro'
		end
	end
end
