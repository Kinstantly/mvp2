Feature: Sign up
	In order to get access to protected sections of the site
	As a user
	I want to be able to sign up

		Background:
			Given I am not logged in

		Scenario: User signs up with valid data
			When I sign up with valid user data
			Then I see an unconfirmed account message
			
		Scenario: User signs up with invalid email
			When I sign up with an invalid email
			Then I should see an invalid email message

		Scenario: User signs up without password
			When I sign up without a password
			Then I should see a missing password message

		Scenario: User signs up without password confirmation
			When I sign up without a password confirmation
			Then I should see a missing password confirmation message

		Scenario: User signs up with mismatched password and confirmation
			When I sign up with a mismatched password confirmation
			Then I should see a mismatched password message

		Scenario: Newly registered user is an expert
			When I sign up with valid user data
			Then I should be an expert

		Scenario: Newly registered non-expert is a client
			When I sign up as a non-expert with valid user data
			Then I should be a client

		Scenario: Newly registered non-expert is a client
			When I sign up as a non-expert without a username
			Then I should see a missing username message
	
		Scenario: Newly registered user receives confirmation email
			When I sign up with email "asleep@thewheel.wv.us"
			Then "asleep@thewheel.wv.us" should receive an email with subject "Confirm your Kinstantly account"
	
		@private_site
		Scenario: Newly registered user receives no confirmation email when running as private site
			When I sign up with email "asleep@thewheel.wv.us"
			Then "asleep@thewheel.wv.us" should receive no email with subject "Confirm your Kinstantly account"
	
		@private_site
		Scenario: Newly registered user receives confirmation email after admin approves when running as private site
			Given I sign up with email "asleep@thewheel.wv.us"
			When I am logged in as an administrator
				And I visit the edit account page for "asleep@thewheel.wv.us"
				And I click on "Send confirmation instructions"
			Then "asleep@thewheel.wv.us" should receive an email with subject "Confirm your Kinstantly account"
		
		Scenario: Newly registered user must confirm
			When I sign up with valid user data
				And I open the email with subject "Confirm your Kinstantly account"
			 	And I follow "confirm" in the email
			Then I see a confirmed account message

		Scenario: Newly registered and confirmed expert receives a welcome email
			When I sign up with valid user data
				And I open the email with subject "Confirm your Kinstantly account"
			 	And I follow "confirm" in the email
			Then I should receive a welcome email

		Scenario: Newly registered and confirmed non-expert should NOT receive a welcome email
			When I sign up as a non-expert with valid user data
			And I open the email with subject "Confirm your Kinstantly account"
			 	And I follow "confirm" in the email
			Then I should receive no welcome email

		Scenario: Admin receives notification when an expert registers
			When I sign up with valid user data
				And "admin@kinstantly.com" opens the email with subject /Provider.*has registered/
			Then they should see /provider.*registered/ in the email body

		@private_site
		Scenario: Admin receives notification when a parent registers when running as a private site
			When I sign up as a parent with valid user data
				And "admin@kinstantly.com" opens the email with subject /Parent.*has registered/
			Then they should see /parent.*registered/ in the email body

		Scenario: Admin receives notification when an expert registers with a special code
			When I sign up with a special code of "IamsoSpecial"
				And "admin@kinstantly.com" opens the email with subject /Provider.*has registered/
			Then they should see "IamsoSpecial" in the email body

		@private_site
		Scenario: Admin receives notification when a parent registers with a special code when running as a private site
			When I sign up as a parent with a special code of "IamaSpecialParent"
				And "admin@kinstantly.com" opens the email with subject /Parent.*has registered/
			Then they should see "IamaSpecialParent" in the email body
