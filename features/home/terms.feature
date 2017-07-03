Feature: Terms of Use
	In order to feel confident and safe about using this service
	As a client
	I want to see this service's terms of use

	Scenario: display a "Terms of use" link
		Given I am not logged in
		When I visit the "/" page
		Then I should see "Terms of use" on the page
