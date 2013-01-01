Feature: search the provider directory
	In order to get expert advice
	As a parent
	I want to search the provider directory

	Scenario: search the provider directory as a site visitor
		Given a published profile exists
			And I am not logged in
		When I enter published profile data in the search box
		Then I should see profile data in the search results list

	Scenario: show name and category in search result
		Given a published profile with last name "Tebaldi" and category "OPERA"
			And I visit the "/" page
		When I enter "Tebaldi" in the search box
		Then I should see "Tebaldi" and "OPERA" in the search results list

	Scenario: show city and service in search result
		Given a published profile with city "Pesaro" and service "lirico-spinto soprano"
			And I visit the "/" page
		When I enter "Pesaro" in the search box
		Then I should see "Pesaro" and "lirico-spinto soprano" in the search results list
