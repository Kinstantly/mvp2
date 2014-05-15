@javascript
Feature: Notify provider suggestion moderator
	In order to expand our provider listings
	As a site administrator
	I want to be notified when a site visitor suggests a provider that we don't have in our listings

	Scenario: Profile moderator receives an email notification
		Given I am on the search results page
			And I click on "Tell us"
		When I enter "ETA Hoffmann" in the "Your name" field
			And I enter "etahoffmann@example.org" in the "Your email" field
			And I enter "Jacques Offenbach" in the "Name of person" field
			And I enter "en.wikipedia.org/wiki/The_Tales_of_Hoffmann" in the "URL of provider" field
			And I enter "A German-born French composer, cellist and impresario." in the "What services" field
			And I click the "Submit" button
		Then I should see "Thank you for suggesting 'Jacques Offenbach'" on the page
			And "profile_monitor@kinstantly.com" should receive an email with subject "New provider suggestion"
