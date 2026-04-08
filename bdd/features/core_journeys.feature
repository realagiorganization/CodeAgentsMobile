Feature: Principal CodeAgents Mobile journeys
  The app should let users authenticate, provision servers, manage plans, and work safely on projects.

  Background:
    Given a fresh app context

  Scenario Outline: Provider login leads to Claude chat
    Given the user selects "<provider>" login with scopes "<scopes>"
    And OAuth succeeds and identity is stored
    When the user opens chat and sends "<prompt>"
    Then a Claude response is rendered
    And the session is marked authenticated with provider "<provider>"

    Examples:
      | provider | scopes         | prompt                   |
      | GitHub   | repo,read:user | List my repos            |
      | Discord  | identify,email | Summarize my guild roles |

  Scenario: Discord token refresh restores the session
    Given the user selects "Discord" login with scopes "identify,email"
    And OAuth succeeds and identity is stored
    When the Discord access token expires
    And the app refreshes the token using PKCE
    Then the session is marked authenticated with provider "Discord"

  Scenario Outline: Provision managed server for Claude Code
    Given <provider> API token is configured
    When the user provisions a new "<size>" server in region "<region>" for "<provider>"
    Then the server is marked ready with Claude CLI installed
    And the server provider is "<provider>"

    Examples:
      | provider     | size        | region |
      | DigitalOcean | s-1vcpu-1gb | nyc3   |
      | Hetzner      | cpx11       | hel1   |

  Scenario: Manage subscription through RevenueCat
    Given RevenueCat offering "pro" priced "$9.99" is available
    When the user purchases the "pro" plan
    Then the entitlement "pro" becomes active
    And billing status is "active"

  Scenario: Restore an existing RevenueCat plan
    Given RevenueCat offering "pro" priced "$9.99" is available
    And the subscription "pro" has previous purchase history
    When the user restores purchases
    Then the entitlement "pro" becomes active
    And billing status is "restored"

  Scenario: Settings preserve both credential types
    Given the user stores API key credential "sk-live-demo"
    And the user stores auth token credential "claude-token-demo"
    When the user switches the active auth method to "apiKey"
    And the user switches the active auth method to "token"
    Then the active auth method is "token"
    And the stored API key credential remains available
    And the stored auth token credential remains available

  Scenario: File browser protects project root
    Given an authenticated project workspace "demo" exists on the server
    When the user creates file "README.md" with contents "hello"
    And the user attempts to delete the project root
    Then the delete is rejected
    And the file remains accessible with content "hello"
