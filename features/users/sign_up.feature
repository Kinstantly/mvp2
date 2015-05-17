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

		Scenario: Newly registered user is an expert
			When I sign up with valid user data
			Then I should be an expert

		Scenario: Newly registered non-expert is a client
			When I sign up as a non-expert with valid user data
			Then I should be a client

		Scenario: Username is optional for parents
			When I sign up as a non-expert without a username
			Then I see an unconfirmed account message

		Scenario: Username is optional for providers
			When I sign up without a username
			Then I see an unconfirmed account message
	
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
				And I visit the account page for "asleep@thewheel.wv.us"
				And I click on "Send confirmation instructions"
			Then "asleep@thewheel.wv.us" should receive an email with subject "Confirm your Kinstantly account"
		
		Scenario: Newly registered user must confirm
			When I sign up with valid user data
				And I open the email with subject "Confirm your Kinstantly account"
			 	And I follow "confirm" in the email
			Then I see a confirmed account message

		Scenario: Newly registered user receives another confirmation email when re-sent by admin
			Given I sign up with email "asleep@thewheel.wv.us"
			When I am logged in as an administrator
				And I visit the account page for "asleep@thewheel.wv.us"
				And I click on "Send confirmation instructions"
			Then "asleep@thewheel.wv.us" should receive 2 emails with subject "Confirm your Kinstantly account"

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

		Scenario: Admin receives notification when a parent registers
			When I sign up as a parent with valid user data
				And "admin@kinstantly.com" opens the email with subject /Parent.*has registered/
			Then they should see /parent.*registered/ in the email body

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

		@in_blog_signup
		Scenario: User visits in-blog sign-up page while logged-in
			Given I exist as a user
				And I am logged in
			When I am on the in-blog signup page
			Then I should not see html element "header#header"
			Then I should see "views.user.view.subscription_preferences_link" translated link to contact_preferences section of my account settings page

		@in_blog_signup
		Scenario: User visits in-blog sign-up page while NOT logged-in
			When I am on the in-blog signup page
			Then I should not see html element "header#header"
			Then I should see "Click here" link to contact_preferences section of my account settings page

		@in_blog_signup
		Scenario: User signs up via iframe on the blog site with valid data
			When I sign up on the blog site with valid data
			Then I should not see html element "header#header"
			Then I should see "welcome to Kinstantly!" on the page

		@in_blog_signup
		Scenario: User signs up via iframe on the blog site with invalid data
			When I sign up on the blog site with invalid data
			Then I should not see html element "header#header"
			Then I should see "Click here" link to contact_preferences section of my account settings page
