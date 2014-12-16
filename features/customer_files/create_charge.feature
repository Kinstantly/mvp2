Feature: Create charge
	In order to collect payments from my clients
	As a provider
	I want to charge them online

	Background:
		Given We are using Stripe for payments
			And I am logged in as a payable provider
			And I have a client with each of username "leontyne", email "lprice@kinstantly.com", and authorized amount "$100"
		When I visit the client list page
			And I click on the "leontyne" link
			And I click on the "Charge card" button
			And I want to charge "$39.50"
			And I want the charge description to be "Office visit fee"
			And I want the description on the charge statement to be "Voice coach"
			And I click on the "Charge card" button

	Scenario: Notification is sent to the client when I charge them
		Then "lprice@kinstantly.com" should receive an email

	Scenario: Notification to the client contains the charged amount
		When "lprice@kinstantly.com" opens the email
		Then they should see "$39.50" in the email body

	Scenario: Notification to the client contains the charge description
		When "lprice@kinstantly.com" opens the email
		Then they should see "Office visit fee" in the email body

	Scenario: Notification to the client contains the statement description
		When "lprice@kinstantly.com" opens the email
		Then they should see "Voice coach" in the email body

	Scenario: Confirmation page shows charged amount
		Then I should see "$39.50" on the page

	Scenario: Confirmation page shows remaining authorized amount
		Then I should see "Authorized amount remaining: $60.50" on the page
