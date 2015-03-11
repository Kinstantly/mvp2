@javascript
Feature: Edit Announcements
	In order to advertise site visitors about my events, blog posts, publications, deals, payments etc
	As a provider
	I want to be able to author my own announcements
	And I want to have them show up on my profile and on the search results page

	Scenario: I have the option to add an announcement
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		Then I should see "views.announcement.edit.new_announcement_prompt" text on the page

	Scenario: Create an active profile announcement
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "announcement_new" formlet
			And I enter "Register now for Summer Camp!" in the "Headline" field of the "announcement_new" formlet
			And I enter "Camps fill up quickly" in the "Text area" field of the "announcement_new" formlet
			And I enter "Register now!" in the "Button text" field of the "announcement_new" formlet
			And I enter "http://example.com" in the "Button link" field of the "announcement_new" formlet
			And I enter a valid start date and a future end date in the Date range section of the "announcement_new" formlet
			And I click on the "Save" button of the "announcement_new" formlet
			And I view my profile
		Then I should see "Register now for Summer Camp!" on the page
			And I should see "Camps fill up quickly" on the page
			And I should see a "Register now!" button linked to "http://example.com" on the page

	Scenario: Create inactive profile announcement
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "announcement_new" formlet
			And I enter "Register now for Summer Camp!" in the "Headline" field of the "announcement_new" formlet
			And I enter "Camps fill up quickly" in the "Text area" field of the "announcement_new" formlet
			And I enter "Register now!" in the "Button text" field of the "announcement_new" formlet
			And I enter "http://example.com" in the "Button link" field of the "announcement_new" formlet
			And I enter a past start date and a past end date in the Date range section of the "announcement_new" formlet
			And I click on the "Save" button of the "announcement_new" formlet
			And I view my profile
		Then I should not see "Register now for Summer Camp!" on the page
			And I should not see "Camps fill up quickly" on the page

	Scenario: Delete profile announcement
		Given I exist as a user
			And I am logged in
			And I have an announcement with "Register now for Summer Camp!" headline in my profile
			And I go to my profile edit page
		When I open the "announcement_0" formlet
			And I click on the "Remove" link of the "announcement_0" formlet
			And I confirm alert
		Then I should not see "Register now for Summer Camp!" on the page

	@search
	Scenario: Create an active search result announcement
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
			And my profile is published
		When I open the "announcement_new" formlet
			And I enter "Register now for Summer Camp!" in the "Headline" field of the "announcement_new" formlet
			And I enter "Camps fill up quickly" in the "Text area" field of the "announcement_new" formlet
			And I enter "Register now!" in the "Button text" field of the "announcement_new" formlet
			And I enter "http://example.com" in the "Button link" field of the "announcement_new" formlet
			And I enter a valid start date and a future end date in the Date range section of the "announcement_new" formlet
			And I enter "Register now for Summer Camp!" in the "Announcement text (to appear in search results)" field of the "announcement_new" formlet
			And I click on the "Save" button of the "announcement_new" formlet
			And I search for my profile
		Then I should see "Register now for Summer Camp!" in the search results list
