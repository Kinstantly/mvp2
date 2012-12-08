Feature: View existing users
	In order to view all users
	As an administrator
	I want see a table listing of all users

	Scenario: View all users
		Given I am logged in as an administrator
			And there are multiple users with profiles in the system
		When I visit the user index page
		Then I should see more than one user

	Scenario: Unpriveleged user cannot view all users
		Given I am logged in
			And there are multiple users with profiles in the system
		When I visit the user index page
		Then I should not see user data that is not my own

	Scenario: Profile editor cannot view all users
		Given I am logged in as a profile editor
			And there are multiple users with profiles in the system
		When I visit the user index page
		Then I should not see user data that is not my own

	Scenario: Must be logged in to see users
		Given I am not logged in
			And a user with a profile exists
		When I visit the user index page
		Then I should not see user data

	Scenario: View a user's profile
		Given I am logged in as an administrator
			And a user with a profile exists
		When I visit the user index page
			And I click on a user profile link
		Then I should see profile data for that user
