Feature: Rate provider
	In order to help parents choose a good provider
	As a parent
	I want to rate a provider

	@javascript
	Scenario Outline: Rate provider as a signed-in parent
		Given a published profile exists
			And I exist as a user
			And I am logged in
		When I visit the published profile page
			And I click on the <rating> star
		Then my rating for this provider should be <saved_rating>
		
		Scenarios: Various ratings
			| rating | saved_rating |
			| 1      | 1            |
			| 2      | 2            |
			| 3      | 3            |
			| 4      | 4            |
			| 5      | 5            |

	@javascript
	Scenario: Rate provider when not signed in
		Given a published profile exists
			And I am not logged in
		When I visit the published profile page
			And I click on the 5 star
		Then I should land on the member sign-up page

	@javascript
	Scenario: Sign up during provider rating process
		Given a published profile exists
			And I am not logged in
		When I visit the published profile page
			And I click on the 5 star
			And I sign up as a non-expert with valid user data
			And I open the email with subject "Confirmation instructions"
			And I follow "confirm" in the email
		Then my rating for this provider should be 5
