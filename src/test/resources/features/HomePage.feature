@tess-website
  Business Need: Create Basic UI test cases to ensure tess website is working properly
    Feature: Tess Website HomePage Tests

    @SmokeTest
    Scenario Outline: Validate Tess Website tile sends user to correct confluence page
      Given I click on "<tile>" tile from tess website home page
      Then I validate the tile nagivates me to the correct confluence "<onConfluence>" page url "<url>"

      Examples:
        | tile | onConfluence | url |
        | Services   | true | https://confluence.capgroup.com/pages/viewpage.action?spaceKey=TAUTO&title=Getting+started+with+Test+Automation|
        | CICD   |  true   | https://confluence.capgroup.com/pages/viewpage.action?pageId=344778875|
        | qTest   |   true | https://confluence.capgroup.com/pages/viewpage.action?spaceKey=TAUTO&title=qTest+Test+Automation+integration+via+Pulse|
        | Frameworks   | false | /reference|
        | Implementations   |false | /reference|
        | BestPractices   | true | https://confluence.capgroup.com/pages/viewpage.action?spaceKey=TAUTO&title=Test+Automation+Best+Practices|

