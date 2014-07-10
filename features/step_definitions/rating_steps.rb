# Tip: to view the page, use: save_and_open_page

### GIVEN ###

Given /^a published profile with no ratings exists$/ do
	create_published_profile ratings: []
end

### WHEN ###

When /^I click on the (\d+) star$/ do |number|
	within(".rate_provider_form form div#rate_provider_#{number}") do
		find('a').click
	end
end

### THEN ###

Then /^the profile should have an average rating of ([\d.]+)$/ do |rating|
	page.has_selector?(".provider_rating form input[title=\"#{rating}\"]", visible: false).should be_true
end

Then /^my rating for this provider should be (\d+)$/ do |rating|
	find('.rate_provider_form form input[checked="checked"]', visible: false).value.should == rating
end

Then /^the published profile should have no ratings$/ do
	find_published_profile.should have(:no).ratings
end
