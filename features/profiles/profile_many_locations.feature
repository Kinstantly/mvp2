@javascript
Feature: Profile with many locations
	In order to choose a close provider or let parents know all my locations
	As a parent or provider
	I want to see all the locations for a provider, not just the first one.

	Scenario: On provider's profile page, only the first location is visible
		Given a published profile with cities "Albuquerque" and "Durham" and states "NM" and "NC"
			And I am not logged in
		When I visit the published profile page
		Then the profile should show "Albuquerque" within the first location address
			And the profile should show "NM" within the first location address
			And the profile should not show "Durham" within the second location address
			And the profile should not show "NC" within the second location address

	Scenario: On provider's profile page, click link to see all locations
		Given a published profile with cities "Albuquerque" and "Durham" and states "NM" and "NC"
			And I am not logged in
		When I visit the published profile page
			And I click on the link to see all locations
		Then the profile should show "Albuquerque" within the first location address
			And the profile should show "NM" within the first location address
			And the profile should show "Durham" within the second location address
			And the profile should show "NC" within the second location address
