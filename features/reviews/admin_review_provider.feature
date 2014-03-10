@javascript
Feature: Administrator maintains parent reviews of providers
	In order to maintain provider reviews done by parents
	As an administrator
	I want to create and edit reviews done by parents

	Scenario: Create a review
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with no reviews
		When I enter "Hank Williams is the best!" in the new review on the admin profile edit page
			And I enter "Go Hank!" as the title in the new review on the admin profile edit page
			And I enter "Do not be fooled by Jr." as the good-to-know in the new review on the admin profile edit page
			And I enter "charlie@example.com" as the reviewer email in the new review on the admin profile edit page
			And I enter "CharlieDick" as the reviewer username in the new review on the admin profile edit page
			And I give a rating of "4" in the new review on the admin profile edit page
			And I click "Save" in the new review on the admin profile edit page
			And I visit the admin view page for the current profile
		Then the profile should show "Hank Williams is the best!"
			And the profile should show "Go Hank!"
			And the profile should show "Do not be fooled by Jr."
			And the profile should show "CharlieDick"
			And the profile should show "Score: 4.0"

	Scenario: Edit a review
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with one review
		When I enter "Hank Williams is the best!" in the first review on the admin profile edit page
			And I enter "jett@example.com" as the reviewer email of the first review on the admin profile edit page
			And I enter "jett_williams" as the reviewer username of the first review on the admin profile edit page
			And I give a rating of "5" on the first review on the admin profile edit page
			And I click "Save" in the first review on the admin profile edit page
			And I visit the admin view page for the current profile
		Then the profile should show "Hank Williams is the best!"
			And the profile should show "jett_williams"
			And the profile should show "Score: 5.0"

	Scenario: Save a review (to prove the converse of "Delete a review")
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with one review
		When I click "Save" in the first review on the admin profile edit page
		Then the profile should have 1 review

	Scenario: Delete a review
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with one review
		When I click "Delete" in the first review on the admin profile edit page
			And I wait a bit
		Then the profile should have no reviews
