Feature: Subscribe to alerts
	In order to get timely parenting information based on my children's ages
	As a user
	I want to be able to subscribe to alerts

	Background:
		Given there are no existing mailing list subscriptions
			And I am not logged in

	Scenario: User subscribes on the alerts-only sign-up page without date and no confirmation required
		When I visit the alerts-only sign-up page and subscribe with email "example@kinstantly.com"
		Then I should see "You're all signed up for KidNotes" on the page

	Scenario: User subscribes on the alerts-only sign-up page with date and no confirmation required
		When I visit the alerts-only sign-up page and subscribe with email "example@kinstantly.com" and date "4/1/2015"
		Then I should see "You're all signed up for KidNotes" on the page

	Scenario: User subscribes on the alerts-only sign-up page with date
		When I visit the alerts-only sign-up page and subscribe with email "example@kinstantly.com" and date "6/1/2015"
		Then "example@kinstantly.com" should be subscribed to the "parent_newsletters" mailing list with birth date "6/1/2015"

	Scenario: Subscription is prevented if the date is entered with a bad format
		When I visit the alerts-only sign-up page and subscribe with email "example@kinstantly.com" and date "4/1/15"
		Then I should see "Please enter the date with the following format" on the page

	Scenario: Previously subscribed parent can manage alerts after registration
		When I visit the alerts-only sign-up page and subscribe with email "example@kinstantly.com" and date "9/1/2015"
		Then I should see "You're all signed up for KidNotes" on the page
		And I sign up as a parent with valid user data
			And I open the email with subject "Confirm your Kinstantly account"
		 	And I follow "confirm" in the email
		Then I should only be subscribed to the "parent_newsletters" mailing list and synced to the list server
