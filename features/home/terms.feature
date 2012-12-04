Feature: Terms of Use
	In order to feel confident and safe about using this service
	As a client
	I want to see this service's terms of use

	Scenario: show terms of use
		Given I am not logged in
		When I visit the "terms" page
		Then I should see explanations of our terms of use
