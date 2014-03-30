Feature: Privacy Policy
	In order to feel confident and safe about using this service
	As a client
	I want to see this service's privacy policy

	Scenario: show privacy policy
		Given I am not logged in
		When I visit the "/privacy" page
		Then I should see explanations of our privacy policy

	@private_site
	Scenario: show privacy policy when running as a private site
		Given I am not logged in
		When I visit the "/privacy" page
		Then I should see explanations of our privacy policy
