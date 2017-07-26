@javascript
Feature: Options a provider can agree to, or not, from their profile edit tab
	In order to take advantage of content marketing and to offer online classes via Kinstantly
	As a registered provider
	I want to opt in to interviews, online classes, and possibly other offerings
	
	Background:
		Given I am logged in as a provider
			And I am on my profile edit page
	
	Scenario: Ask for information about online classes offered by Kinstantly
		When I check "I'm interested in learning more about offering online classes on Kinstantly"
		Then my profile edit page should show "Saving" displayed in the "courses_info" area
			And my profile edit page should show "online classes on Kinstantly" displayed in the "courses_info" area
			And I should be asking for information about online classes on Kinstantly
