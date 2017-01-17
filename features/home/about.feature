Feature: About
	In order to understand what this venture is about
	As a client or expert
	I want see a statement about this venture

	Background:
	Given I am not logged in
	When I visit the "/" page

	Scenario: display an "About us" link that redirects off site
		Then I should see "About us" on the page
