/**
 * @description  :
 * @author       : Justas Stonkus
 * @group        :
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2024-03-17   Justas Stonkus   Initial Version
 **/
public with sharing class UserSelector extends fflib_SObjectSelector {
  /**
   * @description - Construct which sets up the selector
   * @author Justas Stonkus | 2024-03-18
   **/
  public UserSelector() {
    super(false, true, true, false);
  }
  /**
   * @description Returns the list of fields that are retrieved in all SOQLS
   * @author Justas Stonkus | 2024-03-18
   * @return List<Schema.SObjectField> - list of sobject fields
   **/
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{ User.Id };
  }
  /**
   * @description - Returns the SObjectType of the SObject that is being selected by this selector class
   * @author Justas Stonkus | 2024-03-18
   * @return Schema.SObjectType - SObjectType of the SObject that is being selected by this selector class
   **/
  public Schema.SObjectType getSObjectType() {
    return User.SObjectType;
  }
  /**
   * @description - Returns the list of User records by their Ids
   * @author Justas Stonkus | 2024-03-18
   * @param Set<Id> userIds  - Set of User Ids
   * @return List<User> - list of User records
   **/
  public List<User> selectById(Set<Id> userIds) {
    return (List<User>) Database.query(
      newQueryFactory()
        .selectField(User.Name)
        .selectField(User.IsIntegrationUser__c)
        .setCondition('Id IN :userIds')
        .toSOQL()
    );
  }

  /**
   * @description - Returns the list of User records by opportunity owners Ids
   * @author Justas Stonkus | 2024-03-18
   * @param Set<Id> opportunityIds - Set of Opportunity Ids
   * @return List<User> - list of User records
   **/
  public List<User> selectByOpportunityOwners(Set<Id> opportunityIds) {
    return (List<User>) Database.query(
      newQueryFactory()
        .selectField(User.Name)
        .selectField(User.IsActive)
        .selectField(User.IsIntegrationUser__c)
        .setCondition(
          'Id IN (SELECT OwnerId FROM Opportunity WHERE Id IN :opportunityIds)'
        )
        .toSOQL()
    );
  }

  /**
   * @description  - Returns the Automated Process User record by its name, if it exists, otherwise returns null
   * @author Justas Stonkus | 2024-03-18
   * @return User - Automated Process User record
   **/
  public User getAutomatedProcessUser() {
    List<User> users = (List<User>) Database.query(
      newQueryFactory()
        .setCondition('Name = \'Automated Process\'')
        .setLimit(1)
        .toSOQL()
    );
    return users.isEmpty() ? null : users[0];
  }
}
