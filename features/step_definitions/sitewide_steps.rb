# Tip: to view the page, use: save_and_open_page

# Kludgey way to deal with slow asynchronous processes.
# If you're finding that a step fails unpredictably because
# an asynchronous process hasn't finished, try using this step.
When /^I wait a bit$/ do
	sleep 5
end

Then /^I should see "(.*?)" on the page$/ do |content|
	expect(page).to have_content content
end

Then /^I should see "(.*?)" text on the page$/ do |locale_path|
	expect(page).to have_content I18n.t locale_path
end

Then /^I should not see "(.*?)" on the page$/ do |content|
	expect(page).to_not have_content content
end

When /^I click on the "(.*?)" (?:link|button)$/ do |link_or_button|
	click_link_or_button link_or_button
end

When /^I click on "(.*?)"$/ do |link_or_button|
	click_on link_or_button
end

When /^I check "(.*?)"$/ do |field|
	check field
end

When /^I uncheck "(.*?)"$/ do |field|
	uncheck field
end

When /^I choose the "(.*?)" radio button$/ do |button|
	choose button
end

When /^I (?:enter|type|fill) "(.*?)" in the "(.*?)" field$/ do |text, field|
	fill_in field, with: text
end

When /^I confirm alert$/ do
	page.evaluate_script('window.confirm = function() { return true; }')
end

Then /^I should see "(.*?)" in the "(.*?)" field$/ do |text, field|
	within(:xpath, "//*[contains(text(), \"#{field}\")]/..") do
		expect(page).to have_content text
	end
end

Then /^I should land on the home page$/ do
	expect(current_path).to eq root_path
end

Then /^I should see a "(.*?)" link button on the page$/ do |label|
	within('a.button') do
		expect(page).to have_content label
	end
end

Then /^I should see a "(.*?)" button linked to "(.*?)" on the page$/ do |label, url|
	expect(page).to have_link(label, href: url)
end

Then /^I should (not )?see html element "(.*?)"$/ do |no, selector|
  if no.present?
    page.assert_no_selector(selector)
  else
    page.assert_selector(selector)
  end
end

