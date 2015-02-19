@payments
Feature: About payments
	In order to purchase a provider's services
	As a parent
	I want to know how payments work

	Scenario: Payment information page when not logged in
		Given a profile for a payable provider
			And I am not logged in
		When I visit the payable provider's payment information page
		Then I should see "Kinstantly gives you a better way to pay your favorite providers" on the page
			And I click on "Just click here"
		Then I should see "Please sign up below" on the page

	Scenario: Payment information page when logged in
		Given a profile for a payable provider
			And I am logged in as a parent
		When I visit the payable provider's payment information page
		Then I should see "Kinstantly gives you a better way to pay your favorite providers" on the page
			And I click on "Just click here"
		Then I should see "I authorize" on the page
			And I should see "to charge my credit card" on the page

	Scenario: Payment information page for current customer
		Given I am a client of a payable provider
			And I am logged in
		When I visit the payable provider's payment information page
			And I click on "Just click here"
		Then I should see "Change your authorized amount" on the page
