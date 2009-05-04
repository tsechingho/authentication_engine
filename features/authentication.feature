Feature: Authentication
  As a confirmed but anonymous user
  I want to login to the application
  So that I can be productive

  Scenario: Display login form to anonymous users
    Given "sharon" is an anonymous user
    When I go to the login page
    Then I should see a login form

  Scenario: Redirect to account page when user is logged in
    Given "sharon" a logged in user
    When I go to the login page
    Then I should be logged in
    When I follow "Logout"
    Then I should be logged out

  Scenario: Not allow login of an unconfirmed user
    Given "sharon" a notified but unconfirmed user
    When I go to the login page
    And I fill in "login" with "sharon"
    And I fill in "password" with "secret"
    And I press "Login"
    Then I should not be logged in
    And I should see "Login does not exist"

  Scenario: Allow login of a user with valid credentials
    Given "sharon" a confirmed user with password "secret"
    When I go to the login page
    And I fill in "login" with "sharon"
    And I fill in "password" with "secret"
    And I press "Login"
    Then I should be logged in
    When I follow "Logout"
    Then I should be logged out

  Scenario Outline: Not allow login of a user with bad credentials
    Given "sharon" a confirmed user with password "secret"
    When I go to the login page
    And I fill in "login" with "<login>"
    And I fill in "password" with "<password>"
    And I press "Login"
    Then I should not be logged in
    And I should have <count> errors
    And I should see "<error_message>"

    Examples:
      | login   | password   | count | error_message                                      |
      |         |            | 1     | You did not provide any details for authentication |
      |         |  secret    | 1     | Login can not be blank                             |
      |         | bad secret | 1     | Login can not be blank                             |
      | unknown |            | 1     | Password can not be blank                          |
      | unknown |  secret    | 1     | Login does not exist                               |
      | unknown | bad secret | 1     | Login does not exist                               |
      | sharon  |            | 1     | Password can not be blank                          |
      | sharon  | bad secret | 1     | Password is not valid                              |

  Scenario: Allow a confirmed user to login and be remembered
    Given "sharon" a confirmed user with password "secret"
    When I go to the login page
    And I fill in "login" with "sharon"
    And I fill in "password" with "secret"
    And I check "Remember me"
    And I press "Login"
    Then I should be logged in
    When I open the homepage in a new window
    Then I should be logged in
    When I follow "Logout"
    Then I should be logged out

