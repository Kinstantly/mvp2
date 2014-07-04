Feature: Browse by category
	In order to find the right provider
	As a parent
	I want a comprehensive list of categories and services on the home page

	Scenario: Category appears on the home page
		Given a category authored to appear in the "first" column on the home page
		When I visit the "/" page
		Then I should see that authored category

	Scenario: Category appears in the second column on the home page
		Given a category authored to appear in the "second" column on the home page
		When I visit the "/" page
		Then I should see that authored category in the "second" column

	Scenario: Category does not appear on the home page
		Given a category authored to not appear on the home page
		When I visit the "/" page
		Then I should not see that authored category

	Scenario: Subcategory appears on the home page
		Given a subcategory authored to appear on the home page
		When I visit the "/" page
		Then I should see that authored subcategory

	Scenario: Subcategory does not appear on the home page
		Given a subcategory authored to not appear on the home page
		When I visit the "/" page
		Then I should not see that authored subcategory

	Scenario: Service appears on the home page
		Given a service authored to appear on the home page
		When I visit the "/" page
		Then I should see that authored service

	Scenario: Service does not appear on the home page
		Given a service authored to not appear on the home page
		When I visit the "/" page
		Then I should not see that authored service
