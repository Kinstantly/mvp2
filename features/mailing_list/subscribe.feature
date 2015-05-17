Feature: Subscribe to newsletters and/or marketing emails
	In order to get useful and interesting parenting information
	As a user
	I want to be able to subscribe to newsletters

	Background:
		Given I am not logged in

	Scenario: Provider should be fully subscribed before confirmation
		When I sign up as a provider on the regular site and subscribe to the "provider_newsletters and parent_newsletters_stage2" mailing lists
			And I see an unconfirmed account message
		Then I should only be subscribed to the "provider_newsletters and parent_newsletters_stage2" mailing lists and synced to the list server

	Scenario: Provider should be fully subscribed after confirmation
		When I sign up as a provider on the regular site and subscribe to the "parent_newsletters_stage1 and parent_newsletters_stage2" mailing lists
			And I open the email with subject "Confirm your Kinstantly account"
		 	And I follow "confirm" in the email
		Then I should only be subscribed to the "parent_newsletters_stage1 and parent_newsletters_stage2" mailing lists and synced to the list server

	Scenario: Parent should be fully subscribed before confirmation
		When I sign up as a parent on the regular site and subscribe to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists
			And I see an unconfirmed account message
		Then I should only be subscribed to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists and synced to the list server

	Scenario: Parent should be fully subscribed after confirmation
		When I sign up as a parent on the regular site and subscribe to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists
			And I open the email with subject "Confirm your Kinstantly account"
		 	And I follow "confirm" in the email
		Then I should only be subscribed to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists and synced to the list server

	Scenario: Provider should be fully subscribed after registering while claiming their profile
		When I have been invited to claim a profile
			And I click on the profile claim link
			And I sign up as a provider on the regular site and subscribe to the "provider_newsletters, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists
		Then the profile should be attached to my account
			And I should only be subscribed to the "provider_newsletters, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists and synced to the list server

	Scenario: User subscribes on the newsletter sign-up page and is fully subscribed before confirmation
		When I visit the newsletter sign-up page and subscribe to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists
			And I see an unconfirmed account message
		Then I should only be subscribed to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists and synced to the list server

	Scenario: User subscribes on the newsletter sign-up page and is fully subscribed after confirmation
		When I visit the newsletter sign-up page and subscribe to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists
			And I open the email with subject "Confirm your Kinstantly account"
		 	And I follow "confirm" in the email
		Then I should only be subscribed to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists and synced to the list server

	Scenario: User subscribes from blog and is fully subscribed before confirmation
		When I sign up as a parent on the blog site and subscribe to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists
			And I see an unconfirmed account message
		Then I should only be subscribed to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists and synced to the list server

	Scenario: User subscribes from blog and is fully subscribed after confirmation
		When I sign up as a parent on the blog site and subscribe to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists
			And I open the email with subject "Confirm your Kinstantly account"
		 	And I follow "confirm" in the email
		Then I should only be subscribed to the "parent_newsletters_stage1, parent_newsletters_stage2, and parent_newsletters_stage3" mailing lists and synced to the list server
