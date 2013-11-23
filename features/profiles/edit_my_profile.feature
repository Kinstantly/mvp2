Feature: Edit my expert profile
	So that potential clients can see up-to-date profile information for me
	As a registered expert
	I want to edit in my profile information
	
	@javascript
	Scenario: Enter insurance accepted
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "insurance" formlet
			And I enter "Blue Cross\nKaiser Permanente" in the "Insurance" field of the "insurance" formlet
			And I click on the "Save" button of the "insurance" formlet
		Then my profile edit page should show "Blue Cross" displayed in the "insurance" area
			And my profile edit page should show "Kaiser Permanente" displayed in the "insurance" area
	
	@javascript
	Scenario: Enter insurance accepted with an embedded link
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "insurance" formlet
			And I enter "For info click here: http://en.wikipedia.org/wiki/Health_insurance" in the "Insurance" field of the "insurance" formlet
			And I click on the "Save" button of the "insurance" formlet
		Then my profile edit page should show "en.wikipedia.org" displayed as a link in the "insurance" area
	
	@javascript
	Scenario: Remain on edit page while editing
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "website" formlet
			And I enter "www.sfopera.com" in the "Website" field of the "website" formlet
			And I click on the "Save" button of the "website" formlet
		Then I should remain on the profile edit page
	
	@javascript
	Scenario: Remain on edit page after cancel edit
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "insurance" formlet
			And I click on the "Cancel" link of the "website" formlet
		Then I should remain on the profile edit page
	
	@javascript
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
	
	@javascript
	Scenario: Country code is US by default
		Given I exist as a user
			And I am logged in
			And I have no country code in my profile
		When I am on my profile edit page
			And I open the "locations" formlet
			And I click on the "Save" button of the "locations" formlet
		Then my country code should be set to "US"
	
	@javascript
	Scenario: Country code is preserved
		Given I exist as a user
			And I am logged in
			And I have a country code of "CA" in my profile
		When I am on my profile edit page
			And I open the "locations" formlet
			And I click on the "Save" button of the "locations" formlet
		Then my country code should be set to "CA"
	
	@javascript
	Scenario: Select categories
		Given the "THERAPISTS & PARENTING COACHES" and "TUTORS & COUNSELORS" categories are predefined
			And I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I open the "categories" formlet
			And I select the "TUTORS & COUNSELORS" category
			And I click on the "Save" button of the "categories" formlet
		Then my profile edit page should show "TUTORS & COUNSELORS" displayed in the "categories" area
		
	@javascript
	Scenario: Select services associated with my category
		Given I exist as a user
			And I am logged in
			And I have a category of "THERAPISTS & PARENTING COACHES" in my profile that is associated with the "child psychologist" and "child psychiatrist" services
			And I am on my profile edit page
		When I open the "services" formlet
			And I select the "child psychologist" and "child psychiatrist" services
			And I click on the "Save" button of the "services" formlet
		Then my profile edit page should show "child psychologist" and "child psychiatrist" displayed in the "services" area
	
	@javascript
	Scenario: Offer services for predefined category
		Given the predefined category of "THERAPISTS & PARENTING COACHES" is associated with the "child psychologist" and "child psychiatrist" services
			And I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I open the "services" formlet
			And I select the "THERAPISTS & PARENTING COACHES" category
		Then then I should be offered the "child psychologist" and "child psychiatrist" services
	
	@javascript
	Scenario: Offer no predefined services when I have selected no predefined categories
		Given I exist as a user
			And I am logged in
			And I have no predefined categories and no services in my profile
			And I am on my profile edit page
		When I open the "services" formlet
		Then I should be offered no services

	@javascript
	Scenario: Add custom services
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I open the "services" formlet
			And I add the "story-book reader" and "dream catcher" custom services
			And I click on the "Save" button of the "services" formlet
		Then my profile edit page should show "story-book reader" and "dream catcher" displayed in the "services" area
		
	@javascript
	Scenario: Added custom services appear in check list on next profile edit
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I open the "services" formlet
			And I add the "story-book reader" and "dream catcher" custom services
			And I click on the "Save" button of the "services" formlet
			And I open the "services" formlet
		Then the "story-book reader" and "dream catcher" services should appear in the profile edit check list
		
	@javascript
	Scenario: Add custom services using enter
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I open the "services" formlet
			And I add the "story-book reader" and "dream catcher" custom services using enter
			And I click on the "Save" button of the "services" formlet
		Then my profile edit page should show "story-book reader" and "dream catcher" displayed in the "services" area
		
	@javascript
	Scenario: Select specialties associated with my service
		Given I exist as a user
			And I am logged in
			And I have a service of "child psychiatrist" in my profile that is associated with the "behavior" and "adoption" specialties
			And I am on my profile edit page
		When I open the "specialties" formlet
			And I select the "behavior" and "adoption" specialties
			And I click on the "Save" button of the "specialties" formlet
		Then my profile edit page should show "behavior" and "adoption" displayed in the "specialties" area
	
	@javascript
	Scenario: Add custom specialties
		Given I exist as a user
			And I am logged in
			And I have a category of "THERAPISTS & PARENTING COACHES" in my profile
			And I am on my profile edit page
		When I open the "specialties" formlet
			And I add the "story-books" and "dreams" custom specialties
			And I click on the "Save" button of the "specialties" formlet
		Then my profile edit page should show "story-books" and "dreams" displayed in the "specialties" area
	
	@javascript
	Scenario: Add custom specialties using enter
		Given I exist as a user
			And I am logged in
			And I have a category of "THERAPISTS & PARENTING COACHES" in my profile
			And I am on my profile edit page
		When I open the "specialties" formlet
			And I add the "story-books" and "dreams" custom specialties using enter
			And I click on the "Save" button of the "specialties" formlet
		Then my profile edit page should show "story-books" and "dreams" displayed in the "specialties" area
	
	@javascript
	Scenario: Offer specialties for predefined service
		Given the predefined category of "THERAPISTS & PARENTING COACHES" is associated with the "child psychologist" and "child psychiatrist" services
			And the predefined service of "child psychiatrist" is associated with the "adoption" and "toilet training" specialties
			And I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "specialties" formlet
			And I select the "THERAPISTS & PARENTING COACHES" category
			And I select the "child psychiatrist" service
		Then then I should be offered the "adoption" and "toilet training" specialties
	
	@javascript
	Scenario: Offer no predefined specialties when I have selected no predefined services
		Given I exist as a user
			And I am logged in
			And I have no predefined services and no specialties in my profile
			And I am on my profile edit page
		When I open the "specialties" formlet
		Then I should be offered no specialties
	
	@javascript
	Scenario: Update Ages/Stages comment
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I open the "ages" formlet
			And I enter "Beginners to advanced" in the "Add a comment" field of the "ages" formlet
			And I click on the "Save" button of the "ages" formlet
		Then my profile edit page should show "Beginners to advanced" displayed in the "ages" area
	
	@javascript
	Scenario: Update Ages/Stages
		Given there is a "Teens" age range
			And there is a "Young adults" age range
			And I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I open the "stages" formlet
			And I check "Teens" in the "stages" formlet
			And I check "Young adults" in the "stages" formlet
			And I click on the "Save" button of the "stages" formlet
		Then my profile edit page should show "Teens" displayed in the "stages" area
			And my profile edit page should show "Young adults" displayed in the "stages" area
	
	@javascript
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
	
	@javascript
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
	
	@javascript
	Scenario: Enter hours
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "hours" formlet
			And I enter "10-5 M-F\n1-4 Sa" in the "Hours" field of the "hours" formlet
			And I click on the "Save" button of the "hours" formlet
		Then my profile edit page should show "10-5 M-F" displayed in the "hours" area
			And my profile edit page should show "1-4 Sa" displayed in the "hours" area
	
	@javascript
	Scenario: Check hours availability options
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "hours" formlet
			And I check "Evening hours available" in the "hours" formlet
			And I check "Weekend hours available" in the "hours" formlet
			And I click on the "Save" button of the "hours" formlet
		Then my profile edit page should show "Evening hours available" displayed second in the "hours" area
			And my profile edit page should show "Weekend hours available" displayed third in the "hours" area
	
	@javascript
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
	
	@javascript
	Scenario: Check pricing options
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "pricing" formlet
			And I check "Free initial consult" in the "pricing" formlet
			And I check "Sliding scale available" in the "pricing" formlet
			And I click on the "Save" button of the "pricing" formlet
		Then my profile edit page should show "Free initial consult" displayed second in the "pricing" area
			And my profile edit page should show "Sliding scale available" displayed third in the "pricing" area
	
	@javascript
	Scenario: Add a comment for availability/service area
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "availability/service area" formlet
			And I enter "East Bay\nSan Francisco\nDaly City" in the "Add a comment" field of the "availability/service area" formlet
			And I click on the "Save" button of the "availability/service area" formlet
		Then my profile edit page should show "East Bay" displayed third in the "availability/service area" area
			And my profile edit page should show "San Francisco" displayed third in the "availability/service area" area
			And my profile edit page should show "Daly City" displayed third in the "availability/service area" area
	
	@javascript
	Scenario: Specify consultation modes
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "availability/service area" formlet
			And I check "Email consultations" in the "availability/service area" formlet
			And I check "Phone consultations" in the "availability/service area" formlet
			And I check "Video consultations" in the "availability/service area" formlet
			And I check "Home visits" in the "availability/service area" formlet
			And I check "School visits" in the "availability/service area" formlet
			And I click on the "Save" button of the "availability/service area" formlet
		Then my profile edit page should show "Email consultations" displayed in the "availability/service area" area
			And my profile edit page should show "Phone consultations" displayed in the "availability/service area" area
			And my profile edit page should show "Video consultations" displayed in the "availability/service area" area
			And my profile edit page should show "Home visits" displayed in the "availability/service area" area
			And my profile edit page should show "School visits" displayed in the "availability/service area" area
	
	@javascript
	Scenario: Specify accepting new clients
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "availability/service area" formlet
			And I check "Accepting new clients" in the "availability/service area" formlet
			And I click on the "Save" button of the "availability/service area" formlet
		Then my profile edit page should show "Accepting new clients" displayed second in the "availability/service area" area
	
	@javascript
	Scenario: Request extra location
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "locations" formlet
			And I click on the "Fill in a new location" link of the "locations" formlet
			And I click on the "Save" button of the "locations" formlet
		Then I should see form fields for an extra location on my profile edit page
	
	@javascript
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
	
	@javascript
	Scenario: Delete location
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "locations" formlet
			And I click on the "Mark the above location for removal" link
			And I click on the "Save" button of the "locations" formlet
		Then my profile should have no locations
	
	@javascript
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

	@javascript
	Scenario: Enter year started
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "year started" formlet
			And I enter "2007" in the "Year started" field of the "year started" formlet
			And I click on the "Save" button of the "year started" formlet
		Then my profile edit page should show "2007" displayed in the "year started" area

	@javascript
	@photo_upload
	Scenario: Add profile photo from my computer
		Given I exist as a user
			And I am logged in
			And I have "no" profile photo
			And I am on my profile edit page
		When I open the "profile photo" formlet
			And I see step "one" of "profile photo" formlet
			And I upload a valid image file "profile_photo_test_under1MB.jpg"
		Then edit my profile page should show "profile_photo_test_under1MB.jpg" image as my profile photo

	@javascript
	@photo_upload
	Scenario: Import profile photo from URL
		Given I exist as a user
			And I am logged in
			And I have "no" profile photo
			And I am on my profile edit page
		When I open the "profile photo" formlet
			And I see step "one" of "profile photo" formlet
			And I import a valid image file from "http://upload.wikimedia.org/wikipedia/commons/5/56/Tux.jpg"
		Then edit my profile page should show "Tux.jpg" image as my profile photo

	@javascript
	@photo_upload
	Scenario: Change profile photo
		Given I exist as a user
			And I am logged in
			And I have "a" profile photo
			And I am on my profile edit page
		When I open the "profile photo" formlet
			And I see step "two" of "profile photo" formlet
			And I click on the "upload a different photo" link of the "profile photo" formlet
			And I upload a valid image file "profile_photo_test_under1MB.jpg"
		Then edit my profile page should show "profile_photo_test_under1MB.jpg" image as my profile photo

	@javascript
	@photo_upload
	Scenario: Edit profile photo
		Given I exist as a user
			And I am logged in
			And I have "a" profile photo
			And I am on my profile edit page
			And I open the "profile photo" formlet
		When I see step "two" of "profile photo" formlet
			And I click on the "edit_profile_photo" link of the "profile photo" formlet
		Then my profile should show "Photo Editor"

	@javascript
	@photo_upload
	Scenario: View photo upload help page
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "profile_photo" formlet
			And I click on the "more detailed help" link of the "profile photo" formlet
		 	And I see step "three" of "profile photo" formlet
		Then my profile should show "More detailed help for photos:" within "step_three"
			
