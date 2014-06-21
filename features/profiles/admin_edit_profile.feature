Feature: Site administrator edits a profile
	In order to help parents find relevant providers
	As a site administrator or profile editor
	I want to edit provider profiles using the admin interface

	@javascript
	Scenario: Add a set of fields for a new location
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with no locations
		When I click on the "Fill in a new location" link
		Then I should see form fields for an extra location on the admin profile edit page

	@javascript
	Scenario: Enter address in a second location
		Given I am logged in as an administrator
			And I visit the admin edit page for an unclaimed profile with no locations
		When I click on the "Fill in a new location" link
			And I enter "La Fenice" in the "Street address" field of the second location on the admin profile edit page
			And I save the profile
			And I click on the link to see all locations
		Then the profile should show "La Fenice"

	Scenario: Update Ages/Stages as a profile editor
		Given there is a "Teenagers" age range
			And there is a "Young adults" age range
			And I am logged in as a profile editor
		When I visit the admin edit page for an unclaimed profile
			And I check "Teenagers"
			And I check "Young adults"
			And I save the profile
			And I visit the admin view page for the existing unclaimed profile
		Then I should see "Teenagers" on the page
			And I should see "Young adults" on the page

	Scenario: Check hours availability options
		Given I am logged in as a profile editor
		When I visit the admin edit page for an unclaimed profile
			And I check "Evening hours available"
			And I check "Weekend hours available"
			And I save the profile
			And I visit the admin view page for the existing unclaimed profile
		Then I should see "Evening hours available" on the page
			And I should see "Weekend hours available" on the page

	Scenario: Check pricing options
		Given I am logged in as a profile editor
		When I visit the admin edit page for an unclaimed profile
			And I check "Free initial consult"
			And I check "Sliding scale available"
			And I save the profile
			And I visit the admin view page for the existing unclaimed profile
		Then I should see "Free initial consult" on the page
			And I should see "Sliding scale available" on the page

	Scenario: Specify consultation modes
		Given I am logged in as a profile editor
		When I visit the admin edit page for an unclaimed profile
			And I check "Email consultations"
			And I check "Phone consultations"
			And I check "Video consultations"
			And I check "Home visits"
			And I check "School visits"
			And I save the profile
			And I visit the admin view page for the existing unclaimed profile
		Then I should see "Email consultations" on the page
			And I should see "Phone consultations" on the page
			And I should see "Video consultations" on the page
			And I should see "Home visits" on the page
			And I should see "School visits" on the page

	Scenario: Specify remote consultation
		Given I am logged in as a profile editor
		When I visit the admin edit page for an unclaimed profile
			And I check "Offers most or all services remotely"
			And I save the profile
			And I visit the admin view page for the existing unclaimed profile
		Then I should see "Offers most or all services remotely" on the page

	Scenario: Specify accepting new clients
		Given I am logged in as a profile editor
		When I visit the admin edit page for an unclaimed profile
			And I check "Accepting new clients"
			And I save the profile
			And I visit the admin view page for the existing unclaimed profile
		Then I should see "Accepting new clients" on the page

	@private_site
	Scenario: Specify public profile on a private site
		Given I am logged in as a profile editor
		When I visit the admin edit page for an unclaimed profile
			And I check "Public on private site"
			And I save the profile
			And I visit the admin view page for the existing unclaimed profile
		Then I should see "Profile is public on private site" on the page

	@javascript
	Scenario: Save widget code
		Given I am logged in as a profile editor
		When I visit the admin edit page for an unclaimed profile
			And I enter "<div>some widget code</div>" in the "Widget code" field
			And I save the profile
		Then I should see "some widget code" on the page

	Scenario: Set category for a profile
		Given the "FAMILY SERVICES" and "HEALTH" categories are predefined
			And I am logged in as a profile editor
		When I visit the admin edit page for an unclaimed profile
			And I select the "FAMILY SERVICES" category
			And I visit the admin view page for the existing unclaimed profile
		Then I should see "FAMILY SERVICES" on the page

	Scenario: Set subcategory for a profile
		Given the "CHILD CARE" and "PREGNANCY & BIRTH" subcategories are predefined
			And I am logged in as a profile editor
		When I visit the admin edit page for an unclaimed profile
			And I select the "CHILD CARE" subcategory
			And I visit the admin view page for the existing unclaimed profile
		Then I should see "CHILD CARE" on the page

	Scenario: Set service for a profile
		Given the "Nannies" and "Birth Doulas" services are predefined
			And I am logged in as a profile editor
		When I visit the admin edit page for an unclaimed profile
			And I select the "Nannies" service
			And I visit the admin view page for the existing unclaimed profile
		Then I should see "Nannies" on the page
