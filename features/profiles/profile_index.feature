Feature: View all profiles
	In order to view all expert profiles
	As a site administrator
	I want see a table listing of all expert profiles

	Scenario: View all expert profiles
		Given I am logged in as an administrator
			And there are multiple profiles in the system
		When I visit the profile index page
		Then I should see more than one profile

	Scenario: Cannot view all expert profiles
		Given I am logged in
			And there are multiple profiles in the system
		When I visit the profile index page
		Then I should not see profile data that is not my own

	Scenario: Must be logged in to view profiles
		Given I am not logged in
			And I want a profile
		When I visit the profile index page
		Then I should not see profile data
