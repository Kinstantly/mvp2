@javascript
Feature: Suggest a provider
	In order to help other parents find a provider I like
	As a parent
	I want to suggest a provider not listed in the directory

	Scenario: Bring up provider suggestion form
		Given I am on the search results page
		When I click on "Tell us"
		Then I should see "Thanks for helping us find another great provider" on the page

	Scenario: Submit provider suggestion form
		Given I am on the search results page
			And I click on "Tell us"
		When I enter "ETA Hoffmann" in the "Your name" field
			And I enter "etahoffmann@example.org" in the "Your email" field
			And I enter "Jacques Offenbach" in the "Name of person" field
			And I enter "en.wikipedia.org/wiki/The_Tales_of_Hoffmann" in the "URL of provider" field
			And I enter "A German-born French composer, cellist and impresario." in the "What services" field
			And I click on the "Submit" button
		Then I should see "Thank you for suggesting 'Jacques Offenbach'" on the page

	Scenario: Neglect to enter required fields on the provider suggestion form
		Given I am on the search results page
			And I click on "Tell us"
		When I enter "ETA Hoffmann" in the "Your name" field
			And I enter "Jacques Offenbach" in the "Name of person" field
			And I enter "en.wikipedia.org/wiki/The_Tales_of_Hoffmann" in the "URL of provider" field
			And I click on the "Submit" button
		Then I should see "Your email address is required" on the page
			And I should see "Description of services is required" on the page

	Scenario: Bring up provider suggestion form while logged in
		Given I am logged in as a parent
			And I am on the search results page
		When I click on "Tell us"
		Then I should see "Thanks for helping us find another great provider" on the page

	Scenario: Submit provider suggestion form while logged in
		Given I am logged in as a parent
			And I am on the search results page
			And I click on "Tell us"
			And I enter "Jacques Offenbach" in the "Name of person" field
			And I enter "en.wikipedia.org/wiki/The_Tales_of_Hoffmann" in the "URL of provider" field
			And I enter "A German-born French composer, cellist and impresario." in the "What services" field
			And I click on the "Submit" button
		Then I should see "Thank you for suggesting 'Jacques Offenbach'" on the page
