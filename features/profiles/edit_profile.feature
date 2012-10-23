Feature: Edit an expert's profile
	In order to maintain accurate information on our site
	As a site administrator
	I want to edit an expert's profile

	Scenario: Edit profile page
		Given there is an unclaimed profile
			And I am logged in as an administrator
			And I visit the profile index page
		When I click on the edit link for an unclaimed profile
		Then I should land on the edit page for the unclaimed profile

	Scenario: Save edited profile
	  Given I am logged in as an administrator
			And I visit the edit page for the unclaimed profile
		When I set the last name to "Capulet"
			And I save the profile
	  Then the last name in the unclaimed profile should be "Capulet"
