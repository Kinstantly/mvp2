@javascript
Feature: Profile claim
	In order to manage the profile created on my behalf
	As a provider
	I want to acquire access to my profile 

	Scenario: Bring up profile claim form
		Given I visit a published unclaimed profile
		When I click on the "claim_profile_link" link
		Then I should see "Thanks for claiming your profile!" on the page

	Scenario: Submit profile claim form
		Given I visit a published unclaimed profile
			And I click on the "claim_profile_link" link
		When I enter "myclaim@example.com" in the "profile_claim_claimant_email" field
			And I enter "800-000-8888" in the "profile_claim_claimant_phone" field
			And I click on the "Submit" button
		Then I should see "The claim has been submitted" on the page

	Scenario: Neglect to enter required fields on the profile claim form
		Given I visit a published unclaimed profile
			And I click on the "claim_profile_link" link
		When I enter "800-000-8888" in the "profile_claim_claimant_phone" field
			And I click on the "Submit" button
		Then I should see "Email address is required" on the page

	Scenario: Bring up profile claim form while logged in
		Given I am logged in as a parent
			And I visit a published unclaimed profile
		When I click on the "claim_profile_link" link
		Then I should see "Thanks for claiming your profile!" on the page

	Scenario: Submit profile claim form while logged in
		Given I am logged in as a parent
			And I visit a published unclaimed profile
			And I click on the "claim_profile_link" link
			And I enter "myclaim@example.com" in the "profile_claim_claimant_email" field
			And I enter "800-000-8888" in the "profile_claim_claimant_phone" field
			And I click on the "Submit" button
		Then I should see "The claim has been submitted" on the page
