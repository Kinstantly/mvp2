Feature: View my expert profile
	As a registered expert
	I want to view my profile
	so I can know how it looks to potential clients

		Scenario: Email
			Given I am logged in
			When I view my profile
			Then I should see my email

		Scenario: First name
		  Given I am logged in
		  When I view my profile
		  Then I should see my first name
