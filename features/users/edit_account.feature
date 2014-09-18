@javascript
Feature: Edit account
	In order to maintain my account
	As a provider or client
	I want to change my account settings

	Scenario: Change password
		Given I exist as a user
			And I am logged in
			And I am on my account edit page
		When I enter a new password
			And I save the account settings
		Then I should see an account edited message

	Scenario: Change email address
		Given I exist as a user
			And I am logged in
			And I am on my account edit page
		When I enter a new email address of "gyorgy@ligeti.com"
			And I save the account settings
			And "gyorgy@ligeti.com" opens the email
		 	And I follow "confirm" in the email
		Then I see a confirmed account message

	Scenario: Change username as a provider
		Given I am logged in as a provider
			And I am on my account edit page
		When I enter a new username
			And I save the account settings
		Then I should see an account edited message

	Scenario: Change username as a client
		Given I am logged in as a client user
			And I am on my account edit page
		When I enter a new username
			And I save the account settings
		Then I should see an account edited message

	Scenario: Changing email address should NOT produce a welcome email
		Given I exist as a user
			And I am logged in
			And I am on my account edit page
		When I enter a new email address of "gyorgy@ligeti.com"
			And I save the account settings
			And "gyorgy@ligeti.com" opens the email
		 	And I follow "confirm" in the email
		Then I should receive no welcome email

	Scenario: Change news settings as a client
		Given I am logged in as a client user
			And I am on my account edit page
		When I check "parent_marketing_emails"
			And I check "parent_newsletters"
			And I enter my current password
			And I save the account settings
		Then I should see an account edited message

	Scenario: Change news settings as a provider
		Given I am logged in as a provider
			And I am on my account edit page
		When I check "provider_marketing_emails"
			And I check "provider_newsletters"
			And I enter my current password
			And I save the account settings
		Then I should see an account edited message

	@javascript
	Scenario: Provider can see html code for buttons for his personal website
		Given I am logged in as a provider
			And I am on my account edit page
		When I click on the "Add a button" link
		Then I should see "views.user.edit.add_button_header" text on the page

	Scenario: Non-provider cannot see html code for buttons for his personal website
		Given I am logged in as a client user
			And I am on my account edit page
		Then I should not see "Add a button" on the page
