/**
 * Created by Alexey on 18.10.2022.
 */

public with sharing class ShowInvoicePDFController {
    public String recId;

    public ShowInvoicePDFController(ApexPages.StandardController standardPageController) {
        recId = standardPageController.getId();
    }

    public void attachPDF() {
        Opportunity opps = [
                SELECT Id, Invoice_Number__c
                FROM Opportunity
                WHERE Id = :recId
                LIMIT 1
        ];
        Blob pdfBlob;

        PageReference pdfPage = Page.Invoice_PDF;
        pdfPage.getParameters().put('id', recId);
        pdfBlob = Test.isRunningTest() ? Blob.valueOf('TEST'): pdfPage.getContent();

        List<ContentDocument> contentDocuments = [
                SELECT Id
                FROM ContentDocument
                WHERE Title = :opps.Invoice_Number__c
        ];

        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = opps.Invoice_Number__c + '.pdf';
        cVersion.Origin = 'H';
        cVersion.Title = opps.Invoice_Number__c;
        cVersion.VersionData = pdfBlob;
        if (!contentDocuments.isEmpty()) {
            cVersion.ContentDocumentId = contentDocuments[0].Id;
        }
        insert cVersion;

        if (contentDocuments.isEmpty()) {
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cVersion.Id].ContentDocumentId;
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;
            cDocLink.LinkedEntityId = recId;
            cDocLink.ShareType = 'I';
            cDocLink.Visibility = 'AllUsers';
            insert cDocLink;
        }

    }
}