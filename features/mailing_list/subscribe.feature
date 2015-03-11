Feature: Subscribe to newsletters and/or marketing emails
	In order to get useful and interesting parenting information
	As a user
	I want to be able to subscribe to newsletters

	Background:
		Given I am not logged in

	Scenario: Provider should not be fully subscribed before confirmation
		When I sign up as a provider on the regular site and subscribe to "provider_newsletters, parent_newsletters_stage2" mailing lists
			And I see an unconfirmed account message
		Then I should only be subscribed to "provider_newsletters, parent_newsletters_stage2" mailing lists but not synced to the list server

	Scenario: Provider should be fully subscribed after confirmation
		When I sign up as a provider on the regular site and subscribe to "parent_newsletters_stage1, parent_newsletters_stage2" mailing lists
			And I open the email with subject "Confirm your Kinstantly account"
		 	And I follow "confirm" in the email
		Then I should only be subscribed to "parent_newsletters_stage1, parent_newsletters_stage2" mailing lists and synced to the list server

	Scenario: Parent should not be fully subscribed before confirmation
		When I sign up as a parent on the regular site and subscribe to "parent_newsletters_stage1, parent_newsletters_stage2, parent_newsletters_stage3" mailing lists
			And I see an unconfirmed account message
		Then I should only be subscribed to "parent_newsletters_stage1, parent_newsletters_stage2, parent_newsletters_stage3" mailing lists but not synced to the list server

	Scenario: Parent should be fully subscribed after confirmation
		When I sign up as a parent on the regular site and subscribe to "parent_newsletters_stage1, parent_newsletters_stage2, parent_newsletters_stage3" mailing lists
			And I open the email with subject "Confirm your Kinstantly account"
		 	And I follow "confirm" in the email
		Then I should only be subscribed to "parent_newsletters_stage1, parent_newsletters_stage2, parent_newsletters_stage3" mailing lists and synced to the list server

	Scenario: Provider should be fully subscribed after registering while claiming their profile
		When I have been invited to claim a profile
			And I click on the profile claim link
			And I sign up as a parent on the regular site and subscribe to "provider_newsletters, parent_newsletters_stage2, parent_newsletters_stage3" mailing lists
		Then the profile should be attached to my account
			And I should only be subscribed to "provider_newsletters, parent_newsletters_stage2, parent_newsletters_stage3" mailing lists and synced to the list server

	Scenario: User subscribes from blog
		When I sign up as a parent on the blog site and subscribe to "parent_newsletters_stage1, parent_newsletters_stage2, parent_newsletters_stage3" mailing lists
			And I open the email with subject "Confirm your Kinstantly newsletter subscription"
		 	And I follow "confirm" in the email
		Then I should only be subscribed to "parent_newsletters_stage1, parent_newsletters_stage2, parent_newsletters_stage3" mailing lists and synced to the list server
