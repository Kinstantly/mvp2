@javascript
Feature: Story teasers on the home page
	In order to attract parents to our site
	As a story editor
	I want parents to see on their first visit to our site that we have interesting stories

	Background:
		Given I am logged in as an administrator

	Scenario: Adding a story teaser to the home page has been disabled
		When I visit the "/story_teasers/new" page
			And I check "Active"
			And I enter "1" in the "Display order" field
			And I enter "http://blog.kinstantly.com/toddler-making-coffee/" in the "Url" field
			And I enter "coffee_570_380.jpg" in the "Image file" field
			And I enter "This toddler makes coffee for his dad but doesn't drink it" in the "Title" field
			And I click on the "Create Story teaser" button
		Then I should see "Story teaser was successfully created" on the page
			And I visit the "/" page
		Then I should not see "This toddler makes coffee for his dad but doesn't drink it" on the page
