Feature: Blog Posts Management
  As a blog administrator
  I want to manage posts
  So that I can publish content for readers

  Background:
    Given I am on the posts page

  Scenario: Creating a new published post
    When I click link "New post"
    And I fill in "Title" with "Cucumber Test Post"
    And I fill in "Content" with "This post was created using Cucumber"
    And I check "Published"
    And I click button "Create Post"
    Then I should see "Post was successfully created"

  Scenario: Viewing only published posts
    Given there is a published post titled "Published Post"
    And there is a draft post titled "Draft Post"
    When I visit the posts page
    Then I should see "Published Post"
    But I should not see "Draft Post"
