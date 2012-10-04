Feature: View existing profiles
	In order to view expert profiles en mass
	As an administrator
	I want see a table listing of all expert profiles

	Scenario: View all expert profiles
		Given I am logged in
			And there are multiple profiles in the system
		When I visit the profile index page
		Then I should see more than one profile

	Scenario: Must be logged in to view profiles
		Given I am not logged in
			And I want a profile
		When I visit the profile index page
		Then I should not see profile data
