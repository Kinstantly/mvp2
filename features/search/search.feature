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

	Scenario: show city and state in search result
		Given a published profile with city "Pesaro" and state "CA"
			And I visit the "/" page
		When I enter "Pesaro" in the search box
		Then I should see "Pesaro" and "CA" in the search results list

	Scenario: restrict search by search area tag
		Given a published profile with last name "Caballe", specialty "ADHD", and search area tag "North Bay"
			And I visit the "/" page
		When I enter "ADHD" in the search box and select the "North Bay" search area tag
		Then I should see "Caballe" and "ADHD" in the search results list

	Scenario: order search results by distance from postal code
		Given a published profile with city "San Mateo" and state "CA"
			And another published profile with city "San Francisco" and state "CA"
			And I visit the "/" page
		When I enter "San Francisco CA" in the search box
			And I enter "94025" in the search-by-distance box
		Then I should see "San Mateo" first in the search results list

	Scenario: order search results by distance from city
		Given a published profile with city "San Mateo" and state "CA"
			And another published profile with city "San Francisco" and state "CA"
			And I visit the "/" page
		When I enter "San Francisco CA" in the search box
			And I enter "Menlo Park" in the search-by-city box
		Then I should see "San Mateo" first in the search results list
