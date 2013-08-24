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
			And I enter "La Fenice" in the "Address" field of the second location on the admin profile edit page
			And I save the profile
			And I click on the link to see all locations
		Then the profile should show "La Fenice"

	@javascript
	Scenario: Add a set of fields for a review
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with no reviews
		When I click on the "Fill in a new review" link
		Then I should see form fields for a review on the admin profile edit page

	@javascript
	Scenario: Add a set of fields for a second review
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with one review
		When I click on the "Fill in a new review" link
		Then I should see form fields for a second review on the admin profile edit page

	@javascript
	Scenario: Edit a review
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with one review
		When I enter "Hank Williams is the best!" in the first review on the admin profile edit page
			And I enter "jett@example.com" as the reviewer email of the first review on the admin profile edit page
			And I enter "jett_williams" as the reviewer username of the first review on the admin profile edit page
			And I give a rating of "4" on the first review on the admin profile edit page
			And I save the profile
			And I click on the "View full profile" link
		Then the profile should show "Hank Williams is the best!"
			And the profile should show "jett_williams"
			And the profile should show "Score: 4.0"
