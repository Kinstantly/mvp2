Feature: Charge details
	In order to examine a particular charge in more detail
	As a provider
	I want to see all information related to that charge

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
		Then I should see "Authorized amount remaining: $60.50" on the page

	Scenario: View details of the selected charge
		When I click on the "Details" button
		Then I should see "$39.50" in the "Amount collected" field
			And I should see "Office visit fee" on the page
			And I should see "Voice coach" in the "Description on customer's statement" field
