Feature: View only published profiles
	 In order to view published profiles
	 As a user
	 I want to see a table listing of all published expert profiles

	Scenario: Cannot view all unpublished expert profiles
		Given I am logged in
			And there are multiple unpublished profiles in the system
		When I visit the profile index page
		Then I should not see profile data that is not my own

	Scenario: Cannot view unpublished profiles
		Given I am not logged in
			And I want an unpublished profile
		When I visit the profile index page
		Then I should not see profile data

	Scenario: Can view published profiles
		Given I am not logged in
			And I want a published profile
		When I visit the profile index page
		Then I should see published profile data