Feature: Create a new expert profile
	As a site administrator or profile editor
	I want to create a new profile on behalf of an expert
	So that we can list that expert and invite them to take ownership of this profile
	
	Scenario: Create new profile from profile admin page
		Given I am logged in as an administrator
		When I visit the profile admin page
			And I create the profile
		Then I should see an edit profile form
	
	Scenario: New profile page as an administrator
		Given I am logged in as an administrator
		When I visit the new profile page
		Then I should see a new profile form
	
	Scenario: Create new profile as an administrator
		Given I am logged in as an administrator
		When I visit the new profile page
			And I enter new profile information
			And I create the profile
		Then the new profile should be saved
	
	Scenario: Create and publish new profile as an administrator
		Given I am logged in as an administrator
		When I visit the new profile page
			And I enter new profile information
			And I check the publish box
			And I create the profile
		Then the new profile should be published
	
	Scenario: New profile page as a profile editor
		Given I am logged in as a profile editor
		When I visit the new profile page
		Then I should see a new profile form
	
	Scenario: Create new profile as a profile editor
		Given I am logged in as a profile editor
		When I visit the new profile page
			And I enter new profile information
			And I create the profile
		Then the new profile should be saved
