Feature: Start building my expert profile
	As a newly registered expert
	I want to start filling in my profile information
	So that potential clients can see my profile information
	
	@javascript
	@profile_help
	Scenario: Land on profile edit page after registering and confirming
		Given I do not exist as a user
		When I sign up with valid user data
			And I open the email
		 	And I follow "confirm" in the email
		Then I should land on the profile edit page
			And the profile should show "Welcome to your profile"
