/**
 * @description  :
 * @author       : Justas Stonkus
 * @group        :
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2024-03-17   Justas Stonkus   Initial Version
 **/
public with sharing class Opportunities extends fflib_SObjectDomain {
  /**
   * @description Calls the parent constructor
   * @author Justas Stonkus | 2024-03-17
   * @param List<Opportunity> opportunityRecords - List of Opportunity records that will be used to initialize this class
   **/
  public Opportunities(List<Opportunity> opportunityRecords) {
    super(opportunityRecords);
  }

  public class Constructor implements fflib_SObjectDomain.IConstructable {
    /**
     * @description This acts as a way to use the concept of reflection when initializing this class, despite the fact apex still does not support it.
     * @author Justas Stonkus | 2024-03-17
     * @param List<SObject> sObjectList - List of SObjects that will be used to initialize this class
     * @return fflib_SObjectDomain - Returns the instance of the domain class
     **/
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new Opportunities(sObjectList);
    }
  }

  /**
   * @description After insert method of Opportunity records
   * @author Justas Stonkus | 2024-03-17
   **/
  public override void onAfterInsert() {
    Map<Id, List<Opportunity>> ownerOppMap = new Map<Id, List<Opportunity>>();
    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
    Set<Id> accountIds = new Set<Id>();
    Set<Id> ownerIds = new Set<Id>();
    for (Opportunity opp : (List<Opportunity>) Records) {
      if (opp.OwnerId != null) {
        oppMap.put(
          opp.Id,
          new Opportunity(
            Id = opp.Id,
            OwnerId = opp.OwnerId,
            AccountId = opp.AccountId
          )
        );
        if (opp.AccountId != null) {
          accountIds.add(opp.AccountId);
        }
      }
    }

    if (!oppMap.isEmpty()) {
      OpportunityService.handleOwnerAssignments(oppMap, accountIds);
    }
  }

  /**
   * @description - After update method of Opportunity records
   * @author Justas Stonkus | 2024-03-18
   * @param Map<Id SObject> oldRecords - Map of old Opportunity records
   **/
  public override void onAfterUpdate(Map<Id, SObject> oldRecords) {
    Map<Id, List<Opportunity>> ownerOppMap = new Map<Id, List<Opportunity>>();
    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
    Set<Id> accountIds = new Set<Id>();
    Set<Id> ownerIds = new Set<Id>();
    for (Opportunity opp : (List<Opportunity>) Records) {
      Opportunity oldOpp = (Opportunity) oldRecords.get(opp.Id);
      if (opp.OwnerId != oldOpp.OwnerId) {
        oppMap.put(
          opp.Id,
          new Opportunity(
            Id = opp.Id,
            OwnerId = opp.OwnerId,
            AccountId = opp.AccountId
          )
        );
        if (opp.AccountId != null) {
          accountIds.add(opp.AccountId);
        }
      }
    }

    if (!oppMap.isEmpty()) {
      OpportunityService.handleOwnerAssignments(oppMap, accountIds);
    }
  }
}
