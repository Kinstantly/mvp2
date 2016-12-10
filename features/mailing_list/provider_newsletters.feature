@javascript
Feature: Provider marketing tips mailing list
	In order to get marketing tips useful to a provider
	As a new site visitor
	I want to be able to subscribe to provider marketing tips

	Background:
		Given there are no existing mailing list subscriptions
			And I am not logged in

	Scenario: Provider should be fully subscribed to the marketing tips list
		When I visit the "/provider/sign_up" page
			And I enter "provider@kinstantly.com" in the "Email" field
			And I enter "aitle459fjcm.%" in the "Password" field
			And I check "Send me occasional tips and insights on how to grow my business"
			And I click on the sign-up button
			And I see an unconfirmed account message
		Then provider@kinstantly.com should only be subscribed to the "provider_newsletters" mailing list and synced to the list server

	Scenario: Parent should not be allowed to subscribe to the marketing tips list
		When I visit the "/users/sign_up" page
		Then I should see "Get age-based development updates" on the page
			And I should not see "Send me occasional tips and insights on how to grow my business" on the page

	Scenario: Parent should not be subscribed to the marketing tips list
		When I visit the "/users/sign_up" page
			And I enter "parent@kinstantly.com" in the "Email" field
			And I enter "aitle459fjcm.%" in the "Password" field
			And I click on the sign-up button
			And I see an unconfirmed account message
		Then parent@kinstantly.com should only be subscribed to the "parent_newsletters" mailing list and synced to the list server
