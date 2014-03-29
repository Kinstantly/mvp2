Feature: View only published profiles
	 In order to view published profiles
	 As a user
	 I want to see a table listing of published expert profiles

	Scenario: Cannot view all unpublished expert profiles
		Given I exist as a user
			And I am logged in
			And there are multiple unpublished profiles in the system
		When I visit the profile link index page
		Then I should not see profile data that is not my own

	Scenario: Cannot view unpublished profiles
		Given I am not logged in
			And I want an unpublished profile
		When I visit the profile link index page
		Then I should not see profile data

	Scenario: Can view published profiles
		Given I am not logged in
			And I want a published profile
		When I visit the profile link index page
		Then I should see published profile data

	@private_site
	Scenario: New visitor cannot view published profiles when running as a private site
		Given I am not logged in
			And I want a published profile
		When I visit the profile link index page
		Then I should land on the alpha sign-up page
