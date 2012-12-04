Feature: Create a new expert profile
	As a site administrator
	I want to create a new profile on behalf of an expert
	So that we can list that expert and invite them to take ownership of this profile
	
	Scenario: New profile page
		Given I am logged in as an administrator
		When I visit the new profile page
		Then I should see a new profile form
	
	Scenario: Create new profile
		Given I am logged in as an administrator
		When I visit the new profile page
			And I enter new profile information
			And I save the profile
		Then the new profile should be saved
	
	Scenario: Create and publish new profile
		Given I am logged in as an administrator
		When I visit the new profile page
			And I enter new profile information
			And I check the publish box
			And I save the profile
		Then the new profile should be published
