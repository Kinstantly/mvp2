When /^I visit the expert request page$/ do
	visit request_expert_path
end

Then /^I should see an email input box$/ do
	# This does not seem to work if the content is in an iframe (even using Selenium).
	page.should have_content('Email')
end

Then /^I should see a Google form$/ do
	page.should have_css('iframe')
end
