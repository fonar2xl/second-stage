/**
 * Created by alexey on 02/11/2022.
 */
@IsTest
public with sharing class GetEmailMessageTest {
    @IsTest
    static void testUnsubscribeApproved() {
        inboundEmailTest('Approved');
        System.assertEquals('Qualification', [SELECT Id, StageName FROM Opportunity LIMIT 1].StageName);
    }

    @IsTest
    static void testUnsubscribeRejected() {
        inboundEmailTest('Rejected');
        System.assertEquals('Closed Lost', [SELECT Id, StageName FROM Opportunity LIMIT 1].StageName);
    }
    private static void inboundEmailTest(String str) {
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today().addDays(10);
        insert opp;

        Opportunity opps = [SELECT Id, Invoice_Number__c FROM Opportunity];

        email.subject = 'Re: ' + opps.Invoice_Number__c;
        email.plainTextBody = str;
        env.fromAddress = 'user@acme.com';

        Test.startTest();
        GetEmailMessage unsubscribeObj = new GetEmailMessage();
        unsubscribeObj.handleInboundEmail(email, env);
        Test.stopTest();
    }

}