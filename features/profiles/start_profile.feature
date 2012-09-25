Feature: Start building my expert profile
	As a newly registered expert
	I want to start filling in my profile information
	So that potential clients can see my profile information
	
	Scenario: Land on profile edit page after registering
		Given I do not exist as a user
		When I sign up with valid user data
		Then I should land on the profile edit page
	
	Scenario: Enter basic information
		Given an empty profile right after registration
		When I enter my basic profile information
		Then it should be saved in my profile
