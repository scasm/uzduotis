/**
 * @description  :
 * @author       : Justas Stonkus
 * @group        :
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2024-03-17   Justas Stonkus   Initial Version
 **/
trigger OpportunityTrigger on Opportunity(after insert, after update) {
  fflib_SObjectDomain.triggerHandler(Opportunities.class);
}
