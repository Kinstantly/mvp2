When /^I visit the "(.*?)" page$/ do |path|
	visit path
end

Then /^I should see an email input box$/ do
	# This does not seem to work if the content is in an iframe (even using Selenium).
	page.should have_content('Email')
end

Then /^I should see a Google form$/ do
	page.should have_css('iframe')
end

Then /^I should see a statement about us$/ do
	page.should have_content('Zatch')
end

Then /^I should see a list of frequently asked questions and answers$/ do
	page.should have_content('Frequently')
end

Then /^I should see explanations of our terms of use$/ do
	page.should have_content('Terms of Use')
end
