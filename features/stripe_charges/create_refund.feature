@payments
Feature: Refund a customer
	In order to correct a mischarge to one of my clients
	As a provider
	I want to refund them online

	Background:
		Given We are using Stripe for payments
			And I am logged in as a payable provider
			And I have a client with each of username "leontyne", email "lprice@kinstantly.com", and authorized amount "$100"
		When I visit the client list page
			And I click on the "leontyne" link
			And I click on the "Charge customer's card" button
			And I want to charge "$39.50"
			And I want the charge description to be "Office visit fee"
			And I want the description on the charge statement to be "Voice coach"
			And I click on the "Charge card" button
		Then I should see "Authorized amount remaining: $60.50" on the page

	Scenario: Full refund of the selected charge
		When I click on the "Details or refund" button
			And I enter "$39.50" in the "Refund amount" field
			And I click on the "Refund" button
		Then I should see "$39.50" in the "Amount refunded" field
			And I click on the "Back to customer details" button
			And I should see "Authorized amount remaining: $100.00" on the page

	Scenario: Partial refund of the selected charge
		When I click on the "Details or refund" button
			And I enter "$15.25" in the "Refund amount" field
			And I click on the "Refund" button
		Then I should see "$15.25" in the "Amount refunded" field
			And I click on the "Back to customer details" button
			And I should see "Authorized amount remaining: $75.75" on the page

	Scenario: Cannot refund more than the selected charge
		When I click on the "Details or refund" button
			And I enter "$40.00" in the "Refund amount" field
			And I click on the "Refund" button
		Then I should not see "Amount refunded" on the page
			And I click on the "Back to customer details" button
			And I should see "Authorized amount remaining: $60.50" on the page

	Scenario: Notification is sent to the client when I refund them
		When I click on the "Details or refund" button
			And I enter "$39.50" in the "Refund amount" field
			And I click on the "Refund" button
		Then "lprice@kinstantly.com" should receive an email with subject "has issued a refund"

	Scenario: Notification to the client contains the refunded amount
		When I click on the "Details or refund" button
			And I enter "$39.50" in the "Refund amount" field
			And I click on the "Refund" button
		When "lprice@kinstantly.com" opens the email with subject "has issued a refund"
		Then they should see "$39.50" in the email body

	Scenario: Notification to the client contains the partially refunded amount
		When I click on the "Details or refund" button
			And I enter "$15.25" in the "Refund amount" field
			And I click on the "Refund" button
		When "lprice@kinstantly.com" opens the email with subject "has issued a refund"
		Then they should see "$15.25" in the email body

	Scenario: Notification to the client contains the original charge descriptions
		When I click on the "Details or refund" button
			And I enter "$39.50" in the "Refund amount" field
			And I click on the "Refund" button
		When "lprice@kinstantly.com" opens the email with subject "has issued a refund"
		Then they should see "Office visit fee" in the email body
			And they should see "Voice coach" in the email body

	Scenario: Notification to the client contains a link to the refund details page
		When I click on the "Details or refund" button
			And I enter "$39.50" in the "Refund amount" field
			And I click on the "Refund" button
		When "lprice@kinstantly.com" opens the email with subject "has issued a refund"
			And I sign out
			And I sign in as the charged client
			And I follow "here" in the email
		Then I should see "$39.50" in the "Amount refunded" field

	Scenario: Full refund of the selected charge as viewed by my client
		When I click on the "Details or refund" button
			And I enter "$39.50" in the "Refund amount" field
			And I click on the "Refund" button
			And I sign out
			And I sign in as the charged client
			And I visit my payments page
		Then I should see "Fully refunded" on the page
		When I click on the "Details" button
		Then I should see "$39.50" in the "Amount refunded" field

	Scenario: Partial refund of the selected charge as viewed by my client
		When I click on the "Details or refund" button
			And I enter "$15.25" in the "Refund amount" field
			And I click on the "Refund" button
			And I sign out
			And I sign in as the charged client
			And I visit my payments page
		Then I should see "$15.25 refunded" on the page
		When I click on the "Details" button
		Then I should see "$15.25" in the "Amount refunded" field
