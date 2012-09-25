Feature: View my expert profile
  As a registered expert
  I want to view my profile
  so I can know how it looks to potential clients

    Scenario: Viewing profile
      Given I exist as a registered user
      When I view my profile
      Then I should see my email
