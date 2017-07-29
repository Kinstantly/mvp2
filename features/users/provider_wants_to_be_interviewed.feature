@javascript
Feature: Allow a provider to be added to the list of experts we consider when looking for someone to interview for articles on Kinstantly
	In order to gain exposure to new clients
	As a registered provider
	I want to indicate my desire to be interviewed for articles on Kinstantly
	
	Background:
		Given I am logged in as a provider
	
	Scenario: Indicate my desire to be interviewed for articles on Kinstantly
		Given I am on my profile edit page
		When I check "like to be added to the list of experts we consider when looking for someone to interview"
		Then my profile edit page should show "Saving" displayed in the "interview_me" area
			And my profile edit page should show "someone to interview" displayed in the "interview_me" area
			And I should be indicating that I want to be interviewed by Kinstantly
	
	Scenario: Notify admin that provider wants to be interviewed for articles on Kinstantly
		Given I am on my profile edit page
		When I check "like to be added to the list of experts we consider when looking for someone to interview"
			And "admin@kinstantly.com" opens the email with subject "Provider wants to be interviewed for articles"
		Then they should see "wants to be interviewed for articles" in the email body
	
	Scenario: No longer wants to be interviewed for articles on Kinstantly
		Given I am already indicating that I want to be interviewed by Kinstantly
			And I am on my profile edit page
		When I uncheck "like to be added to the list of experts we consider when looking for someone to interview"
		Then my profile edit page should show "Saving" displayed in the "interview_me" area
			And my profile edit page should show "someone to interview" displayed in the "interview_me" area
			And I should not be indicating that I want to be interviewed by Kinstantly
	
	Scenario: Notify admin that provider no longer wants to be interviewed for articles on Kinstantly
		Given I am already indicating that I want to be interviewed by Kinstantly
			And I am on my profile edit page
		When I uncheck "like to be added to the list of experts we consider when looking for someone to interview"
			And "admin@kinstantly.com" opens the email with subject "Provider no longer wants to be interviewed for articles"
		Then they should see /no longer(?:.|\s)+wants to be interviewed for articles/ in the email body
