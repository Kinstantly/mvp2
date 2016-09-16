Feature: Create a filtered list of email delivery records
	In order to sell our services to provider prospects
	As a sales person
	I want to send emails to providers who have not opted out of contact from us

	Background:
		Given I am logged in as an administrator

	Scenario: Create a list of email delivery records
		When I visit the "/email_deliveries/new_list" page
			And I enter "me@example.com" in the "Sender" field
			And I enter "provider_sell" in the "Email type" field
			And I enter "a@example.org" in the "List of email addresses" field
			And I click on the "Create list" button
		Then I should see "Email delivery records were successfully created" on the page
			And I should see "a@example.org	http" on the page

	Scenario: Filter out blocked email addresses
		Given "a@example.org" opted out of receiving email from us
		When I visit the "/email_deliveries/new_list" page
			And I enter "me@example.com" in the "Sender" field
			And I enter "provider_sell" in the "Email type" field
			And I enter "a@example.org" in the "List of email addresses" field
			And I click on the "Create list" button
		Then I should see "Unsubscribed: DO NOT USE!" on the page
			And I should see "a@example.org" on the page

	Scenario: Reject bad email addresses
		When I visit the "/email_deliveries/new_list" page
			And I enter "me@example.com" in the "Sender" field
			And I enter "provider_sell" in the "Email type" field
			And I enter "a@example." in the "List of email addresses" field
			And I click on the "Create list" button
		Then I should see "'a@example.' must be a valid address" on the page

	Scenario: Requires an input list of email addresses
		When I visit the "/email_deliveries/new_list" page
			And I enter "me@example.com" in the "Sender" field
			And I enter "provider_sell" in the "Email type" field
			And I click on the "Create list" button
		Then I should see "Email list is required" on the page
