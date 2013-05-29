Feature: Browse by category
	In order to find the right provider
	As a parent
	I want a comprehensive list of categories and services on the home page

	Scenario: Category appears on home page
		Given a category authored to appear on the home page
		When I visit the "/" page
		Then I should see that authored category

	Scenario: Service appears on home page
		Given a service authored to appear on the home page
		When I visit the "/" page
		Then I should see that authored service
