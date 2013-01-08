Feature: search the provider directory
	In order to get expert advice
	As a parent
	I want to search the provider directory

	Scenario: search the provider directory as a site visitor
		Given a published profile exists
			And I am not logged in
		When I enter published profile data in the search box
		Then I should see profile data in the search results list

	Scenario: show name and specialty in search result
		Given a published profile with last name "Tebaldi" and specialty "ADHD"
			And I visit the "/" page
		When I enter "Tebaldi" in the search box
		Then I should see "Tebaldi" and "ADHD" in the search results list

	Scenario: show city and postal code in search result
		Given a published profile with city "Pesaro" and postal code "98765"
			And I visit the "/" page
		When I enter "Pesaro" in the search box
		Then I should see "Pesaro" and "98765" in the search results list

	Scenario: restrict search by search area tag
		Given a published profile with last name "Caballe", specialty "ADHD", and search area tag "North Bay"
			And I visit the "/" page
		When I enter "ADHD" in the search box and select the "North Bay" search area tag
		Then I should see "Caballe" and "ADHD" in the search results list
