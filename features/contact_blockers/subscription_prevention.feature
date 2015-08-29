Feature: Blocked email address cannot be subscribed to any mailing list
	In order to prevent spam
	As a user that has previously unsubscribed from all email
	I don't want to be subscribed by mistake

	Background:
		Given there are no existing mailing list subscriptions

	Scenario: I can subscribe to mailing lists
		Given I exist as a provider
			And I am logged in
			And I am on my contact preferences edit page
		When I check "Get the weekly emails parents love"
			And I check "Get our monthly newsletter for providers"
			And I save the account settings
		Then I should only be subscribed to the "parent_newsletters and provider_newsletters" mailing lists and synced to the list server

	Scenario: I cannot subscribe to mailing lists if I am blocked
		Given I exist as a provider
			And I opted out of receiving email from us
			And I am logged in
			And I am on my contact preferences edit page
		When I check "Get the weekly emails parents love"
			And I check "Get our monthly newsletter for providers"
			And I save the account settings
		Then I should not be subscribed to any mailing lists
