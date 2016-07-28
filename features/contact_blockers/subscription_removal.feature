Feature: Subscription removal upon blocking
	In order to prevent spam
	As an email recipient or administrator
	I want to ensure that the recipient is removed from all mailing lists

	Background:
		Given there are no existing mailing list subscriptions

	Scenario: Should be subscribable to all mailing lists
		Given I exist as a user
			And I am subscribed to all mailing lists
		Then I should be subscribed to all mailing lists

	Scenario: Unsubscription by recipient triggers removal from all mailing lists and blocks future delivery
		Given I exist as a user
			And I am subscribed to all mailing lists
			And I have received an email from Kinstantly
		When I click on the unsubscribe link for the delivered email
			And I click submit on the unsubscribe page
		Then I should not be subscribed to any mailing lists
			And I should be blocked from receiving further email

	Scenario: Recipient can also block future delivery to a second email address
		Given I exist as a user
			And I am subscribed to all mailing lists
			And I have received an email from Kinstantly
		When I click on the unsubscribe link for the delivered email
			And I enter "thebrewinglair@example.org" in the "Email address" field
			And I click submit on the unsubscribe page
		Then I should not be subscribed to any mailing lists
			And I should be blocked from receiving further email
			And "thebrewinglair@example.org" should be blocked from receiving further email

	Scenario: Blocking by admin triggers removal of user from all mailing lists
		Given I exist as a user
			And I am subscribed to all mailing lists
		When an administrator unsubscribes me from all mailing lists
		Then I should not be subscribed to any mailing lists

	Scenario: Submitting a prefilled opt-out form triggers my removal from all mailing lists
		Given I exist as a user
			And I am subscribed to all mailing lists
		When I visit the prefilled optout page
			And I click submit on the optout page
		Then I should not be subscribed to any mailing lists

	Scenario: Entering my email address in the opt-out form triggers my removal from all mailing lists
		Given I exist as a user
			And I am subscribed to all mailing lists
		When I visit the optout page
			And I enter my email address on the optout page
			And I click submit on the optout page
		Then I should not be subscribed to any mailing lists
