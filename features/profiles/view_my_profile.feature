Feature: View my expert profile
	As a registered expert
	I want to view my profile
	so I can know how it looks to potential clients

		Scenario: See profile information
			Given I am logged in
				And I want my profile
			When I view my profile
			Then I should see my profile information

		Scenario: Edit link on profile view page
			Given I am logged in
				And I want my profile
			When I view my profile
				And Click edit profile
			Then I should land on the profile edit page

		Scenario: See at least one category
			Given I am logged in
				And I want my profile
			When I view my profile
			Then I should see one of my categories

		Scenario: See at least one specialty
			Given I am logged in
				And I want my profile
			When I view my profile
			Then I should see one of my specialties
