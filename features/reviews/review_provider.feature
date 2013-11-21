Feature: Review provider
	In order to help parents choose a good provider
	As a parent
	I want to review a provider

	Scenario: I have the option to review a provider
		Given a published profile exists
			And I am not logged in
		When I visit the published profile page
		Then the profile should show "Review" within "rate-this"
