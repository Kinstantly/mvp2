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

	Scenario: Unsubscription by recipient triggers removal from all mailing lists
		Given I exist as a user
			And I am subscribed to all mailing lists
			And I have received an email from Kinstantly
		When I click on the unsubscribe link for the delivered email
			And I click submit on the unsubscribe page
		Then I should not be subscribed to any mailing lists

	Scenario: Blocking by admin triggers removal of user from all mailing lists
		Given I exist as a user
			And I am subscribed to all mailing lists
		When an administrator unsubscribes me from all mailing lists
		Then I should not be subscribed to any mailing lists
