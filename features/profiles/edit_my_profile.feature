Feature: Edit my expert profile
	So that potential clients can see up-to-date profile information for me
	As a registered expert
	I want to edit in my profile information
	
	Scenario: Enter basic information
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I edit my profile information
		Then my edited information should be saved in my profile
	
	Scenario: Enter insurance accepted
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I enter "Blue Cross\nKaiser Permanente" in the "Health insurance accepted" field
			And I save my profile
		Then my profile should show "Blue Cross"
			And my profile should show "Kaiser Permanente"
	
	Scenario: Land on view page after edit
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I edit my profile information
		Then I should land on the profile view page
	
	Scenario: Land on view page after cancel edit
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I click on the cancel link
		Then I should land on the profile view page
	
	Scenario: Edit location address
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I enter "123 Main St." in the "Address" field
			And I enter "Ames" in the "City" field
			And I select "Iowa" as the state
			And I enter "50010" in the "Zip code" field
			And I save my profile
		Then my profile should show "123 Main St." in the location area
			And my profile should show "Ames" in the location area
			And my profile should show "IA" in the location area
			And my profile should show "50010" in the location area
	
	Scenario: Country code is US by default
		Given I exist as a user
			And I am logged in
			And I have no country code in my profile
		When I am on my profile edit page
			And I save my profile
		Then my country code should be set to "US"
	
	Scenario: Country code is preserved
		Given I exist as a user
			And I am logged in
			And I have a country code of "CA" in my profile
		When I am on my profile edit page
			And I save my profile
		Then my country code should be set to "CA"
	
	Scenario: Select categories
		Given the "THERAPISTS & PARENTING COACHES" and "TUTORS & COUNSELORS" categories are predefined
			And I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I select the "TUTORS & COUNSELORS" category
			And I save my profile
		Then my profile should show me as being in the "TUTORS & COUNSELORS" category
		
	@javascript
	Scenario: Select services associated with my category
		Given I exist as a user
			And I am logged in
			And I have a category of "THERAPISTS & PARENTING COACHES" in my profile that is associated with the "child psychologist" and "child psychiatrist" services
			And I am on my profile edit page
		When I select the "child psychologist" and "child psychiatrist" services
			And I save my profile
		Then my profile should show me as having the "child psychologist" and "child psychiatrist" services
	
	@javascript
	Scenario: Offer services for predefined category
		Given the predefined category of "THERAPISTS & PARENTING COACHES" is associated with the "child psychologist" and "child psychiatrist" services
			And I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I select the "THERAPISTS & PARENTING COACHES" category
		Then then I should be offered the "child psychologist" and "child psychiatrist" services
	
	@javascript
	Scenario: Offer no predefined services when I have selected no predefined categories
		Given I exist as a user
			And I am logged in
			And I have no predefined categories and no services in my profile
		When I am on my profile edit page
		Then I should be offered no services

	@javascript
	Scenario: Add custom services
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I add the "story-book reader" and "dream catcher" custom services
			And I save my profile
		Then my profile should show me as being in the "story-book reader" and "dream catcher" services
		
	@javascript
	Scenario: Added custom services appear in check list on next profile edit
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I add the "story-book reader" and "dream catcher" custom services
			And I save my profile
			And I go to my profile edit page
		Then the "story-book reader" and "dream catcher" services should appear in the profile edit check list
		
	@javascript
	Scenario: Add custom services using tab
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I add the "story-book reader" and "dream catcher" custom services using tab
			And I save my profile
		Then my profile should show me as being in the "story-book reader" and "dream catcher" services
		
	@javascript
	Scenario: Select specialties associated with my service
		Given I exist as a user
			And I am logged in
			And I have a service of "child psychiatrist" in my profile that is associated with the "behavior" and "adoption" specialties
			And I am on my profile edit page
		When I select the "behavior" and "adoption" specialties
			And I save my profile
		Then my profile should show me as having the "behavior" and "adoption" specialties
	
	@javascript
	Scenario: Add custom specialties
		Given I exist as a user
			And I am logged in
			And I have a category of "THERAPISTS & PARENTING COACHES" in my profile
			And I am on my profile edit page
		When I add the "story-books" and "dreams" custom specialties
			And I save my profile
		Then my profile should show me as having the "story-books" and "dreams" specialties
	
	@javascript
	Scenario: Add custom specialties using tab
		Given I exist as a user
			And I am logged in
			And I have a category of "THERAPISTS & PARENTING COACHES" in my profile
			And I am on my profile edit page
		When I add the "story-books" and "dreams" custom specialties using tab
			And I save my profile
		Then my profile should show me as having the "story-books" and "dreams" specialties
	
	@javascript
	Scenario: Offer specialties for predefined service
		Given the predefined category of "THERAPISTS & PARENTING COACHES" is associated with the "child psychologist" and "child psychiatrist" services
			And the predefined service of "child psychiatrist" is associated with the "adoption" and "toilet training" specialties
			And I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I select the "THERAPISTS & PARENTING COACHES" category
			And I select the "child psychiatrist" service
		Then then I should be offered the "adoption" and "toilet training" specialties
	
	@javascript
	Scenario: Offer no predefined specialties when I have selected no predefined services
		Given I exist as a user
			And I am logged in
			And I have no predefined services and no specialties in my profile
		When I am on my profile edit page
		Then I should be offered no specialties

	Scenario: Select age ranges
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I select the "0 to 6" age range
			And I select the "6 to 12" age range
			And I save my profile
		Then my profile should show the "0 to 6" age range
			And my profile should show the "6 to 12" age range
	
	@javascript
	Scenario: Show display name as editing
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I set my first name to "Philo"
			And I set my middle name to "T."
			And I set my last name to "Farnsworth"
			And I set my credentials to "MD, PhD"
		Then the display name should be dynamically shown as "Philo T. Farnsworth, MD, PhD"
	
	Scenario: Update display name
		Given I exist as a user
			And I want my profile
			And I am logged in
			And I am on my profile edit page
		When I set my first name to "Philo"
			And I set my middle name to "T."
			And I set my last name to "Farnsworth"
			And I set my credentials to "MD, PhD"
			And I save my profile
		Then the display name should be updated to "Philo T. Farnsworth, MD, PhD"
	
	Scenario: Enter pricing
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I enter "$1/minute\n$40/15 minutes\n$120/hour" in the "Pricing" field
			And I save my profile
		Then my profile should show "$1/minute"
			And my profile should show "$40/15 minutes"
			And my profile should show "$120/hour"
	
	Scenario: Enter service area
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I enter "East Bay\nSan Francisco\nDaly City" in the "Service area" field
			And I save my profile
		Then my profile should show "East Bay"
			And my profile should show "San Francisco"
			And my profile should show "Daly City"
	
	Scenario: Specify consultation modes
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I check "Email consultations"
			And I check "Phone consultations"
			And I check "Video consultations"
			And I check "In-person consultations"
			And I save my profile
		Then my profile should show "email" within "consultations"
			And my profile should show "phone" within "consultations"
			And my profile should show "video" within "consultations"
			And my profile should show "in-person" within "consultations"
	
	Scenario: Enter specialties description
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I enter "challenging behavior, attachment issues, temperament" in the "My specialties" field
			And I save my profile
		Then my profile should show "challenging behavior, attachment issues, temperament" within "specialties_description"
	
	@javascript
	Scenario: Request extra location
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I click on the "Fill in another location" link
		Then I should see form fields for an extra location
	
	@javascript
	Scenario: Enter extra location
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I click on the "Fill in another location" link
			And I enter "La Fenice" in the "Address" field of the second location
			And I save my profile
		Then my profile should show "La Fenice" in the location area
	
	@javascript
	Scenario: Delete location
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I click on the "Mark this location for removal" link
			And I save my profile
		Then my profile should have no locations
	
	Scenario: Enter phone number
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I enter "505-555-9087x47 " in the "Phone" field of the first location
			And I save my profile
		Then my profile should show "(505) 555-9087, x47" in the location area
	
	Scenario: My profile should display my website with a link
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I enter "www.sfopera.com" in the "Website" field
			And I save my profile
		Then my profile should show "www.sfopera.com" within "url a"
