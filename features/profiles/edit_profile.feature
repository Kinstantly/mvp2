Feature: Edit an expert's profile
	In order to maintain accurate information on our site
	As a site administrator or profile editor
	I want to edit an expert's profile

	Scenario: Save edited profile as an administrator
		Given I am logged in as an administrator
			And I visit the edit page for an unclaimed profile
		When I enter "Capulet" in the "Last name" display name field
			And I save the display name
		Then the last name in the unclaimed profile should be "Capulet"

	Scenario: Publish profile as an administrator
		Given I am logged in as an administrator
			And I visit the edit page for an unpublished profile
		When I check the publish box
			And I save the profile
		Then the previously unpublished profile should be published

	Scenario: Save edited profile as a profile editor
		Given I am logged in as a profile editor
			And I visit the edit page for an unclaimed profile
		When I enter "Capulet" in the "Last name" display name field
			And I save the display name
		Then the last name in the unclaimed profile should be "Capulet"

	Scenario: Assign search area tag as a profile editor
		Given there is a search area tag named "East Bay"
			And I am logged in as a profile editor
			And I visit the edit page for an unclaimed profile
		When I select "East Bay" as the search area tag
			And I save the profile
		Then the search area tag in the unclaimed profile should be "East Bay"

	Scenario: Save notes as an administrator
		Given I am logged in as an administrator
			And I visit the edit page for an unclaimed profile
		When I enter "Bel piacere e godere fido amor" in the "Admin notes" field
			And I save the profile
		Then the profile should show "Bel piacere e godere fido amor"

	Scenario: Log a lead generator as an administrator
		Given I am logged in as an administrator
			And I visit the edit page for an unclaimed profile
		When I enter "Miah Persson" in the "Lead generator" field
			And I save the profile
		Then the profile should show "Miah Persson"

