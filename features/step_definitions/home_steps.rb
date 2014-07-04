# Tip: to view the page, use: save_and_open_page

def column_name_to_number(name)
	case name
	when 'first'
		1
	when 'second'
		2
	else
		pending "#{which_column} column"
	end
end

Given /^a category authored to appear in the "(first|second)" column on the home page$/ do |which_column|
	column_number = column_name_to_number(which_column)
	@authored_category = case column_number
	when 1
		FactoryGirl.create :category_on_home_page, home_page_column: 1
	when 2
		FactoryGirl.create :category_on_home_page, home_page_column: 4 # Use 4 until we implement the new design.
	else
		pending "column #{column_number}"
	end
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
	page.should have_content('Email')
end

Then /^I should see a Google form$/ do
	page.should have_css('iframe')
end

Then /^I should see contact information$/ do
	page.should have_content 'Ask us anything'
end

Then /^I should see a statement about us$/ do
	page.should have_content('Meet the Founders')
end

Then /^I should see a list of frequently asked questions and answers$/ do
	page.should have_content('Frequently')
end

Then /^I should see explanations of our terms of use$/ do
	within('.privacy .section-header') do
		page.should have_content('Terms of Use')
	end
end

Then /^I should see explanations of our privacy policy$/ do
	within('.privacy .section-header') do
		page.should have_content('Our Privacy Policy')
	end
end

Then /^I should see that authored category$/ do
	page.should have_content(@authored_category.name)
end

Then /^I should not see that authored category$/ do
	page.should_not have_content(@authored_category.name)
end

Then /^I should see that authored category in the "(first|second)" column$/ do |which_column|
	within("#col#{column_name_to_number which_column}") do
		page.should have_content(@authored_category.name)
	end
end

Then /^I should see that authored subcategory$/ do
	page.should have_content(@authored_subcategory.name)
end

Then /^I should not see that authored subcategory$/ do
	page.should_not have_content(@authored_subcategory.name)
end

Then /^I should see that authored service$/ do
	page.should have_content(@authored_service.name)
end

Then /^I should not see that authored service$/ do
	page.should_not have_content(@authored_service.name)
end
