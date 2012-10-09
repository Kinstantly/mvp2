Feature: Policies
	In order to feel confident and safe about using this service
	As a client
	I want to see this service's policies

	Scenario: show policies
		Given I am not logged in
		When I visit the "policies" page
		Then I should see explanations of our policies
