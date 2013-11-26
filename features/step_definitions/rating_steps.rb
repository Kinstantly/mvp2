# Tip: to view the page, use: save_and_open_page

### WHEN ###

When /^I click on the (\d+) star$/ do |number|
	within('.rate_provider_form form') do
		choose "rate_provider_#{number}"
	end
end

### THEN ###

Then /^the profile should have an average rating of ([\d.]+)$/ do |rating|
	page.has_selector?(".provider_rating form input[title=\"#{rating}\"]").should be_true
end

Then /^my rating for this provider should be (\d+)$/ do |rating|
	find('.rate_provider_form form input[checked="checked"]').value.should == rating
end
