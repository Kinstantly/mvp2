Feature: Site administrator edits a profile
	In order to help parents find relevant providers
	As a site administrator or profile editor
	I want to edit provider profiles using the admin interface

	@javascript
	Scenario: Add a set of fields for a new location
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with no locations
		When I click on the "Fill in a new location" link
		Then I should see form fields for an extra location on the admin profile edit page

	@javascript
	Scenario: Enter address in a second location
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with no locations
		When I click on the "Fill in a new location" link
			And I enter "La Fenice" in the "Street address" field of the second location on the admin profile edit page
			And I save the profile
			And I click on the link to see all locations
		Then the profile should show "La Fenice"
