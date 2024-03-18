/**
 * @description  :
 * @author       : Justas Stonkus
 * @group        :
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2024-03-17   Justas Stonkus   Initial Version
 **/
public with sharing class AccountSelector extends fflib_SObjectSelector {
  /**
   * @description - Construct which sets up the selector
   * @author Justas Stonkus | 2024-03-18
   **/
  public AccountSelector() {
    super(false, true, true, false);
  }
  /**
   * @description Returns the list of fields that are retrieved in all SOQLS
   * @author Justas Stonkus | 2024-03-18
   * @return List<Schema.SObjectField> - list of sobject fields
   **/
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{ Account.Id };
  }
  /**
   * @description - Returns the SObjectType of the SObject that is being selected by this selector class
   * @author Justas Stonkus | 2024-03-18
   * @return Schema.SObjectType - SObjectType of the SObject that is being selected by this selector class
   **/
  public Schema.SObjectType getSObjectType() {
    return Account.SObjectType;
  }
  /**
   * @description - Returns the list of Account records by their Ids
   * @author Justas Stonkus | 2024-03-18
   * @param Set<Id> accountIds  - Set of Account Ids
   * @return List<Account> - list of Account records
   **/
  public List<Account> selectById(Set<Id> accountIds) {
    return (List<Account>) selectSObjectsById(accountIds);
  }

  /**
  * @description - Returns the list of Account records by their Ids
   with Opportunities created in the last 60 days
  * @author Justas Stonkus | 2024-03-18 
  * @param Set<Id> accountIds - Set of Account Ids
  * @return List<Account> - list of Account records
  **/
  public List<Account> selectWithOpportunitiesById(Set<Id> accountIds) {
    fflib_QueryFactory mainQuery = newQueryFactory()
      .selectField(Account.FirstName)
      .selectField(Account.LastName)
      .selectField(Account.PersonEmail)
      .selectField(Account.Phone)
      .setCondition('Id IN :accountIds');

    mainQuery.subselectQuery('Opportunities')
      .selectField(Opportunity.OwnerId)
      .setCondition(
        'CreatedDate = LAST_N_DAYS:60 AND Owner.IsActive = true AND Owner.IsIntegrationUser__c = false AND Owner.Name != \'Automated Process\''
      )
      .setOrdering(
        Opportunity.CreatedDate,
        fflib_QueryFactory.SortOrder.DESCENDING
      );
    return Database.query(mainQuery.toSOQL());
  }
}
