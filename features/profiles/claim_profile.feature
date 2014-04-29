@javascript
Feature: Claim profile
	In order to manage the profile created on my behalf
	As a provider
	I want to claim the profile
	
	Scenario: I preview the invitation to claim a profile
		Given I am logged in as an administrator
		When I visit the view page for an unclaimed profile
			And I preview the invitation to "asleep@thewheel.wv.us" to claim the profile
		Then the administrator should receive an email
	
	Scenario: Invite provider to claim their profile
		Given I am logged in as an administrator
		When I visit the view page for an unclaimed profile
			And I invite "asleep@thewheel.wv.us" to claim the profile
		Then "asleep@thewheel.wv.us" should have an email
	
	Scenario: Unregistered provider must register to claim profile
	  Given I am not logged in
			And I have been invited to claim a profile
	  When I click on the profile claim link
	  Then I should be on the provider registration page
	
	Scenario: Newly registered provider claims profile without confirmation
	  Given I am not logged in
			And I have been invited to claim a profile
	  When I click on the profile claim link
	  Then I should be on the provider registration page
		When I sign up with valid user data
		Then I should receive a welcome email
			And the profile should be attached to my account
	
	Scenario: Replace my existing profile with confirmation when claiming
		Given I exist as a user
			And I want a profile
			And I am logged in
			And I have been invited to claim a profile
		When I click on the profile claim link
		Then I should be asked to replace my existing profile
		When I click on the profile claim confirm link
		Then the profile should be attached to my account
