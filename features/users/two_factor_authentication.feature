@javascript
Feature: Sign in with two-factor authenticaion
	In order to get access to protected sections of the site
	A user
	Should be granted access after signing in with a one-time password

	Background:
		Given I am logged in as an administrator requiring two-factor authentication
			And I visit my account edit page
		
	Scenario: User is required to enter one-time password
		Then I should see the two-factor authentication page
		
	Scenario: User enters correct one-time password
		When I submit the correct one-time password
		Then I should be signed in with two-factor authentication
		
	Scenario: User enters incorrect one-time password
		When I submit an incorrect one-time password
		Then I should see the two-factor authentication page
		
	Scenario: User runs out of tries
		When I submit an incorrect one-time password
			And I submit an incorrect one-time password
			And I submit an incorrect one-time password
			And I submit an incorrect one-time password
			And I submit an incorrect one-time password
		Then I should have run out of two-factor authentication attempts
