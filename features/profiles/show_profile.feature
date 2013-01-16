Feature: View a provider's profile
	In order to determine if I want to contact and how to contact a provider
	As a parent
	I want to see all of the provider's public profile information

	Scenario: Provider's name is in the page title
		Given a published profile with last name "Cabell" and category "NEW MOM SUPPORT"
			And I am not logged in
		When I visit the published profile page
		Then I should see "Cabell" in the page title
