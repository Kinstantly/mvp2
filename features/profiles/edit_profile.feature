Feature: Edit my expert profile
	So that potential clients can see up-to-date profile information for me
	As a registered expert
	I want to edit in my profile information
	
	Scenario: Enter basic information
		Given I am on my profile edit page
		When I enter profile information
		Then it should be saved in my profile
