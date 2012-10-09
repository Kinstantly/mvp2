Feature: Register as an expert
	In order to get us this service to give advice
	As an expert
	I want to register

	# @javascript
	Scenario: show expert registration form
		Given I am not logged in
		When I visit the "become_expert" page
		Then I should see a Google form
