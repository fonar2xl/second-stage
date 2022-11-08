/**
 * Created by alexey on 02/11/2022.
 */
@IsTest
public with sharing class ShowInvoicePDFControllerTest {
    @IsTest
    static void attachPDFTestFirst() {
        Opportunity newOpp = new Opportunity(
                Name = 'Test opp',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(10)
        );
        insert newOpp;
        Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity];
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        Test.startTest();
        ShowInvoicePDFController showInvoicePDFController = new ShowInvoicePDFController(sc);
        showInvoicePDFController.attachPDF();
        Test.stopTest();
    }
    @IsTest
    static void attachPDFTestSecond() {
        Opportunity newOpp = new Opportunity(
                Name = 'Test opp',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(10)
        );
        insert newOpp;
        Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity];

        Blob pdfBlob;
        PageReference pdfPage = Page.Invoice_PDF;
        pdfPage.getParameters().put('id', opp.Id);
        pdfBlob = Blob.valueOf('TEST');

        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = opp.Invoice_Number__c + '.pdf';
        cVersion.Origin = 'H';
        cVersion.Title = opp.Invoice_Number__c;
        cVersion.VersionData = pdfBlob;
        insert cVersion;

        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;
        cDocLink.LinkedEntityId = opp.Id;
        cDocLink.ShareType = 'I';
        cDocLink.Visibility = 'AllUsers';
        insert cDocLink;


//        Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity];
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        Test.startTest();
        ShowInvoicePDFController showInvoicePDFController = new ShowInvoicePDFController(sc);
        showInvoicePDFController.attachPDF();
        Test.stopTest();
    }
}