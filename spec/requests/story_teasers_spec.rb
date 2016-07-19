require 'spec_helper'

RSpec.describe 'StoryTeasers', :type => :request do
	
	# This should return at least the minimal set of attributes required to create a valid ProviderSuggestion.
	let (:valid_attributes) { FactoryGirl.attributes_for :story_teaser }
	
	let(:story_teaser) { FactoryGirl.create :story_teaser }
	
	describe 'story_teasers requests' do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'elina@example.com' }

		before (:each) do
			story_teaser # Make sure a persistent story_teaser exists.
			post user_session_path, user: { email: admin_user.email, password: admin_user.password }
		end
		
		it 'requests the list of story teasers' do
			get story_teasers_path
			expect(response).to have_http_status(200)
		end
		
		it 'requests a story teaser creation form' do
			get new_story_teaser_path
			expect(response).to have_http_status(200)
		end
		
		it 'requests creation of a new story teaser' do
			post story_teasers_path, story_teaser: valid_attributes
			expect(response).to have_http_status(302) # redirects to show view
		end
		
		it 'requests a look at a story teaser' do
			get story_teaser_path story_teaser
			expect(response).to have_http_status(200)
		end
		
		it 'requests a story teaser edit form' do
			get edit_story_teaser_path story_teaser
			expect(response).to have_http_status(200)
		end
		
		it 'requests update of a story teaser' do
			patch story_teaser_path(story_teaser), story_teaser: valid_attributes
			expect(response).to have_http_status(302) # redirects to show view
		end
		
		it 'requests deletion of a story teaser' do
			delete story_teaser_path story_teaser
			expect(response).to have_http_status(302) # redirects to list view
		end
	end
end
