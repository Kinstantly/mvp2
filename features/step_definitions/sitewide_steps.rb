# Tip: to view the page, use: save_and_open_page

Then /^I should see "(.*?)" on the page$/ do |content|
	page.should have_content content
end
