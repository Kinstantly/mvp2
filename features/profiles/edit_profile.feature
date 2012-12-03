Feature: Edit an expert's profile
	In order to maintain accurate information on our site
	As a site administrator
	I want to edit an expert's profile

	Scenario: Save edited profile
	  Given I am logged in as an administrator
			And I visit the edit page for the unclaimed profile
		When I enter "Capulet" in the "Last name" field
			And I save the profile
	  Then the last name in the unclaimed profile should be "Capulet"
