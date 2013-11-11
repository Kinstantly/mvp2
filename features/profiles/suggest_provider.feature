Feature: Review provider
	In order to help parents find a good provider
	As a parent
	I want to suggest a provider be added to the database

	Scenario: I have the option to suggest a provider from the search results
		Given a published profile exists
			And I am not logged in
		When I enter published profile data in the search box
		Then I should see "Are we missing your favorite provider?" on the page

	Scenario: I have the option to suggest a provider from the contact page
		Given a published profile exists
			And I am not logged in
		When I visit the "contact" page
		Then I should see "Are we missing your favorite provider?" on the page
