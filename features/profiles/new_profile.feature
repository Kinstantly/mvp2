Feature: Create a new expert profile
	As a site administrator or profile editor
	I want to create a new profile on behalf of an expert
	So that we can list that expert and invite them to take ownership of this profile
	
	Scenario: Create new profile from profile admin page
		Given I am logged in as an administrator
		When I visit the profile admin page
			And I create the profile
		Then I should see an edit profile form
	
	@javascript
	Scenario: Create new profile as an administrator
		Given I am logged in as an administrator
		When I visit the profile admin page
			And I create the profile
			And I enter profile information
			And I click on the "View profile" link
		Then I should see the new profile data
	
	@javascript
	Scenario: Create and publish new profile as an administrator
		Given I am logged in as an administrator
		When I visit the profile admin page
			And I create the profile
			And I enter profile information
			And I open the "admin" formlet
			And I check the publish box in the "admin" formlet
			And I click on the "Save" button of the "admin" formlet
		Then the new profile should be published
	
	Scenario: Create new profile as a profile editor
		Given I am logged in as a profile editor
		When I visit the profile admin page
			And I create the profile
		Then I should see an edit profile form
