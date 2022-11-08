/**
 * Created by alexey on 02/11/2022.
 */
@IsTest
public with sharing class SendInvoiceByEmailControllerTest {
    @IsTest
    static void oppRolesAndEmailTemplateTest() {
        Opportunity opportunity = createContactAndOpp();
        List<EmailTemplate> emailTemplate = [
                SELECT Id, Name, Subject, Body
                FROM EmailTemplate
                WHERE Name = 'Custom Email Template'
        ];
        System.debug(emailTemplate);
        Test.startTest();
        SendInvoiceByEmailController.oppRolesAndEmailTemplate(opportunity.Id);
        Test.stopTest();
    }

    @IsTest
    static void sendEmailTemplateTest() {
        Opportunity opportunity = createContactAndOpp();
        Blob pdfBlob;
        PageReference pdfPage = Page.Invoice_PDF;
        pdfPage.getParameters().put('id', opportunity.Id);
        pdfBlob = Blob.valueOf('TEST');

        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = opportunity.Invoice_Number__c + '.pdf';
        cVersion.Origin = 'H';
        cVersion.Title = opportunity.Invoice_Number__c;
        cVersion.VersionData = pdfBlob;
        insert cVersion;

        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;
        cDocLink.LinkedEntityId = opportunity.Id;
        cDocLink.ShareType = 'I';
        cDocLink.Visibility = 'AllUsers';
        insert cDocLink;
        String str = 'Test';
        Id contactId = opportunity.OpportunityContactRoles[0].ContactId;
        Test.startTest();
        SendInvoiceByEmailController.sendEmailTemplate(str, contactId, conDocument);
        Test.stopTest();
    }

    private static Opportunity createContactAndOpp() {
        Contact newCont = new Contact(
                FirstName = 'Test',
                LastName = 'Name',
                Email = 'acme@acme.com'
        );
        insert newCont;
        Opportunity newOpp = new Opportunity(
                Name = 'Test opp',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(10)
        );
        insert newOpp;
        OpportunityContactRole newOppRole = new OpportunityContactRole(
                OpportunityId = newOpp.Id,
                ContactId = newCont.Id
        );
        insert newOppRole;
        Opportunity firstOpp = [
                SELECT Id, Invoice_Number__c,
                (
                        SELECT Id, Contact.Id
                        FROM OpportunityContactRoles
                )
                FROM Opportunity
        ];
        return firstOpp;
    }
}