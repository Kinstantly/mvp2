Feature: Edit my expert profile
	So that potential clients can see up-to-date profile information for me
	As a registered expert
	I want to edit in my profile information
	
	Scenario: Enter basic information
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I edit my profile information
		Then my edited information should be saved in my profile
	
	Scenario: Enter user information
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I edit my email address
		Then my email address should be saved to my user record
	
	Scenario: Check insurance accepted
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I check "Insurance accepted"
			And I save my profile
		Then my profile should show "Insurance accepted"
	
	Scenario: Land on view page after edit
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I edit my profile information
		Then I should land on the profile view page
	
	Scenario: Land on view page after edit
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I click on the cancel link
		Then I should land on the profile view page
	
	Scenario: Country code is US by default
		Given I exist as a user
			And I am logged in
			And I have no country code in my profile
		When I am on my profile edit page
			And I save my profile
		Then my country code should be set to "US"
	
	Scenario: Country code is preserved
		Given I exist as a user
			And I am logged in
			And I have a country code of "CA" in my profile
		When I am on my profile edit page
			And I save my profile
		Then my country code should be set to "CA"
	
	Scenario: Select categories
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I select the "child psychiatrist" and "developmental-behavioral pediatrician" categories
			And I save my profile
		Then my profile should show me as being in the "child psychiatrist" and "developmental-behavioral pediatrician" categories
	
	@javascript
	Scenario: Add custom categories
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I add the "story-book reader" and "dream catcher" custom categories
			And I save my profile
		Then my profile should show me as being in the "story-book reader" and "dream catcher" categories
		
	@javascript
	Scenario: Select specialties
		Given I exist as a user
			And I am logged in
			And I have a category of "developmental-behavioral pediatrician" in my profile
			And I am on my profile edit page
		When I select the "behavior" and "developmental delay" specialties
			And I save my profile
		Then my profile should show me as having the "behavior" and "developmental delay" specialties
	
	@javascript
	Scenario: Add custom specialties
		Given I exist as a user
			And I am logged in
			And I have a category of "developmental-behavioral pediatrician" in my profile
			And I am on my profile edit page
		When I add the "story-books" and "dreams" custom specialties
			And I save my profile
		Then my profile should show me as having the "story-books" and "dreams" specialties
	
	@javascript
	Scenario: Offer specialties for given categories
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I select the "child psychiatrist" and "developmental-behavioral pediatrician" categories
		Then then I should be offered the "adoption" and "toilet training" specialties
	
	@javascript
	Scenario: Offer all specialties when I have selected no predefined categories
		Given I exist as a user
			And I have no predefined categories in my profile
			And I am logged in
		When I am on my profile edit page
		Then I should be offered all specialties

	Scenario: Select age ranges
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I select the "0 to 6" age range
			And I select the "6 to 12" age range
			And I save my profile
		Then my profile should show the "0 to 6" age range
			And my profile should show the "6 to 12" age range
	
	@javascript
	Scenario: Show display name as editing
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I set my first name to "Philo"
			And I set my middle name to "T."
			And I set my last name to "Farnsworth"
			And I set my credentials to "MD, PhD"
		Then the display name should be dynamically shown as "Philo T. Farnsworth, MD, PhD"
	
	Scenario: Update display name
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I set my first name to "Philo"
			And I set my middle name to "T."
			And I set my last name to "Farnsworth"
			And I set my credentials to "MD, PhD"
			And I save my profile
		Then the display name should be updated to "Philo T. Farnsworth, MD, PhD"
