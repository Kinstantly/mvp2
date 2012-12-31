When /^I enter published profile data in the search box$/ do
	within('.search_providers') do
		fill_in 'provider_search_query', with: @published_profile_data[:last_name]
		click_button 'provider_search_button'
	end
end

Then /^I should see profile data in the search results list$/ do
	within('.search_results') do
		page.should have_content @published_profile_data[:last_name]
	end
end
