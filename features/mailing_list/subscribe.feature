Feature: Subscribe to newsletters and/or marketing emails
	In order to get useful and interesting parenting information
	As a user
	I want to be able to subscribe to newsletters and marketing emails

	Background:
		Given I am not logged in

	Scenario: Provider should not be fully subscribed before confirmation
		When I sign up with valid user data
			And I see an unconfirmed account message
		Then I should be subscribed only to the provider mailing lists but not yet synced to the list server

	Scenario: Provider should be fully subscribed after confirmation
		When I sign up with valid user data
			And I open the email with subject "Confirm your Kinstantly account"
		 	And I follow "confirm" in the email
		Then I should be subscribed only to the provider mailing lists and synced to the list server

	Scenario: Parent should not be fully subscribed before confirmation
		When I sign up as a parent with valid user data
			And I see an unconfirmed account message
		Then I should be subscribed to only the parent mailing lists but not yet synced to the list server

	Scenario: Parent should be fully subscribed after confirmation
		When I sign up as a parent with valid user data
			And I open the email with subject "Confirm your Kinstantly account"
		 	And I follow "confirm" in the email
		Then I should be subscribed to only the parent mailing lists and synced to the list server

	Scenario: Provider should be fully subscribed after registering while claiming their profile
		When I have been invited to claim a profile
			And I click on the profile claim link
			And I sign up with valid user data
		Then the profile should be attached to my account
			And I should be subscribed only to the provider mailing lists and synced to the list server
