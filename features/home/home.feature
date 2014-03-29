Feature: Home page
	In order to find a parenting provider
	As a parent that is new to Kinstantly
	I want see what Kinstantly has to offer

	Scenario: View home page
		Given I am not logged in
		When I visit the "/" page
		Then I should land on the home page

	@private_site
	Scenario: New visitor cannot view home page when running as a private site
		Given I am not logged in
		When I visit the "/" page
		Then I should land on the alpha sign-up page
