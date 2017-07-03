Feature: Contact
	In order to get more information or give feedback
	As an expert or client
	I want to use a contact for me ask a question or make a comment

	Scenario: display a "Contact us" link
		Given I am not logged in
		When I visit the "/" page
		Then I should see "Contact us" on the page
