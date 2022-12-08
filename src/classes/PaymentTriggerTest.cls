/**
 * Created by alexey on 01/12/2022.
 */
@IsTest
public with sharing class PaymentTriggerTest {
    @IsTest
    static void changeStageOppAndCreateTaskTest(){
        List<Payment__c> payments = createPayments();
        List<Opportunity> opportunities = createOpportunities();
        insert opportunities;
        Contact contact = createContact();
        insert contact;
        OpportunityContactRole opportunityContactRole = createOpportunityContactRole(contact, opportunities);
        insert opportunityContactRole;
        Test.startTest();
        insert payments;
        Test.stopTest();
        Opportunity opportunity= [SELECT Id, StageName FROM Opportunity WHERE Name = 'ikea-'];
        Task task = [SELECT Id, Subject FROM Task];
        System.assertEquals(opportunity.StageName, 'Fully Paid');
        System.assertEquals(task.Subject, 'Delivery of goods');
    }

    private static OpportunityContactRole createOpportunityContactRole(Contact contact, List<Opportunity> opportunities) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunities[1].Id,
                IsPrimary = true
        );
        return opportunityContactRole;
    }

    private static Contact createContact() {
        Contact contact = new Contact(
                FirstName = 'Alexey',
                LastName = 'Kamenev'
        );
        return contact;
    }

    private static List<Opportunity> createOpportunities() {
        List<Opportunity> opportunities = new List<Opportunity>();
        Opportunity firstOpportunity = new Opportunity(
                Name = 'Success Craft-',
                StageName = 'Value Proposition',
                CloseDate = Date.today(),
                Amount = 25000
        );
        opportunities.add(firstOpportunity);
        Opportunity secondOpportunity = new Opportunity(
                Name = 'ikea-',
                StageName = 'Value Proposition',
                CloseDate = Date.today(),
                Amount = 3750
        );
        opportunities.add(secondOpportunity);
        return opportunities;
    }

    private static List<Payment__c> createPayments() {
        List<Payment__c> payments = new List<Payment__c>();
        Payment__c firstPayment = new Payment__c(
                OpportunityName__c = 'Success Craft-',
                Amount__c = 20000,
                FirstName__c = 'Alexey',
                LastName__c = 'Kamenev'
        );
        payments.add(firstPayment);
        Payment__c secondPayment = new Payment__c(
                OpportunityName__c = 'ikea-',
                Amount__c = 3750,
                FirstName__c = 'Alexey',
                LastName__c = 'Kamenev'
        );
        payments.add(secondPayment);
        return payments;
    }
}