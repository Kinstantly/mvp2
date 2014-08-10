@javascript
Feature: Notify profile moderator
	As a site administrator
	I want to know what content providers are putting in their profile
	And I want the system to send an email alert each time a provider saves a pop-up form on the profile edit page
	
	Scenario: Site administrator edits a profile
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with no locations
		When I click on the "Fill in a new location" link
			And I enter "La Fenice" in the "Street address" field of the second location on the admin profile edit page
			And I save the profile
		Then "profile_monitor@kinstantly.com" should receive no emails with subject "Provider Profile updated on Kinstantly"
	
	Scenario: Profile editor edits a profile
		Given I am logged in as a profile editor
			And I visit the edit page for an unclaimed profile
		When I open the "display name" formlet
			And I enter "Capulet" in the "Last name" field of the "display name" formlet
			And I click on the "Save" button of the "display name" formlet
		Then "profile_monitor@kinstantly.com" should receive no emails with subject "Provider Profile updated on Kinstantly"
	
	Scenario: Profile owner edits their own profile
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "website" formlet
			And I enter "www.sfopera.com" in the "Website" field of the "website" formlet
			And I click on the "Save" button of the "website" formlet
		Then "profile_monitor@kinstantly.com" should receive an emails with subject "Provider Profile updated on Kinstantly"
	
	