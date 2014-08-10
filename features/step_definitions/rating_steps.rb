# Tip: to view the page, use: save_and_open_page

### GIVEN ###

Given /^a published profile with no ratings exists$/ do
	create_published_profile ratings: []
end

Given /^a published profile with ratings of (\d+) and (\d+) exists$/ do |score1, score2|
	create_published_profile ratings: [FactoryGirl.create(:rating, score: score1), FactoryGirl.create(:rating, score: score2)]
end

### WHEN ###

When /^I click on the (\d+) star$/ do |number|
	within('.rate_provider .rate') do
		find(".star[data-score=\"#{number}\"]").click
	end
end

### THEN ###

Then /^the profile should have an average rating of ([\d.]+)$/ do |rating|
	page.should have_css(".ratings-section .reviews[title=\"#{rating}\"]")
end

Then /^my rating for this provider should be (\d+)$/ do |rating|
	page.should have_css(".rate_provider .rate.reviewed-#{rating}-star")
end

Then /^the published profile should have no ratings$/ do
	find_published_profile.should have(:no).ratings
end
