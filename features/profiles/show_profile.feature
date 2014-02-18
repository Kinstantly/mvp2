@javascript
Feature: View a provider's profile
	In order to determine if I want to contact and how to contact a provider
	As a parent
	I want to see all of the provider's public profile information

	Scenario: Provider's name is in the page title
		Given a published profile with last name "Cabell" and category "NEW MOM SUPPORT"
			And I am not logged in
		When I visit the published profile page
		Then I should see "Cabell" in the page title

	Scenario: Provider's specialty is in the meta-data
		Given a published profile with last name "Cabell" and specialty "soprano"
			And I am not logged in
		When I visit the published profile page
		Then meta-data should contain "soprano"

	Scenario: Administrator can see admin notes
		Given a published profile with admin notes "Nessun dorma"
			And I am logged in as an administrator
		When I visit the published profile page
		Then the profile should show "Nessun dorma"

	Scenario: Profile editor can see admin notes
		Given a published profile with admin notes "Nessun dorma"
			And I am logged in as a profile editor
		When I visit the published profile page
		Then the profile should show "Nessun dorma"

	Scenario: Provider cannot see admin notes in their own profile
		Given my profile with admin notes "Nessun dorma"
			And I am logged in
		When I view my profile
		Then I should see my profile information
			And my profile should not show "Nessun dorma"

	Scenario: Public cannot see admin notes
		Given a published profile with admin notes "Nessun dorma"
			And I am not logged in
		When I visit the published profile page
		Then the profile should not show "Nessun dorma"

	Scenario: Provider has a review on their profile page
		Given I am not logged in
		When I visit the view page for a published profile with one review
		Then the profile should show the review

	Scenario: Provider's location displayed on map
		Given I am not logged in 
			And I visit the view page for a published profile with one location
		When I visit the published profile page
		Then I should see a Google Map

	Scenario: Info for Provider with remote services and no locations displayed instead of map
		Given I am not logged in 
			And I visit the view page for a published profile with no locations
		Then I should see "controllers.profiles.location_remote_only" message
