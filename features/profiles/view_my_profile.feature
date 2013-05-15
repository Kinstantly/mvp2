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

		Scenario: Edit link on profile view page
			Given I exist as a user
				And I want my profile
				And I am logged in
			When I view my profile
				And click edit my profile
			Then I should land on the profile edit page

		Scenario: At least one service is in meta-data
			Given I exist as a user
				And I want my profile
				And I am logged in
			When I view my profile
			Then meta-data should contain one of my services

		Scenario: See at least one specialty
			Given I exist as a user
				And I want my profile
				And I am logged in
			When I view my profile
			Then I should see one of my specialties
