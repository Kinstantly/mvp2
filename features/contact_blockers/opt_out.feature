Feature: Opt out of contact from us
	In order to be no longer contacted by Kinstantly
	As an email recipient
	I want to be placed on an opt-out list

	Scenario: Submitting a prefilled opt-out form adds me to the opt-out list
		Given I click an optout link with the email address "willie@example.org"
			And I click submit on the optout page
		Then "willie@example.org" should be blocked from receiving further email

	Scenario: Submitting a prefilled opt-out form with a second email adds both addresses to the opt-out list
		Given I click an optout link with the email address "willie@example.org"
			And I enter "nelson@example.org" in the "Email address" field
			And I click submit on the optout page
		Then "willie@example.org" should be blocked from receiving further email
			And "nelson@example.org" should be blocked from receiving further email

	Scenario: Entering my email address in the opt-out form adds me to the opt-out list
		Given I visit the optout page
			And I enter "willie@example.org" in the "Email address" field
			And I click submit on the optout page
		Then "willie@example.org" should be blocked from receiving further email
