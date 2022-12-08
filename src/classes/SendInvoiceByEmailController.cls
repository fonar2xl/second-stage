/**
 * Created by alexey on 21/10/2022.
 */

public with sharing class SendInvoiceByEmailController {
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> oppRolesAndEmailTemplate(Id ids) {
        Map<String, Object> result = new Map<String, Object>();
        Opportunity oppRoles = [
                SELECT Id, Invoice_Number__c, (SELECT Id, Contact.Name, Contact.Email FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE Id = :ids
        ];
        result.put('OpportunityRoles', oppRoles);
        EmailTemplate emailTemplate = [
                SELECT Id, Subject, Body
                FROM EmailTemplate
                WHERE Name = 'Custom Email Template'
        ];
        emailTemplate.Subject = oppRoles.Invoice_Number__c;
        result.put('EmailTemplate', emailTemplate);
        List<ContentDocumentLink> files = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :ids
        ];
        result.put('contentDocId', files);
        return result;
    }

    @AuraEnabled(Cacheable=true)
    public static void sendEmailTemplate(String emailTemplateBody, Id contactId, Id contentDocId) {
        Contact contactEmail = [
                SELECT Id
                FROM Contact
                WHERE Id = :contactId
        ];
        System.debug(emailTemplateBody);
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<ContentVersion> contVers = [
                SELECT Id, Title
                FROM ContentVersion
                WHERE ContentDocumentId = :contentDocId
                ORDER BY CreatedDate DESC
        ];
        List<OrgWideEmailAddress> orgWibEmailAddress = [SELECT Id FROM OrgWideEmailAddress];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(contVers[0].Title);
        mail.setTargetObjectId(contactEmail.Id);
        mail.setHtmlBody(emailTemplateBody);
        mail.setEntityAttachments(new List<String>{
                contVers[0].Id
        });
        mail.setInReplyTo('get_email_message@9cn57k2ibm7jq1m6zp8x41mir1gsm3b2rnt4aw2df4necvxhm.5g-hlfvxeax.ap24.apex.salesforce.com');
        mail.setOrgWideEmailAddressId(orgWibEmailAddress[0].Id);
        emailList.add(mail);

        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }
}