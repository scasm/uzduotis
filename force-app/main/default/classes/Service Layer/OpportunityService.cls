/**
 * @description  :
 * @author       : Justas Stonkus
 * @group        :
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2024-03-18   Justas Stonkus   Initial Version
 **/
public with sharing class OpportunityService {
  /**
   * @description - Handles opportunity owner assignments
   * @author Justas Stonkus | 2024-03-18
   * @param Map<Id Opportunity> oppMap - Map of opportunities
   * @param Set<Id> accountIds - Set of account ids
   **/
  public static void handleOwnerAssignments(
    Map<Id, Opportunity> oppMap,
    Set<Id> accountIds
  ) {
    fflib_ISObjectUnitOfWork uow = Application.UOW.newInstance();
    UserSelector userSelector = (UserSelector) Application.Selector.newInstance(
      User.SObjectType
    );
    AccountSelector accountSelector = (AccountSelector) Application.Selector.newInstance(
      Account.SObjectType
    );
    ReferralSelector referralSelector = (ReferralSelector) Application.Selector.newInstance(
      Referral__c.SObjectType
    );

    Map<Id, User> owners = new Map<Id, User>(
      userSelector.selectByOpportunityOwners(oppMap.keySet())
    );
    Map<Id, Account> accounts = new Map<Id, Account>(
      accountSelector.selectWithOpportunitiesById(accountIds)
    );
    List<Referral__c> referrals = referralSelector.selectForOpportunityUpdate();
    Id automatedProcessUserId = userSelector.getAutomatedProcessUser().Id;
    for (Opportunity opp : oppMap.values()) {
      User owner = owners.get(opp.OwnerId);

      if (
        owner.IsActive &&
        !owner.IsIntegrationUser__c &&
        owner.Name != 'Automated Process'
      ) {
        continue;
      }

      opp.OwnerId = automatedProcessUserId;
      assignOwner(opp, accounts, referrals);
    }
    uow.registerDirty(
      oppMap.values(),
      new List<SObjectField>{ Opportunity.OwnerId }
    );
    uow.commitWork();
  }

  /**
   * @description - Assigns owner to opportunity based on account or referral data
   * @author Justas Stonkus | 2024-03-18
   * @param Opportunity opp - Opportunity record
   * @param Map<Id Account> accounts - Map of accounts
   * @param List<Referral__c> referrals - List of referralss
   **/
  private static void assignOwner(
    Opportunity opp,
    Map<Id, Account> accounts,
    List<Referral__c> referrals
  ) {
    if (opp.AccountId == null) {
      return;
    }

    Account acc = accounts.get(opp.AccountId);
    if (!acc.Opportunities.isEmpty()) {
      opp.OwnerId = acc.Opportunities[0].OwnerId;
      return;
    }
    for (Referral__c referral : referrals) {
      if (
        initialsAndEmailMatch(referral, acc) ||
        initialsAndPhoneMatch(referral, acc) ||
        emailPhoneAndNameMatch(referral, acc)
      ) {
        opp.OwnerId = referral.OwnerId;
        break;
      }
    }
  }

  /**
   * @description - Checks if referral initials and email match account initials and email
   * @author Justas Stonkus | 2024-03-18
   * @param Referral__c referral - Referral record
   * @param Account acc - Account record
   * @return Boolean
   **/
  private static Boolean initialsAndEmailMatch(
    Referral__c referral,
    Account acc
  ) {
    return referral.FirstName__c?.uncapitalize().left(1) ==
      acc.FirstName?.uncapitalize().left(1) &&
      referral.LastName__c?.uncapitalize().left(1) ==
      acc.LastName?.uncapitalize().left(1) &&
      referral.Email__c?.toLowerCase() == acc.PersonEmail?.toLowerCase();
  }

  /**
   * @description - Checks if referral initials and phone match account initials and phone
   * @author Justas Stonkus | 2024-03-18
   * @param Referral__c referral - Referral record
   * @param Account acc - Account record
   * @return Boolean
   **/
  private static Boolean initialsAndPhoneMatch(
    Referral__c referral,
    Account acc
  ) {
    return referral.FirstName__c?.uncapitalize().left(1) ==
      acc.FirstName?.uncapitalize().left(1) &&
      referral.LastName__c?.uncapitalize().left(1) ==
      acc.LastName?.uncapitalize().left(1) &&
      referral.Phone__c?.replaceAll('[^0-9.]', '').right(4) ==
      acc.Phone?.replaceAll('[^0-9.]', '').right(4);
  }

  /**
   * @description - Checks if referral email, phone and name match account email, phone and name
   * @author Justas Stonkus | 2024-03-18
   * @param Referral__c referral - Referral record
   * @param Account acc - Account record
   * @return Boolean
   **/
  private static Boolean emailPhoneAndNameMatch(
    Referral__c referral,
    Account acc
  ) {
    return referral.Email__c?.toLowerCase() == acc.PersonEmail?.toLowerCase() &&
      referral.Phone__c?.replaceAll('[^0-9.]', '').right(4) ==
      acc.Phone?.replaceAll('[^0-9.]', '').right(4) &&
      referral.FirstName__c?.uncapitalize().left(1) ==
      acc.FirstName?.uncapitalize().left(1);
  }
}
