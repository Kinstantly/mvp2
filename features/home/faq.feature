Feature: FAQ
	In order to get help from experts
	As a client
	I want answers to my process questions

	Scenario: show FAQs
		Given I am not logged in
		When I visit the "faq" page
		Then I should see a list of frequently asked questions and answers
