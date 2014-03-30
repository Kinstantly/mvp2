Feature: Contact
	In order to get more information or give feedback
	As an expert or client
	I want to use a contact for me ask a question or make a comment

	Scenario: show contact-us and/or feedback form
		Given I am not logged in
		When I visit the "/contact" page
		Then I should see contact information

	@private_site
	Scenario: show contact-us and/or feedback form when running as a private site
		Given I am not logged in
		When I visit the "/contact" page
		Then I should see contact information
