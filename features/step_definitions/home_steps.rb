# Tip: to view the page, use: save_and_open_page

def column_name_to_number(name)
	case name
	when 'first'
		1
	when 'second'
		2
	else
		pending "#{name} column"
	end
end

Given /^a category authored to appear in the "(first|second)" column on the home page$/ do |which_column|
	@authored_category = FactoryGirl.create :category_on_home_page, home_page_column: column_name_to_number(which_column)
end

Given /^a category authored to not appear on the home page$/ do
	@authored_category = FactoryGirl.create :category_not_on_home_page
end

Given /^a subcategory authored to appear on the home page$/ do
	@authored_subcategory = FactoryGirl.create :subcategory_on_home_page
end

Given /^a subcategory authored to not appear on the home page$/ do
	@authored_subcategory = FactoryGirl.create :subcategory_not_on_home_page
end

Given /^a service authored to appear on the home page$/ do
	@authored_service = FactoryGirl.create :service_on_home_page
end

Given /^a service authored to not appear on the home page$/ do
	@authored_service = FactoryGirl.create :service_not_on_home_page
end

When /^I visit the "(.*?)" page$/ do |path|
	visit path
end

Then /^I should see an email input box$/ do
	# This does not seem to work if the content is in an iframe (even using Selenium).
	expect(page).to have_content('Email')
end

Then /^I should see a Google form$/ do
	expect(page).to have_css('iframe')
end

Then /^I should see contact information$/ do
	expect(page).to have_content 'Ask us anything'
end

Then /^I should see a statement about us$/ do
	expect(page).to have_content('Our Story')
end

Then /^I should see a list of frequently asked questions and answers$/ do
	expect(page).to have_content('Frequently')
end

Then /^I should see explanations of our terms of use$/ do
	within('.privacy .section-header') do
		expect(page).to have_content('Terms of Use')
	end
end

Then /^I should see explanations of our privacy policy$/ do
	within('.privacy .section-header') do
		expect(page).to have_content('Our Privacy Policy')
	end
end

Then /^I should see that authored category$/ do
	expect(page).to have_content(@authored_category.name)
end

Then /^I should not see that authored category$/ do
	expect(page).to_not have_content(@authored_category.name)
end

Then /^I should see that authored category in the "(first|second)" column$/ do |which_column|
	within("#col#{column_name_to_number which_column}") do
		expect(page).to have_content(@authored_category.name)
	end
end

Then /^I should see that authored subcategory$/ do
	expect(page).to have_content(@authored_subcategory.name)
end

Then /^I should not see that authored subcategory$/ do
	expect(page).to_not have_content(@authored_subcategory.name)
end

Then /^I should see that authored service$/ do
	expect(page).to have_content(@authored_service.name)
end

Then /^I should not see that authored service$/ do
	expect(page).to_not have_content(@authored_service.name)
end

Then /^I should be redirected to the "([^\"]*)" site$/ do |url|
	expect(page.current_url).to match(url)
end
