@javascript
Feature: Allow a provider address that is anywhere in the world
	So that international providers can create a profile on Kinstantly
	As a registered provider
	I want to enter an address for any country in the world
	
	Scenario: Select Canada in the locations formlet
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "locations" formlet
			And I select "Canada" as the "Country" in the "locations" formlet
		Then I should see "Province" in the "locations" formlet
			And I should see "Postal Code" in the "locations" formlet
	
	Scenario: Add address in Canada
		Given I exist as a user
			And I am logged in
			And I am on my profile edit page
		When I open the "locations" formlet
			And I enter "8623 Granville Street" in the "Street address" field of the "locations" formlet
			And I enter "Vancouver" in the "City" field of the "locations" formlet
			And I select "Canada" as the "Country" in the "locations" formlet
			And I select "British Columbia" as the "Province" in the "locations" formlet
			And I enter "V6P 5A2" in the "Postal Code" field of the "locations" formlet
			And I click on the "Save" button of the "locations" formlet
		Then my profile edit page should show "8623 Granville Street" displayed in the "locations" area
			And my profile edit page should show "Vancouver" displayed in the "locations" area
			And my profile edit page should show "BC" displayed in the "locations" area
			And my profile edit page should show "V6P 5A2" displayed in the "locations" area
			And my profile edit page should show "Canada" displayed in the "locations" area
