# Tip: to view the page, use: save_and_open_page

# Kludgey way to deal with slow asynchronous processes.
# If you're finding that a step fails unpredictably because
# an asynchronous process hasn't finished, try using this step.
When /^I wait a bit$/ do
	sleep 5
end

Then /^I should see "(.*?)" on the page$/ do |content|
	page.should have_content content
end

When /^I click (?:on|the) "(.*?)"(?: link| button)?$/ do |link_or_button|
	click_on link_or_button
end

Then /^I should land on the home page$/ do
  current_path.should eq root_path
end
