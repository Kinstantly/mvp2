# Tip: to view the page, use: save_and_open_page

Given /^I am on the search results page$/ do
	visit search_providers_path query: 'Music Teachers'
end

When /^I enter published profile data in the search box$/ do
	within('#providerSearch') do
		fill_in 'provider_search_query', with: @published_profile_data[:last_name]
		click_button 'Search'
	end
end

When /^I enter "(.*?)" in the search box$/ do |query|
	within('#providerSearch') do
		fill_in 'provider_search_query', with: query
		click_button 'Search'
	end
end

When /^I enter "(.*?)" in the search location box$/ do |location|
	within('#providerSearch') do
		fill_in 'provider_search_location', with: location
		click_button 'Search'
	end
end

Then /^I should see profile data in the search results list$/ do
	within('.search-results') do
		expect(page).to have_content @published_profile_data[:last_name]
	end
end

Then /^I should see "([^\"]+)" in the search results list$/ do |arg1|
	within('.search-results') do
		expect(page).to have_content arg1
	end
end

Then /^I should see "([^\"]+)" and "([^\"]+)" in the search results list$/ do |arg1, arg2|
	within('.search-results') do
		expect(page).to have_content arg1
		expect(page).to have_content arg2
	end
end

Then /^I should see "(.*?)" first in the search results list$/ do |arg1|
	within('.search-results li.result:first-of-type') do
		expect(page).to have_content arg1
	end
end

Then /^I should see no search results$/ do
	expect(page).to_not have_css('.search-results .result')
end
