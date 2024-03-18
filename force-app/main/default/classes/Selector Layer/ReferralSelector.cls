/**
 * @description  :
 * @author       : Justas Stonkus
 * @group        :
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2024-03-17   Justas Stonkus   Initial Version
 **/
public with sharing class ReferralSelector extends fflib_SObjectSelector {
  /**
   * @description - Construct which sets up the selector
   * @author Justas Stonkus | 2024-03-18
   **/
  public ReferralSelector() {
    super(false, true, true, false);
  }
  /**
   * @description Returns the list of fields that are retrieved in all SOQLS
   * @author Justas Stonkus | 2024-03-18
   * @return List<Schema.SObjectField> - list of sobject fields
   **/
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{ Referral__c.Id };
  }
  /**
   * @description - Returns the SObjectType of the SObject that is being selected by this selector class
   * @author Justas Stonkus | 2024-03-18
   * @return Schema.SObjectType - SObjectType of the SObject that is being selected by this selector class
   **/
  public Schema.SObjectType getSObjectType() {
    return Referral__c.SObjectType;
  }
  /**
   * @description - Returns the list of referral records by their Ids
   * @author Justas Stonkus | 2024-03-18
   * @param Set<Id> referralIds  - Set of referral Ids
   * @return List<Referral__c> - list of referral records
   **/
  public List<Referral__c> selectById(Set<Id> referralIds) {
    return (List<Referral__c>) selectSObjectsById(referralIds);
  }

  /**
   * @description - Returns the list of referral records by specified conditions
   * @author Justas Stonkus | 2024-03-18
   * @return List<Referral__c> - list of referral records
   **/
  public List<Referral__c> selectForOpportunityUpdate() {
    List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
      Referral__c.LastName__c,
      Referral__c.FirstName__c,
      Referral__c.Email__c,
      Referral__c.Phone__c,
      Referral__c.OwnerId
    };
    fflib_QueryFactory mainQuery = newQueryFactory()
      .selectFields(fields)
      .setCondition(
        'ExpirationDate__c >= TODAY AND Source__c = \'Internal\' AND Owner.IsActive = true AND OwnerIsIntegrationUser__c = false AND Owner.Name != \'Automated Process\''
      );
    return Database.query(mainQuery.toSOQL());
  }
}
