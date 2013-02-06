Feature: Edit account
	In order to maintain my account
	As a provider or client
	I want to change my account settings

	Scenario: Change password
		Given I exist as a user
			And I am logged in
			And I am on my account edit page
		When I enter a new password
			And I save the account settings
		Then I should see an account edited message

	Scenario: Change email address
		Given I exist as a user
			And I am logged in
			And I am on my account edit page
		When I enter a new email address of "gyorgy@ligeti.com"
			And I save the account settings
			And "gyorgy@ligeti.com" opens the email
		 	And I follow "confirm" in the email
		Then I see a confirmed account message

	Scenario: Change username as a client
		Given I am logged in as a client user
			And I am on my account edit page
		When I enter a new username
			And I save the account settings
		Then I should see an account edited message