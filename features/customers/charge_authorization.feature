@payments
Feature: Authorize charges
	In order to pay my provider conventiently
	As a parent
	I want to authorize my provider to charge me online

	Background:
		Given I am a client of a payable provider
			And I am logged in
		When I visit the payable provider's profile page
			And I click on "Authorize payment"
		Then I should see "Change your authorized amount" on the page

	Scenario: Authorize a total amount
		When I enter "$42.47" in the "I authorize payment" field
			And I click on the "Authorize" button
		Then I should see "You're set up for Kinstantly Pre-Auth" on the page
			And I should see "up to $42.47" on the page
		When I click on the "Payment information" button
		Then I should see "$42.47" on the page

	Scenario: Receive authorization confirmation
		When I enter "$42.47" in the "I authorize payment" field
			And I click on the "Authorize" button
			And I open the email with subject "You have authorized payments via Kinstantly"
		Then I should see "not to exceed a total of $42.47" in the email body

	Scenario: Notify provider of authorization by their client
		When I enter "$42.47" in the "I authorize payment" field
			And I click on the "Authorize" button
			And the payable provider opens the email with subject "Your client has authorized payments to you"
		Then they should see "not to exceed a total of $42.47" in the email body

	Scenario: Revoke authorization
		When I click on the "Revoke payment authorization" button
		Then I should see "no longer has permission to charge your card" on the page
		When I click on the "Payment information" button
		Then I should see "Not authorized" on the page

	Scenario: Receive revocation confirmation
		When I click on the "Revoke payment authorization" button
			And I open the email with subject "You have revoked authorization of payments"
		Then I should see "no longer has permission to charge your card" in the email body

	Scenario: Notify provider of revocation
		When I click on the "Revoke payment authorization" button
			And the payable provider opens the email with subject "Your client has revoked authorization of payments"
		Then they should see "You no longer have permission to charge their card" in the email body
