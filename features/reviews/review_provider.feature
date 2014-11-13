@javascript
Feature: Review provider
	In order to help parents choose a good provider
	As a parent
	I want to review a provider

	Scenario: I have the option to review a provider
		Given a published profile exists
			And I am not logged in
		When I visit the published profile page
		Then the profile should show "Add your review"

	Scenario: Create a review
		Given a published profile exists
			And I am logged in as a client user
		When I visit the published profile page
			And I click on the review link
			And I enter "Hank Williams is the best!" in the new review on the review page
			And I enter "Do not be fooled by Jr." as the good-to-know in the new review on the review page
			And I click "Submit" in the new review on the review page
		Then I should land on the view page for the published profile
			And the profile should show "Hank Williams is the best!"

	Scenario: Review provider when not signed in
		Given a published profile exists
			And I am not logged in
		When I visit the published profile page
			And I click on the review link
		Then I should land on the member sign-up page

	Scenario: Sign up during provider review process
		Given a published profile exists
			And I am not logged in
		When I visit the published profile page
			And I click on the review link
			And I sign up as a non-expert with valid user data
			And I open the email with subject "Confirm your Kinstantly account"
			And I follow "confirm" in the email
		Then I should land on the review form of the profile

	Scenario: Admin notified when a provider is reviewed
		Given a published profile exists with company name "Car Wheels on a Gravel Road"
			And I am logged in as a client user
		When I visit the published profile page
			And I click on the review link
			And I enter "Lucinda Williams is the best!" in the new review on the review page
			And I click "Submit" in the new review on the review page
		Then "admin@kinstantly.com" should receive an email with subject "New Review for Car Wheels on a Gravel Road"
			And they open the email
			And they should see "Lucinda Williams is the best!" in the email body
