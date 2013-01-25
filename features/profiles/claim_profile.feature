Feature: Claim profile
	In order to manage the profile created on my behalf
	As a provider
	I want to claim the profile

	Scenario: Attach profile to my existing account
		Given I am logged in
			And I have no profile
			And I have been invited to claim a profile
		When click on the profile claim link
		Then the profile should be attached to my account
	
	Scenario: Invite provider to claim their profile
		Given I am logged in as an administrator
		When I visit the view page for an unclaimed profile
			And I invite "asleep@thewheel.wv.us" to claim the profile
		Then "asleep@thewheel.wv.us" should have an email
	
