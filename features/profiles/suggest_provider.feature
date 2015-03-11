Feature: Review provider
	In order to help parents find a good provider
	As a parent
	I want to suggest a provider be added to the database

	@search
	Scenario: I have the option to suggest a provider from the search results
		Given a published profile exists
			And I am not logged in
			And I visit the "/" page
		When I enter published profile data in the search box
		Then I should see "Are we missing a great provider?" on the page
