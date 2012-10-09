Feature: About
	In order to understand what this venture is about
	As a client or expert
	I want see a statement about this venture

	Scenario: display about page
		Given I am not logged in
		When I visit the "about" page
		Then I should see a statement about us
