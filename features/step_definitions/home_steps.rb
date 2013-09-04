Given /^a category authored to appear on the home page$/ do
	@authored_category = FactoryGirl.create :category_on_home_page
end

Given /^a service authored to appear on the home page$/ do
	@authored_service = FactoryGirl.create :predefined_service
	@authored_category = FactoryGirl.create :category_on_home_page, services: [@authored_service]
end

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

Then /^I should see contact information$/ do
	page.should have_content I18n.t('contact.intro')
end

Then /^I should see a statement about us$/ do
	page.should have_content('About us')
end

Then /^I should see a list of frequently asked questions and answers$/ do
	page.should have_content('Frequently')
end

Then /^I should see explanations of our terms of use$/ do
	page.should have_content('Terms of Use')
end

Then /^I should see that authored category$/ do
	page.should have_content(@authored_category.name)
end

Then /^I should see that authored service$/ do
	page.should have_content(@authored_service.name)
end
