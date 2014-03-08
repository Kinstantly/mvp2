@javascript
Feature: View all profiles
	In order to view all expert profiles
	As a site administrator or profile editor
	I want see a table listing of all expert profiles

	Scenario: View all expert profiles as an administrator
		Given I am logged in as an administrator
			And there are multiple profiles in the system
		When I visit the profile index page
		Then I should see more than one profile

	Scenario: Select profile page to view as an administrator
		Given there is an unclaimed profile
			And I am logged in as an administrator
			And I visit the profile index page
		When I click on the link for an unclaimed profile
		Then I should land on the view page for the unclaimed profile

	Scenario: View all expert profiles as a profile editor
		Given I am logged in as a profile editor
			And there are multiple profiles in the system
		When I visit the profile index page
		Then I should see more than one profile

	Scenario: Select profile page to view as a profile editor
		Given there is an unclaimed profile
			And I am logged in as a profile editor
			And I visit the profile index page
		When I click on the link for an unclaimed profile
		Then I should land on the view page for the unclaimed profile
