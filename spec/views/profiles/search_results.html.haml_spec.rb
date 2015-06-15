require 'spec_helper'

describe "profiles/search_results" do
	let(:parent) { FactoryGirl.create :parent }
	let(:profile) { FactoryGirl.create :published_profile } # Should have at least one service.
	
	context "search by service" do
		before(:each) do
			profile
			Profile.reindex
			Sunspot.commit
		end
		
		it "should show a provider associated with their service" do
			assign :search, Profile.search_by_service(profile.services.first)
			render
			rendered.should have_content(profile.display_name_or_company)
		end
	
		it "should show no reviews and ratings for the provider" do
			assign :search, Profile.search_by_service(profile.services.first)
			render
			rendered.should have_content('No reviews')
			rendered.should have_content('No ratings')
		end
	
		it "should show the number of reviews of a provider" do
			n_reviews = 3
			profile.reviews = FactoryGirl.create_list(:review, n_reviews, reviewer: parent)
			assign :search, Profile.search_by_service(profile.services.first)
			render
			rendered.should have_content("#{n_reviews} reviews")
		end
	
		it "should show the number of ratings of a provider" do
			profile.ratings << FactoryGirl.create(:rating, rater: parent)
			profile.ratings << FactoryGirl.create(:rating, rater: FactoryGirl.create(:second_parent))
			assign :search, Profile.search_by_service(profile.services.first)
			render
			rendered.should have_content('2 ratings')
		end
	end
	
	context "fuzzy search" do
		before(:each) do
			profile
			Profile.reindex
			Sunspot.commit
		end
		
		it "should return no search results when the query is empty" do
			assign :search, Profile.fuzzy_search('')
			render
			rendered.should have_content('No search results')
		end
		
		it "should return the profile when searching on its display name" do
			assign :search, Profile.fuzzy_search(profile.display_name)
			render
			rendered.should have_content(profile.display_name)
		end
	end
end
