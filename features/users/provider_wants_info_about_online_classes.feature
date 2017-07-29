@javascript
Feature: Allow a provider with a profile to request information about offering online classes via Kinstantly
	In order to offer online classes to parents
	As a registered provider
	I want to ask for information about creating and selling online classes via Kinstantly
	
	Background:
		Given I am logged in as a provider
	
	Scenario: Ask for information about online classes offered by Kinstantly
		Given I am on my profile edit page
		When I check "I'm interested in learning more about offering online classes on Kinstantly"
		Then my profile edit page should show "Saving" displayed in the "courses_info" area
			And my profile edit page should show "online classes on Kinstantly" displayed in the "courses_info" area
			And I should be asking for information about online classes on Kinstantly
	
	Scenario: Notify admin that provider wants information about online classes offered by Kinstantly
		Given I am on my profile edit page
		When I check "I'm interested in learning more about offering online classes on Kinstantly"
			And "admin@kinstantly.com" opens the email with subject "Provider wants info about online classes"
		Then they should see "wants information about online classes" in the email body
	
	Scenario: No longer wants information about online classes offered by Kinstantly
		Given I am already asking for information about online classes on Kinstantly
			And I am on my profile edit page
		When I uncheck "I'm interested in learning more about offering online classes on Kinstantly"
		Then my profile edit page should show "Saving" displayed in the "courses_info" area
			And my profile edit page should show "online classes on Kinstantly" displayed in the "courses_info" area
			And I should not be asking for information about online classes on Kinstantly
	
	Scenario: Notify admin that provider no longer wants information about online classes offered by Kinstantly
		Given I am already asking for information about online classes on Kinstantly
			And I am on my profile edit page
		When I uncheck "I'm interested in learning more about offering online classes on Kinstantly"
			And "admin@kinstantly.com" opens the email with subject "Provider no longer wants info about online classes"
		Then they should see /no longer(?:.|\s)+wants information about online classes/ in the email body
