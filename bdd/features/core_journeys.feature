Feature: Principal CodeAgents Mobile journeys
  The app should let users authenticate, provision servers, manage plans, and work safely on projects.

  Background:
    Given a fresh app context

  Scenario: GitHub login leads to Claude chat
    Given the user selects "GitHub" login with scopes "repo,read:user"
    And OAuth succeeds and identity is stored
    When the user opens chat and sends "List my repos"
    Then a Claude response is rendered
    And the session is marked authenticated with provider "GitHub"

  Scenario: Discord token refresh restores the session
    Given the user selects "Discord" login with scopes "identify,email"
    And OAuth succeeds and identity is stored
    When the Discord access token expires
    And the app refreshes the token using PKCE
    Then the session is marked authenticated with provider "Discord"

  Scenario: Provision DigitalOcean server for Claude Code
    Given DigitalOcean API token is configured
    When the user provisions a new "s-1vcpu-1gb" droplet in region "nyc3"
    Then the droplet is marked ready with Claude CLI installed

  Scenario: Manage subscription through RevenueCat
    Given RevenueCat offering "pro" priced "$9.99" is available
    When the user purchases the "pro" plan
    Then the entitlement "pro" becomes active
    And billing status is "active"

  Scenario: File browser protects project root
    Given an authenticated project workspace "demo" exists on the server
    When the user creates file "README.md" with contents "hello"
    And the user attempts to delete the project root
    Then the delete is rejected
    And the file remains accessible with content "hello"
