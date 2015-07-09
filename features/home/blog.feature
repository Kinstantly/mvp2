Feature: Blog
	As a client or expert
	I want easy ways to get to the blog site. 

	Background:
	Given I am not logged in
	When I visit the "/blog" page

	Scenario: redirect to blog site
		Then I should be redirected to the "blog.kinstantly.com" site
