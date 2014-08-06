@javascript
Feature: Notify profile moderator
	As a site administrator
	I want to be notified when a new profile claim has been submitted

	Scenario: Profile moderator receives an email notification
		Given I visit a published unclaimed profile
			And I click on the "claim_profile_link" link
		When I enter "etahoffmann@example.org" in the "profile_claim_claimant_email" field
			And I enter "800-000-8888" in the "profile_claim_claimant_phone" field
			And I click on the "Submit" button
			And I wait a bit
		Then I should see "The claim has been submitted" on the page
			And "profile_monitor@kinstantly.com" should receive an email with subject "New profile claim has been submitted."
