Feature: Show user account to admin
	In order to support users in managing their accounts
	As an administrator
	I want to view the user account from the admin interface

	Scenario: Display send confirmation instructions form for unconfirmed user
		Given I am logged in as an administrator
		When I visit the account page for an unconfirmed user
		Then I should see confirmation instructions form

	Scenario: Display no send confirmation instructions form for confirmed user
		Given I am logged in as an administrator
		When I visit the account page for a confirmed user
		Then I should not see confirmation instructions form

	Scenario: Unpriveleged user cannot view page
		Given I exist as a user
			And I am logged in
		When I visit the account page for an unconfirmed user
		Then I should not land on the account page

	Scenario: Profile editor cannot view page
		Given I am logged in as a profile editor
		When I visit the account page for an unconfirmed user
		Then I should not land on the account page

	Scenario: Must be logged in to view page
		Given I am not logged in
		When I visit the account page for an unconfirmed user
		Then I should not land on the account page
