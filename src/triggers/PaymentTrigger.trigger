/**
 * Created by alexey on 23/11/2022.
 */

trigger PaymentTrigger on Payment__c (after insert) {
    PaymentTriggerHandler.changeStageOppAndCreateTask(Trigger.new);
}