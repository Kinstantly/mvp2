@javascript
Feature: View my expert profile
	As a registered expert
	I want to view my profile
	so I can know how it looks to potential clients

		Scenario: See profile information
			Given I exist as a user
				And I want my profile
				And I am logged in
			When I view my profile
			Then I should see my profile information

		Scenario: See at least one specialty
			Given I exist as a user
				And I want my profile
				And I am logged in
			When I view my profile
			Then I should see one of my specialties
