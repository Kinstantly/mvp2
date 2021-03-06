@search
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

	Scenario: show city, region, and country in search result that is outside the US
		Given a published profile with city "Montreal", region "QC", and country "CA"
			And I visit the "/" page
		When I enter "Montreal" in the search box
		Then I should see "QC" and "Canada" in the search results list

	Scenario: order search results by distance from postal code
		Given a published profile with city "San Mateo" and state "CA"
			And another published profile with city "San Francisco" and state "CA"
			And I visit the "/" page
		When I enter "San Francisco CA" in the search box
			And I enter "94025" in the search location box
		Then I should see "San Mateo" first in the search results list

	Scenario: order search results by distance from city
		Given a published profile with city "San Mateo" and state "CA"
			And another published profile with city "San Francisco" and state "CA"
			And I visit the "/" page
		When I enter "San Francisco CA" in the search box
			And I enter "Menlo Park, CA" in the search location box
		Then I should see "San Mateo" first in the search results list

	Scenario: using search on a non-home page, order search results by distance from postal code
		Given a published profile with city "San Mateo" and state "CA"
			And another published profile with city "San Francisco" and state "CA"
			And I visit the view page for an existing published profile
		When I enter "San Francisco CA" in the search box
			And I enter "94025" in the search location box
		Then I should see "San Mateo" first in the search results list

	Scenario: using search on a non-home page, order search results by distance from city
		Given a published profile with city "San Mateo" and state "CA"
			And another published profile with city "San Francisco" and state "CA"
			And I visit the view page for an existing published profile
		When I enter "San Francisco CA" in the search box
			And I enter "Menlo Park, CA" in the search location box
		Then I should see "San Mateo" first in the search results list

	Scenario: search results displayed on map
		Given a published profile with last name "Tebaldi", specialty "soprano", and postal code "94107"
			And I am not logged in
			And I visit the "/" page
		When I enter "soprano" in the search box
		Then I should see "Tebaldi" and "soprano" in the search results list
			And I should see a Google Map container

	Scenario: no map displayed when there are no search results
		Given a published profile with last name "Tebaldi", specialty "soprano", and postal code "94107"
			And I am not logged in
			And I visit the "/" page
		When I enter "the brewing lair of the lost sierra" in the search box
		Then I should see no search results
			And I should not see a Google Map container

	Scenario: can search the provider directory from a profile page
		Given a published profile exists
			And I am not logged in
			And I visit the view page for the existing published profile
		When I enter published profile data in the search box
		Then I should see profile data in the search results list

	Scenario: empty search query should give no search results
		Given a published profile exists
			And I am not logged in
			And I visit the "/" page
		When I enter "" in the search box
		Then I should see no search results

	Scenario: search engine failure should result in a nice error message
		Given the search engine is not working
			And I am not logged in
			And I visit the "/" page
		When I enter "day camps" in the search box
		Then I should see "There was a problem while searching" on the page
			And I should see "Please try again" on the page
			And I should see no search results
