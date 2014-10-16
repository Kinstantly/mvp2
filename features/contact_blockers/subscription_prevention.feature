Feature: Blocked email address cannot be subscribed to any mailing list
	In order to prevent spam
	As a user that has previously unsubscribed from all email
	I don't want to be subscribed by mistake

	Scenario: I can subscribe to mailing lists
		Given I exist as a provider
			And I am logged in
			And I am on my account edit page
		When I check "Send me occasional deals"
			And I check "Send me occasional newsletters"
			And I enter my current password
			And I save the account settings
		Then I should be subscribed to the provider mailing lists

	Scenario: I cannot subscribe to mailing lists if I am blocked
		Given I exist as a provider
			And I opted out of receiving email from us
			And I am logged in
			And I am on my account edit page
		When I check "Send me occasional deals"
			And I check "Send me occasional newsletters"
			And I enter my current password
			And I save the account settings
		Then I should not be subscribed to the provider mailing lists
