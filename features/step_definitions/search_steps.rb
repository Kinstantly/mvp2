# Tip: to view the page, use: save_and_open_page

When /^I enter published profile data in the search box$/ do
	within('.search_providers') do
		fill_in 'provider_search_query', with: @published_profile_data[:last_name]
		click_button 'provider_search_button'
	end
end

When /^I enter "(.*?)" in the search box$/ do |query|
	within('.search_providers') do
		fill_in 'provider_search_query', with: query
		click_button 'provider_search_button'
	end
end

When /^I enter "(.*?)" in the search box and select the "(.*?)" search area tag$/ do |query, tag|
	within('.search_providers') do
		fill_in 'provider_search_query', with: query
		select tag, from: 'search_area_tag'
		click_button 'provider_search_button'
	end
end

When /^I enter "(.*?)" in the search-by-distance box$/ do |postal_code|
	within('.buttons form') do
		fill_in 'postal_code', with: postal_code
		click_button 'order_by_distance_button'
	end
end

Then /^I should see profile data in the search results list$/ do
	within('.search_results_list') do
		page.should have_content @published_profile_data[:last_name]
	end
end

Then /^I should see "(.*?)" and "(.*?)" in the search results list$/ do |arg1, arg2|
	within('.search_results_list') do
		page.should have_content arg1
		page.should have_content arg2
	end
end

Then /^I should see "(.*?)" first in the search results list$/ do |arg1|
	within('#expert_result_0') do
		page.should have_content arg1
	end
end
