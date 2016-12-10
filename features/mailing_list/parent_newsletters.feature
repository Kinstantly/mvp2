@javascript
Feature: Parenting newsletter list
	In order to get news useful to a parent
	As a new site visitor
	I want to be able to subscribe to the parenting newsletter

	Background:
		Given there are no existing mailing list subscriptions
			And I am not logged in

	Scenario: Parent should be subscribed to the parenting newsletter by default
		When I visit the "/users/sign_up" page
			And I enter "parent@kinstantly.com" in the "Email" field
			And I enter "aitle459fjcm.%" in the "Password" field
			And I click on the sign-up button
			And I see an unconfirmed account message
		Then parent@kinstantly.com should only be subscribed to the "parent_newsletters" mailing list and synced to the list server

	Scenario: Parent must uncheck box to avoid being subscribed the parenting newsletter
		When I visit the "/users/sign_up" page
			And I enter "parent@kinstantly.com" in the "Email" field
			And I enter "aitle459fjcm.%" in the "Password" field
			And I uncheck "Get age-based development updates"
			And I click on the sign-up button
			And I see an unconfirmed account message
		Then parent@kinstantly.com should not be subscribed to any mailing lists
