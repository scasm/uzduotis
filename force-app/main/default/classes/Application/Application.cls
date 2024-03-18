/**
 * @description  :
 * @author       : Justas Stonkus
 * @group        :
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2024-03-17   Justas Stonkus   Initial Version
 **/
public with sharing class Application {
  public static final fflib_Application.UnitOfWorkFactory UOW = new fflib_Application.UnitOfWorkFactory(
    new List<SObjectType>{ Opportunity.SObjectType }
  );

  public static final fflib_Application.SelectorFactory selector = new fflib_Application.SelectorFactory(
    new Map<SObjectType, Type>{
      Account.SObjectType => AccountSelector.class,
      Referral__c.SObjectType => ReferralSelector.class,
      User.SObjectType => UserSelector.class
    }
  );
}
