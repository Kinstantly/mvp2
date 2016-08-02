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
	
	Scenario: Track the invitation to claim a profile
		Given I am logged in as an administrator
		When I visit the view page for an unclaimed profile
			And I invite "asleep@thewheel.wv.us" to claim the profile
			And I visit the admin view page for the existing unclaimed profile
		Then I should see an invitation to "asleep@thewheel.wv.us" to claim their profile
	
	Scenario: Do not deliver an invitation to someone who opted out of email from us
		Given "asleep@thewheel.wv.us" opted out of receiving email from us
			And I am logged in as an administrator
		When I visit the view page for an unclaimed profile
			And I invite "asleep@thewheel.wv.us" to claim the profile
		Then I should see "'asleep@thewheel.wv.us' has opted out" on the page
	
	Scenario: Cannot invite to claim a profile whose provider has opted out of email from us
		Given I am logged in as an administrator
			And there is an unclaimed profile for which the recipient of a previous invitation opted out of email from us
		When I visit the view page for the existing unclaimed profile
		Then I should see no invitation link
	
	Scenario: Invited provider clicks the unsubscribe link
		Given I am not logged in
			And I have been invited to claim a profile
		When I click on the unsubscribe link in the unclaimed profile invitation
		Then I should be on the unsubscribe page for the unclaimed profile invitation
	
	Scenario: Invited provider unsubscribes
		Given I am not logged in
			And I have been invited to claim a profile
		When I click on the unsubscribe link in the unclaimed profile invitation
			And I click submit on the unsubscribe page
		Then I should be on the unsubscribe confirmation page
	
	Scenario: Invited provider is sent to a blank opt-out form after clicking a corrupted unsubscribe link
		Given I am not logged in
			And I have been invited to claim a profile
		When I click on a bad unsubscribe link in the unclaimed profile invitation
		Then I should be on the opt-out page
	
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
