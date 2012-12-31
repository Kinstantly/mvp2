Feature: search the provider directory
	In order to get expert advice
	As a parent
	I want to search the provider directory

	Scenario: search the provider directory as a site visitor
		Given a published profile exists
			And I am not logged in
		When I enter published profile data in the search box
		Then I should see profile data in the search results list
