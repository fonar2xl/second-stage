/**
 * Created by alexey on 02/11/2022.
 */
@IsTest
public with sharing class GetCustomerDataTest {
    @IsTest
    static void getClosedOpportunityTestOnSearchString(){
        createAccountAndOpportunity();
        Test.startTest();
        List<Map<String, Object>> result = GetCustomerData.getClosedOpportunity('123', '', 0);
        Test.stopTest();
        System.assertEquals('test123 $7500.0', result[0].get('label'));
    }
    @IsTest
    static void getClosedOpportunityTestOnId(){
        createAccountAndOpportunity();
        Id accountId = [SELECT Id FROM Account].Id;
        Test.startTest();
        List<Map<String, Object>> result = GetCustomerData.getClosedOpportunity('', accountId, 0);
        Test.stopTest();
        System.assertEquals(1, result[0].get('sizeQuery'));
    }
    @IsTest
    static void getOpportunityProductTest() {
        createAccountAndOpportunity();
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        createOpportunityLineItem(opportunity);

        Test.startTest();
        List<OpportunityLineItem> result = GetCustomerData.getOpportunityProduct(opportunity.Id);
        Test.stopTest();
        System.assertEquals('Kia Rio', result[0].Product2.Name);
    }

    private static void createOpportunityLineItem(Opportunity opportunity) {
        Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        update standardPricebook;

        Product2 newProduct = new Product2(
                Name = 'Kia Rio',
                IsActive = true
        );
        insert newProduct;

        PricebookEntry newPriceBookEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = newProduct.Id,
                UnitPrice = 750,
                IsActive = true
        );
        insert newPriceBookEntry;

        OpportunityLineItem newLineItem = new OpportunityLineItem(
                OpportunityId = opportunity.Id,
                Quantity = 2,
                TotalPrice = 5000,
                PricebookEntryId = newPriceBookEntry.Id
        );
        insert newLineItem;
    }

    private static void createAccountAndOpportunity() {
        Account newAcc = new Account(
                Name = 'test123'
        );
        insert newAcc;
        Opportunity newOpp = new Opportunity(
                Name = 'Test',
                Amount = 7500,
                CloseDate = Date.today(),
                StageName = 'Closed Won',
                AccountId = newAcc.Id
        );
        insert newOpp;
    }
}