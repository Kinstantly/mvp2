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
		Then the published profile should have an average rating of <average_rating>
		
		Scenarios: Various ratings
			| rating | average_rating |
			| 1      | 1.0            |
			| 2      | 2.0            |
			| 3      | 3.0            |
			| 4      | 4.0            |
			| 5      | 5.0            |
