@javascript
Feature: View existing users
	In order to view all users
	As an administrator
	I want see a table listing of all users

	Scenario: View all users
		Given there are multiple users with profiles in the system
			And I am logged in as an administrator
		When I visit the user index page
		Then I should see more than one user

	Scenario: Unpriveleged user cannot view all users
		Given there are multiple users with profiles in the system
			And I exist as a user
			And I am logged in
		When I visit the user index page
		Then I should not see user data that is not my own

	Scenario: Profile editor cannot view all users
		Given there are multiple users with profiles in the system
			And I am logged in as a profile editor
		When I visit the user index page
		Then I should not see user data that is not my own

	Scenario: Must be logged in to see users
		Given I am not logged in
			And a user with a profile exists
		When I visit the user index page
		Then I should not see user data

	Scenario: View a user's profile
		Given a user with a profile exists
			And I am logged in as an administrator
		When I visit the user index page
			And I click on a user profile link
		Then I should see profile data for that user

	Scenario: View a user edit page
		Given there are multiple users with profiles in the system
			And I am logged in as an administrator
		When I visit the user index page
			And I click on an edit account link
		Then I should land on edit account page
