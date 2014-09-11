Feature: Edit an expert's profile
	In order to maintain accurate information on our site
	As a site administrator or profile editor
	I want to edit an expert's profile

	@javascript
	Scenario: Save edited profile as an administrator
		Given I am logged in as an administrator
			And I visit the edit page for an unclaimed profile
		When I open the "display name" formlet
			And I enter "Capulet" in the "Last name" field of the "display name" formlet
			And I click on the "Save" button of the "display name" formlet
		Then the last name in the unclaimed profile should be "Capulet"

	@javascript
	Scenario: Publish profile as an administrator
		Given I am logged in as an administrator
			And I visit the edit page for an unpublished profile
		When I open the "admin" formlet
			And I check the publish box in the "admin" formlet
			And I click on the "Save" button of the "admin" formlet
		Then the previously unpublished profile should be published

	@javascript
	Scenario: Save edited profile as a profile editor
		Given I am logged in as a profile editor
			And I visit the edit page for an unclaimed profile
		When I open the "display name" formlet
			And I enter "Capulet" in the "Last name" field of the "display name" formlet
			And I click on the "Save" button of the "display name" formlet
		Then the last name in the unclaimed profile should be "Capulet"

	@javascript
	Scenario: Save notes as an administrator
		Given I am logged in as an administrator
			And I visit the edit page for an unclaimed profile
		When I open the "admin" formlet
			And I enter "Bel piacere e godere fido amor" in the "Admin notes" field of the "admin" formlet
			And I click on the "Save" button of the "admin" formlet
		Then the profile should show "Bel piacere e godere fido amor"

	@javascript
	Scenario: Log a lead generator as an administrator
		Given I am logged in as an administrator
			And I visit the edit page for an unclaimed profile
		When I open the "admin" formlet
			And I enter "Miah Persson" in the "Lead generator" field of the "admin" formlet
			And I click on the "Save" button of the "admin" formlet
		Then the profile should show "Miah Persson"

	@javascript
	@profile_help
	Scenario: No profile help link for an administrator
		Given I am logged in as an administrator
			And I visit the edit page for an unclaimed profile
		Then the profile should not show "Profile help"
