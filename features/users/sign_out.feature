@javascript
Feature: Sign out
	To protect my account from unauthorized access
	A signed-in user
	Should be able to sign out

	Scenario: User signs out
		Given I exist as a user
			And I am logged in
		When I sign out
		Then I should see a signed out message
