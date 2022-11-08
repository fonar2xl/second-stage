global class GetEmailMessage implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        List<String> newStr = email.subject.split(': ');
        Opportunity opp = [
                SELECT Id, StageName
                FROM Opportunity
                WHERE Invoice_Number__c = :newStr[1]
        ];
        Schema.DescribeFieldResult testStage = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> testPickListValues = testStage.getPicklistValues();

        if (opp.StageName != 'Closed Lost' && opp.StageName != 'Closed Won') {
            String myPlainText = email.plainTextBody;
            if (myPlainText.toLowerCase().contains('approved')) {
                for (Integer i = 0; i < testPickListValues.size(); i++) {
                    if (testPickListValues[i].getValue() == opp.StageName) {
                        opp.StageName = testPickListValues[i + 1].getValue();
                        break;
                    }
                }
            }
            if (myPlainText.toLowerCase().contains('rejected')) {
                opp.StageName = 'Closed Lost';
            }
        }

        update opp;
        result.success = true;
        return result;
    }
}