Feature: Start building my expert profile
	As a newly registered expert
	I want to start filling in my profile information
	So that potential clients can see my profile information
	
	Scenario: Land on profile edit page after registering and confirming
		Given I do not exist as a user
		When I sign up with valid user data
			And I open the email
		 	And I follow "confirm" in the email
		Then I should land on the profile edit page
	
	Scenario: Enter basic information
		Given an empty profile right after registration and confirmation
		When I enter my basic profile information
		Then my basic information should be saved in my profile
