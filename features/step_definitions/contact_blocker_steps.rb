# Tip: to view the page, use: save_and_open_page

### GIVEN ###

Given /^there is an unclaimed profile for which the recipient of a previous invitation opted out of email from us$/ do
	create_unattached_profile email_deliveries: [FactoryGirl.create(:email_delivery_with_contact_blockers)]
end

Given /^"(.*?)" opted out of receiving email from us$/ do |email|
	FactoryGirl.create :contact_blocker, email: email
end

Given /^I opted out of receiving email from us$/ do
	FactoryGirl.create :contact_blocker, email: @user.email
end

Given /^I click an optout link with the email address "(.*?)"$/ do |email|
	visit new_contact_blocker_from_email_address_path e: email
end

### WHEN ###

When /^I click on the unsubscribe link in the unclaimed profile invitation$/ do
	visit new_contact_blocker_from_email_delivery_path email_delivery_token: @unattached_profile.email_deliveries.last.token
end

When /^I click on a bad unsubscribe link in the unclaimed profile invitation$/ do
	visit new_contact_blocker_from_email_delivery_path email_delivery_token: @unattached_profile.email_deliveries.last.token+'a'
end

When /^I click submit on the unsubscribe page$/ do
	click_button I18n.t('views.contact_blocker.edit.unsubscribe_submit')
end

When /^I visit the optout page$/ do
	visit new_contact_blocker_from_email_address_path
end

When /^I visit the prefilled optout page$/ do
	visit new_contact_blocker_from_email_address_path e: @user.email
end

When /^I enter my email address on the optout page$/ do
	fill_in 'Email address', with: @user.email
end

When /^I click submit on the optout page$/ do
	click_button I18n.t('views.contact_blocker.edit.unsubscribe_submit')
end

### THEN ###

Then /^I should be on the unsubscribe page$/ do
	expect(page).to have_content I18n.t('views.contact_blocker.edit.unsubscribe_title')
end

Then /^I should be on the unsubscribe confirmation page$/ do
	expect(page).to have_content /unsubscribe successful/i
end

Then /^I should be on the unsubscribe recovery page$/ do
	expect(page).to have_content I18n.t('views.contact_blocker.view.unsubscribe_error')
end

Then /^I should see no invitation link$/ do
	expect(page).to_not have_content I18n.t('views.profile.view.invitation_to_claim_link')
end

Then /^I should be blocked from receiving further email$/ do
  expect(ContactBlocker.find_by_email @user.email).to be_present
end

Then /^"(.*?)" should be blocked from receiving further email$/ do |email|
  expect(ContactBlocker.find_by_email email).to be_present
end
