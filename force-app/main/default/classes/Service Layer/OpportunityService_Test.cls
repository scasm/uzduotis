/**
 * @description  :
 * @author       : Justas Stonkus
 * @group        :
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2024-03-18   Justas Stonkus   Initial Version
 **/

@isTest
public with sharing class OpportunityService_Test {
  @TestSetup
  static void makeData() {
    insert new Account(
      FirstName = 'Test',
      LastName = 'Account',
      PersonEmail = 'test@account.com',
      Phone = '99998888'
    );
    insert new Referral__c(
      FirstName__c = 'Tim',
      LastName__c = 'Apple',
      Email__c = 'test@account.com',
      Phone__c = '77778888'
    );
  }

  @isTest
  static void testWhenOwnerValid() {
    Opportunity o = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today()
    );
    fflib_SObjectDomain.getTriggerEvent(Opportunities.class).disableAll();
    insert o;
    fflib_SObjectDomain.getTriggerEvent(Opportunities.class).enableAll();
    o = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id = :o.Id];

    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>{ o.Id => o };
    Set<Id> accountIds = new Set<Id>();

    Test.startTest();
    OpportunityService.handleOwnerAssignments(oppMap, accountIds);
    Test.stopTest();
    o = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id = :o.Id];
    Assert.areEqual(UserInfo.getUserId(), o.OwnerId);
  }

  @isTest
  static void testWhenOwnerInvalid() {
    User u = getUser('test');
    u.IsIntegrationUser__c = true;
    insert u;
    Opportunity o = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today(),
      OwnerId = u.Id
    );
    fflib_SObjectDomain.getTriggerEvent(Opportunities.class).disableAll();
    insert o;
    fflib_SObjectDomain.getTriggerEvent(Opportunities.class).enableAll();

    o = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id = :o.Id];

    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>{ o.Id => o };
    Set<Id> accountIds = new Set<Id>();
    Test.startTest();
    OpportunityService.handleOwnerAssignments(oppMap, accountIds);
    Test.stopTest();
    o = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id = :o.Id];
    Assert.areNotEqual(u.Id, o.OwnerId);

    UserSelector userSelector = (UserSelector) Application.Selector.newInstance(
      User.SObjectType
    );
    Assert.areEqual(userSelector.getAutomatedProcessUser().Id, o.OwnerId);
  }

  @isTest
  static void testWithAccountOpps() {
    User u = getUser('test');
    u.IsIntegrationUser__c = true;
    insert u;

    Account a = [SELECT Id FROM Account LIMIT 1];
    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      AccountId = a.Id,
      StageName = 'Prospecting',
      CloseDate = Date.today()
    );
    insert opp;

    Opportunity opp2 = new Opportunity(
      Name = 'Test Opportunity 2',
      AccountId = a.Id,
      StageName = 'Prospecting',
      CloseDate = Date.today(),
      OwnerId = u.Id
    );

    fflib_SObjectDomain.getTriggerEvent(Opportunities.class).disableAll();
    insert opp2;
    fflib_SObjectDomain.getTriggerEvent(Opportunities.class).enableAll();

    opp2 = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id = :opp2.Id];
    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>{ opp2.Id => opp2 };
    Set<Id> accountIds = new Set<Id>{ a.Id };
    Test.startTest();
    OpportunityService.handleOwnerAssignments(oppMap, accountIds);
    Test.stopTest();
    opp2 = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id = :opp2.Id];
    Assert.areNotEqual(u.Id, opp2.OwnerId);
    Assert.areEqual(UserInfo.getUserId(), opp2.OwnerId);
  }

  @isTest
  static void testWithReferrals() {
    User integrationUser = getUser('test');
    integrationUser.IsIntegrationUser__c = true;
    User standardUser = getUser('stand');
    insert new List<User>{ integrationUser, standardUser };

    insert new Referral__c(
      FirstName__c = 'Tom',
      LastName__c = 'Adams',
      Email__c = 'test@account.com',
      Phone__c = '11118888',
      ExpirationDate__c = System.today().addDays(1),
      Source__c = 'Internal',
      OwnerId = standardUser.Id
    );

    Account a = [SELECT Id FROM Account LIMIT 1];
    Opportunity o = new Opportunity(
      Name = 'Test Opportunity',
      AccountId = a.Id,
      StageName = 'Prospecting',
      CloseDate = Date.today(),
      OwnerId = integrationUser.Id
    );
    fflib_SObjectDomain.getTriggerEvent(Opportunities.class).disableAll();
    insert o;
    fflib_SObjectDomain.getTriggerEvent(Opportunities.class).enableAll();

    o = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id = :o.Id];

    Test.startTest();
    OpportunityService.handleOwnerAssignments(
      new Map<Id, Opportunity>{ o.Id => o },
      new Set<Id>{ a.Id }
    );
    Test.stopTest();

    o = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id = :o.Id];

    Assert.areEqual(standardUser.id, o.OwnerId);
  }

  @isTest
  static void testConditions() {
    Account a = [
      SELECT Id, FirstName, LastName, PersonEmail, Phone
      FROM Account
      LIMIT 1
    ];
    Referral__c ref = [
      SELECT Id, FirstName__c, LastName__c, Email__c, Phone__c
      FROM Referral__c
      LIMIT 1
    ];

    Assert.isTrue(OpportunityService.initialsAndEmailMatch(ref, a));
    Assert.isTrue(OpportunityService.initialsAndPhoneMatch(ref, a));
    Assert.isTrue(OpportunityService.emailPhoneAndNameMatch(ref, a));
  }

  private static User getUser(String name) {
    return new User(
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']
      .Id,
      LastName = name,
      Email = 'email@domain.com',
      Username = name + '@9randomdomain9.com',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      Alias = 'test'
    );
  }
}
