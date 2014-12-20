@payments
Feature: List my customer files, i.e., show my list of clients
	In order to manage charges to my clients
	As a provider who does online charges
	I want to see my client list with relevant information for each client

	Scenario: List my clients and show their usernames
		Given I am logged in as a payable provider
			And I have a client with username "LinusVanPelt"
		When I visit the client list page
		Then I should see "LinusVanPelt" on the page

	Scenario: List my clients and show their email addresses
		Given I am logged in as a payable provider
			And I have a client with email "great_pumpkin@kinstantly.com"
		When I visit the client list page
		Then I should see "great_pumpkin@kinstantly.com" on the page

	Scenario: List my clients and show their authorized amounts
		Given I am logged in as a payable provider
			And I have a client with authorized amount "275.25"
		When I visit the client list page
		Then I should see "275.25" on the page

	Scenario: List my clients and show their charge buttons
		Given I am logged in as a payable provider
			And I have a client
		When I visit the client list page
		Then I should see a "charge or view" link button on the page
