/**
 * @description  :
 * @author       : Justas Stonkus
 * @group        :
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2024-03-18   Justas Stonkus   Initial Version
 **/
@isTest
public with sharing class Opportunities_Test {
  @TestSetup
  static void makeData() {
    insert new Account(
      FirstName = 'Test',
      LastName = 'Account',
      PersonEmail = 'test@account.com',
      Phone = '99998888'
    );
  }

  @isTest
  static void testInsert() {
    User u = getUser('test');
    u.IsIntegrationUser__c = true;
    insert u;
    Opportunity o = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today(),
      OwnerId = u.Id
    );
    Test.startTest();
    insert o;
    Test.stopTest();
    o = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id = :o.Id];
    Assert.areNotEqual(u.Id, o.OwnerId);

    UserSelector userSelector = (UserSelector) Application.Selector.newInstance(
      User.SObjectType
    );
    Assert.areEqual(userSelector.getAutomatedProcessUser().Id, o.OwnerId);
  }

  @IsTest
  static void testUpdate() {
    User u = getUser('test');
    u.IsIntegrationUser__c = true;
    insert u;
    Opportunity o = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today()
    );
    insert o;

    o.OwnerId = u.Id;
    Test.startTest();
    update o;
    Test.stopTest();
    o = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id = :o.Id];
    Assert.areNotEqual(u.Id, o.OwnerId);

    UserSelector userSelector = (UserSelector) Application.Selector.newInstance(
      User.SObjectType
    );
    Assert.areEqual(userSelector.getAutomatedProcessUser().Id, o.OwnerId);
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
