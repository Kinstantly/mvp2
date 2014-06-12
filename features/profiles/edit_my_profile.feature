@javascript
Feature: Edit my expert profile
	So that potential clients can see up-to-date profile information for me
	As a registered expert
	I want to edit in my profile information
	
	Scenario: Enter insurance accepted
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "insurance" formlet
			And I enter "Blue Cross\nKaiser Permanente" in the "Insurance" field of the "insurance" formlet
			And I click on the "Save" button of the "insurance" formlet
		Then my profile edit page should show "Blue Cross" displayed in the "insurance" area
			And my profile edit page should show "Kaiser Permanente" displayed in the "insurance" area
	
	Scenario: Enter insurance accepted with an embedded link
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "insurance" formlet
			And I enter "For info click here: http://en.wikipedia.org/wiki/Health_insurance" in the "Insurance" field of the "insurance" formlet
			And I click on the "Save" button of the "insurance" formlet
		Then my profile edit page should show "en.wikipedia.org" displayed as a link in the "insurance" area
	
	Scenario: Remain on edit page while editing
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "website" formlet
			And I enter "www.sfopera.com" in the "Website" field of the "website" formlet
			And I click on the "Save" button of the "website" formlet
		Then I should remain on the profile edit page
	
	Scenario: Remain on edit page after cancel edit
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "insurance" formlet
			And I click on the "Cancel" link of the "website" formlet
		Then I should remain on the profile edit page
	
	Scenario: Edit location address
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "locations" formlet
			And I enter "123 Main St." in the "Street address" field of the "locations" formlet
			And I enter "Ames" in the "City" field of the "locations" formlet
			And I select "Iowa" as the state in the "locations" formlet
			And I enter "50010" in the "Zip Code" field of the "locations" formlet
			And I enter "505-555-0123" in the "Phone" field of the "locations" formlet
			And I enter "Bike parking in front." in the "Add a comment" field of the "locations" formlet
			And I click on the "Save" button of the "locations" formlet
		Then my profile edit page should show "123 Main St." displayed in the "locations" area
			And my profile edit page should show "Ames" displayed in the "locations" area
			And my profile edit page should show "IA" displayed in the "locations" area
			And my profile edit page should show "50010" displayed in the "locations" area
			And my profile edit page should show "(505) 555-0123" displayed second in the "locations" area
			And my profile edit page should show "Bike parking in front." displayed third in the "locations" area
	
	Scenario: Country code is US by default
		Given I exist as a user
			And I am logged in
			And I have no country code in my profile
		When I am on my profile edit page
			And I open the "locations" formlet
			And I click on the "Save" button of the "locations" formlet
		Then my country code should be set to "US"
	
	Scenario: Country code is preserved
		Given I exist as a user
			And I am logged in
			And I have a country code of "CA" in my profile
		When I am on my profile edit page
			And I open the "locations" formlet
			And I click on the "Save" button of the "locations" formlet
		Then my country code should be set to "CA"
	
	Scenario: Fill in specialties
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "specialties" formlet
			And I fill in the "story-books" and "dreams" specialties
			And I click on the "Save" button of the "specialties" formlet
		Then my profile edit page should show "story-books" and "dreams" displayed in the "specialties" area
	
	Scenario: Filled-in specialties appear in field list on next profile edit
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "specialties" formlet
			And I fill in the "story-books" and "dreams" specialties
			And I click on the "Save" button of the "specialties" formlet
			And I open the "specialties" formlet
		Then the "story-books" and "dreams" specialties should appear in the profile edit input list
	
	Scenario: Fill in specialties using enter
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "specialties" formlet
			And I fill in the "story-books" and "dreams" specialties using enter
			And I click on the "Save" button of the "specialties" formlet
		Then my profile edit page should show "story-books" and "dreams" displayed in the "specialties" area
	
	Scenario: Update Ages/stages text
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I open the "ages" formlet
			And I enter "Beginners to advanced" in the "Ages/stages" field of the "ages" formlet
			And I click on the "Save" button of the "ages" formlet
		Then my profile edit page should show "Beginners to advanced" displayed in the "ages" area
	
	Scenario: Show display name as editing
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I open the "display name" formlet
			And I set my first name to "Philo"
			And I set my middle name to "T."
			And I set my last name to "Farnsworth"
			And I set my credentials to "MD, PhD"
		Then the display name should be dynamically shown as "Philo T. Farnsworth, MD, PhD"
	
	Scenario: Update display name
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I open the "display name" formlet
			And I set my first name to "Philo"
			And I set my middle name to "T."
			And I set my last name to "Farnsworth"
			And I set my credentials to "MD, PhD"
			And I click on the "Save" button of the "display name" formlet
		Then my profile edit page should show "Philo T. Farnsworth, MD, PhD" displayed in the "display name" area
	
	Scenario: Enter hours
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "hours" formlet
			And I enter "10-5 M-F\n1-4 Sa" in the "Hours" field of the "hours" formlet
			And I click on the "Save" button of the "hours" formlet
		Then my profile edit page should show "10-5 M-F" displayed in the "hours" area
			And my profile edit page should show "1-4 Sa" displayed in the "hours" area
	
	Scenario: Enter pricing
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "pricing" formlet
			And I enter "$1/minute\n$40/15 minutes\n$120/hour" in the "Fees" field of the "pricing" formlet
			And I click on the "Save" button of the "pricing" formlet
		Then my profile edit page should show "$1/minute" displayed in the "pricing" area
			And my profile edit page should show "$40/15 minutes" displayed in the "pricing" area
			And my profile edit page should show "$120/hour" displayed in the "pricing" area
	
	Scenario: Add text for Availability/service area
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "availability/service area" formlet
			And I enter "East Bay\nSan Francisco\nDaly City" in the "Availability/service area" field of the "availability/service area" formlet
			And I click on the "Save" button of the "availability/service area" formlet
		Then my profile edit page should show "East Bay" displayed in the "availability/service area" area
			And my profile edit page should show "San Francisco" displayed in the "availability/service area" area
			And my profile edit page should show "Daly City" displayed in the "availability/service area" area
	
	Scenario: Request extra location
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "locations" formlet
			And I click on the "Fill in a new location" link of the "locations" formlet
			And I click on the "Save" button of the "locations" formlet
		Then I should see form fields for an extra location on my profile edit page
	
	Scenario: Enter extra location
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "locations" formlet
			And I click on the "Fill in a new location" link
			And I enter "La Fenice" in the "Street address" field of the second location on my profile edit page
			And I click on the "Save" button of the "locations" formlet
			And I click on the link to see all locations
		Then my profile edit page should show "La Fenice" displayed third in the "locations" area
	
	Scenario: Delete location
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "locations" formlet
			And I click on the "Mark the above location for removal" link
			And I click on the "Save" button of the "locations" formlet
		Then my profile should have no locations
	
	Scenario: Enter phone number
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "locations" formlet
			And I enter "505-555-9087x47 " in the "Phone" field of the first location on my profile edit page
			And I click on the "Save" button of the "locations" formlet
		Then my profile edit page should show "(505) 555-9087, x47" displayed second in the "locations" area
	
	Scenario: My profile should display my website with a link
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "website" formlet
			And I enter "www.sfopera.com" in the "Website" field of the "website" formlet
			And I click on the "Save" button of the "website" formlet
			And I view my profile
		Then my profile should show "www.sfopera.com" within "location a"

	Scenario: Enter year started
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "year started" formlet
			And I enter "2007" in the "Year started" field of the "year started" formlet
			And I click on the "Save" button of the "year started" formlet
		Then my profile edit page should show "2007" displayed in the "year started" area

	@photo_upload
	Scenario: Add profile photo from my computer
		Given I exist as a user
			And I am logged in
			And I have no profile photo
			And I am on my profile edit page
		When I open the "profile photo" formlet
			And I see step "one" of "profile photo" formlet
			And I upload a valid image file "profile_photo_test_under1MB.jpg"
			And I wait a bit
		Then edit my profile page should show "profile_photo_test_under1MB.jpg" image as my profile photo

	@photo_upload
	Scenario: Import profile photo from URL
		Given I exist as a user
			And I am logged in
			And I have no profile photo
			And I am on my profile edit page
		When I open the "profile photo" formlet
			And I see step "one" of "profile photo" formlet
			And I import a valid image file from "http://upload.wikimedia.org/wikipedia/commons/5/56/Tux.jpg"
		Then edit my profile page should show "Tux.jpg" image as my profile photo

	@photo_upload
	Scenario: Change profile photo
		Given I exist as a user
			And I am logged in
			And I have a profile photo
			And I am on my profile edit page
		When I open the "profile photo" formlet
			And I see step "two" of "profile photo" formlet
			And I click on the "upload a different photo" link of the "profile photo" formlet
			And I upload a valid image file "profile_photo_test_under1MB.jpg"
		Then edit my profile page should show "profile_photo_test_under1MB.jpg" image as my profile photo

	@photo_upload
	Scenario: Edit profile photo
		Given I exist as a user
			And I am logged in
			And I have a profile photo
			And I am on my profile edit page
			And I open the "profile photo" formlet
		When I see step "two" of "profile photo" formlet
			And I click on the "edit_profile_photo" link of the "profile photo" formlet
		Then my profile should show "Photo Editor"

	@photo_upload
	Scenario: View photo upload help page
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "profile_photo" formlet
			And I click on the "more detailed help" link of the "profile photo" formlet
		 	And I see step "three" of "profile photo" formlet
		Then my profile should show "More detailed help for photos:" within "step_three"

	@photo_upload
	Scenario: Click on profile photo placeholder to upload a photo
		Given I exist as a user
			And I am logged in
			And I have no profile photo
			And I am on my profile edit page
		When I click on the profile photo
		Then I should see step "one" of "profile photo" formlet

	@photo_upload
	Scenario: Click on profile photo to edit it
		Given I exist as a user
			And I am logged in
			And I have a profile photo
			And I am on my profile edit page
		When I click on the profile photo
		Then I should see step "two" of "profile photo" formlet

	Scenario: My profile page has an edit tab
		Given I exist as a user
			And I am logged in
		When I view my profile
		Then I should see an edit tab

	Scenario: I can switch to the edit tab from my profile page
		Given I exist as a user
			And I am logged in
		When I view my profile
			And I click on the profile edit tab
		Then I should see the "display name" formlet
