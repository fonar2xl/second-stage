public class CheckContactsBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                'SELECT Id, Name, FirstName, LastName, Birthdate, Email ' +
                'FROM Contact'
        );
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope){
        Date today = Date.today();
        EmailTemplate emailTemplate = [
                SELECT Id, Subject, Body
                FROM EmailTemplate
                WHERE Name = 'Happy Birthday'
        ];

        List<OrgWideEmailAddress> orgWibEmailAddress = [SELECT Id FROM OrgWideEmailAddress];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for (Contact contact: scope) {
            if (contact.Birthdate != null) {
                if (contact.Birthdate.month() == today.month() && contact.Birthdate.day() == today.day()) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(contact.Id);
                    mail.setTemplateId(emailTemplate.Id);
                    mail.setOrgWideEmailAddressId(orgWibEmailAddress[0].Id);
                    emailList.add(mail);
                }
            }
        }
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }
    public void finish(Database.BatchableContext bc){

    }
}