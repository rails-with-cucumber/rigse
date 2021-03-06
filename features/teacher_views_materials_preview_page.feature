Feature: Teacher can search and assign instructional materials to a class

  As a teacher
  I should be able to preview and assign materials to a class
  In order to provide study materials to the students from the class
  
  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher
    
    
  @javascript
  Scenario: Teacher should be able to preview materials activity as teacher and as a student
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I click link "Preview" for investigation "Mechanics" on the materials preview page
    Then I should see "As Teacher"
    Then I should see "As Student"
    And I click link "Preview" for activity "Fluid Mechanics" on the materials preview page
    Then I should see "As Teacher"
    Then I should see "As Student"
    
    
  @javascript
  Scenario: Anonymous user should see message for teacher only activity
    When I log out
    And I am on the the preview activity page for the activity "Aeroplane"
    Then I should see "Please log in as a teacher to see this content."
    
    
  Scenario: Anonymous user should be able to preview investigation
    When I log out
    And I am on the the preview investigation page for the investigation "Mechanics"
    And I click link "Preview" for investigation "Mechanics" on the materials preview page
    Then I receive a file for download with a filename like "_investigation_"
    
    
  Scenario: Anonymous user should be able to preview activity
    When I log out
    And I am on the the preview investigation page for the investigation "Mechanics"
    And I click link "Preview" for activity "Fluid Mechanics" on the materials preview page
    Then I receive a file for download with a filename like "_activity_"
    
    
  @javascript
  Scenario: Anonymous user can not assign instructional materials to the class
    When I log out
    And I am on the the preview investigation page for the investigation "Mechanics"
    And I follow "Assign Investigation"
    Then I should see "Please log-in" within the lightbox in focus
    And I should see "as a teacher to assign this material." within the lightbox in focus
    And I follow "register" within the lightbox in focus
    Then I should see "Please log-in or register as a teacher to assign this material."
    And I am on the the preview investigation page for the investigation "Mechanics"
    And I uncheck "Fluid Mechanics" from the investigation preview page
    And I follow "Assign Individual Activities"
    Then I should see "Please log-in" within the lightbox in focus
    And I should see "as a teacher to assign this material." within the lightbox in focus
    And I follow "register" within the lightbox in focus
    Then I should see "Please log-in or register as a teacher to assign this material."
    
    
  Scenario: Teacher should be able to see different properties of materials
    When the investigation "Digestive System 2" with activity "Bile Juice" belongs to domain "Biological Science" and has grade "10-11"
    And the investigation "A Weather Underground" with activity "A heat spontaneously" belongs to probe "Temperature"
    And I am on the the preview investigation page for the investigation "Digestive System 2"
    Then I should see "Biological Science"
    And I should see "10-11"
    And I am on the the preview investigation page for the investigation "A Weather Underground"
    And I should see "Temperature"
    
    
  @javascript
  Scenario: Teacher should be able to share investigation
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I should see "Mechanics is a great subject"
    And I click link "Share" for investigation "Mechanics" on the materials preview page
    Then I should be able to share investigation "Mechanics"
    
    
  @javascript
  Scenario: Teacher should be able to share activity
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I click link "Share" for activity "Fluid Mechanics" on the materials preview page
    Then I should be able to share activity "Fluid Mechanics"
    
    
  @javascript @search
  Scenario: Teacher should be able return on search page
    When I am on the search instructional materials page
    And I search for "Mechanics" on the search instructional materials page
    And I follow investigation link "Mechanics" on the search instructional materials page
    And the check box for the activity "Mechanics" should be checked
    And the check box for the activity "Fluid Mechanics" should be checked
    And I follow "return to search"
    Then I should be on the search instructional materials page
    And I follow activity link "Fluid Mechanics" on the search instructional materials page
    And the check box for the activity "Fluid Mechanics" should be checked
    And the check box for the activity "Mechanics" should not be checked
    And I follow "return to search"
    Then I should be on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can assign investigations to a class
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I follow "Assign Investigation"
    And I check "Mathematics"
    And I follow "Save"
    And I should see "Mechanics is assigned to the selected class(es) successfully." within the lightbox in focus
    And I go to Instructional Materials page for "Mathematics"
    Then I should see "Mechanics"
    
    
  @javascript
  Scenario: Teacher can assign activities to a class from the preview investigation page
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I uncheck "Mechanics" from the investigation preview page
    And I uncheck "Quantum Mechanics" from the investigation preview page
    And I uncheck "Circular Motion" from the investigation preview page
    And I follow "Assign Individual Activities"
    And "Mechanics" should appear before "Fluid Mechanics"
    When I check "Physics"
    And I follow "Save"
    And I should see "Fluid Mechanics is assigned to the selected class(es) successfully." within the lightbox in focus
    And I go to Instructional Materials page for "Physics"
    Then I should see "Fluid Mechanics"
    
    
  @javascript
  Scenario: Teacher should see message if assignment of activities is done without checking the activity
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I uncheck "Mechanics" from the investigation preview page
    And I uncheck "Fluid Mechanics" from the investigation preview page
    And I uncheck "Quantum Mechanics" from the investigation preview page
    And I uncheck "Circular Motion" from the investigation preview page
    And I follow "Assign Individual Activities"
    Then I should see "Please select at least one activity to assign to a class" within the lightbox in focus
    
    
  @javascript
  Scenario: Teacher should see message the class name in which activities are assigned
    When the Activity "Fluid Mechanics" is assigned to the class "Mathematics"
    And I am on the the preview investigation page for the investigation "Mechanics"
    And I uncheck "Mechanics" from the investigation preview page
    And I follow "Assign Individual Activities"
    And "Mechanics" should appear before "Fluid Mechanics"
    When I check "Physics"
    And I follow "Save"
    Then I should see "Assigned successfully" within the lightbox in focus
    And I should see "Physics" within the lightbox in focus
    And I should see "Fluid Mechanics, Circular Motion, Quantum Mechanics" within the lightbox in focus
    And I am on the the preview investigation page for the investigation "Mechanics"
    And I uncheck "Mechanics" from the investigation preview page
    And I follow "Assign Individual Activities"
    And I check "Mathematics"
    And I follow "Save"
    Then I should see "Please note that some of the activities were already assigned and were not re-assigned." within the lightbox in focus
    And I follow "More Information" within the lightbox in focus
    Then I should see "Mechanics"
    And I should see "Fluid Mechanics"
    
    
  @javascript
  Scenario: Teacher can see a message in the popup of assign activity if  activity is already as part of investigation
    When the Investigation "Mechanics" is assigned to the class "Physics"
    And I am on the the preview activity page for the activity "Fluid Mechanics"
    And I follow "Assign Individual Activities"
    Then I should see /(Already assigned as part of "Mechanics")/ within the lightbox in focus
    
    
  @javascript
  Scenario: Teacher can see a message in the popup if investigation is assigned to any class
    When the Investigation "Mechanics" is assigned to the class "Physics"
    And I am on the the preview investigation page for the investigation "Mechanics"
    And I follow "Assign Investigation"
    Then I should see "Already assigned to the following class(es)" within the lightbox in focus
    And I should see "Physics" within the lightbox in focus
    
    
  @javascript
  Scenario: Teacher can see a message in the popup if activity is assigned to any class
    When the Activity "Fluid Mechanics" is assigned to the class "Mathematics"
    And I am on the the preview activity page for the activity "Fluid Mechanics"
    And I follow "Assign Individual Activities"
    Then I should see "Already assigned to the following class(es)" within the lightbox in focus
    And I should see "Mathematics" within the lightbox in focus
    
    
 @javascript
  Scenario: Teacher should see a message if save button is clicked without selecting any class in assign popup
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I follow "Assign Investigation"
    And I follow "Save" within the lightbox in focus
    Then I should see "Select at least one class to assign this Investigation" within the lightbox in focus
    And I am on the the preview investigation page for the investigation "Mechanics"
    And I uncheck "Mechanics" from the investigation preview page
    And I follow "Assign Individual Activities"
    And I follow "Save" within the lightbox in focus
    Then I should see "Select at least one class to assign this Activity" within the lightbox in focus
    
    
  @javascript
  Scenario: Teacher can see a message in the popup if the investigation is assigned to all the classes
    When the following classes exist:
          | name        | teacher               |
          | New Class   | teacher_with_no_class |
    And I am logged in with the username teacher_with_no_class
    And I am on the the preview investigation page for the investigation "differential calculus"
    And I follow "Assign Investigation"
    And I check "clazz_id[]"
    And I follow "Save"
    And I should wait 2 seconds
    And I am on the the preview investigation page for the investigation "differential calculus"
    And I follow "Assign Investigation"
    Then I should see "This material is assigned to all the classes." within the lightbox in focus
    
    
  @javascript
  Scenario: Teacher can see a message in the popup if the activity is assigned to all the classes
    When the following classes exist:
          | name        | teacher               |
          | New Class   | teacher_with_no_class |
    And I am logged in with the username teacher_with_no_class
    And I am on the the preview activity page for the activity "Fluid Mechanics"
    And I follow "Assign Individual Activities"
    And I check "clazz_id[]"
    And I follow "Save"
    And I should wait 2 seconds
    And I am on the the preview activity page for the activity "Fluid Mechanics"
    And I follow "Assign Individual Activities"
    Then I should see "This material is assigned to all the classes." within the lightbox in focus
    
    
  @javascript
  Scenario: Teacher can see a message if assign to a class popup is opened without creating any class
    When the following classes exist:
          | name        | teacher               |
          | New Class   | teacher_with_no_class |
    And I am logged in with the username teacher_with_no_class
    And I go to the Manage Class Page
    And I uncheck "teacher_clazz[]"
    And I should wait 2 seconds
    And I am on the the preview investigation page for the investigation "Mechanics"
    And I follow "Assign Investigation"
    Then I should see "You don't have any active classes. Once you have created your class(es) you will be able to assign materials to them." within the lightbox in focus
    And I am on the the preview activity page for the activity "Fluid Mechanics"
    And I follow "Assign Individual Activities"
    Then I should see "You don't have any active classes. Once you have created your class(es) you will be able to assign materials to them." within the lightbox in focus
    
    
