Feature: Privacy Policy
	In order to feel confident and safe about using this service
	As a client
	I want to see this service's privacy policy

	Scenario: display a "Privacy policy" link
		Given I am not logged in
		When I visit the "/" page
		Then I should see "Privacy policy" on the page
