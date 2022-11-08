/**
 * Created by alexey on 31/10/2022.
 */

public with sharing class GetCustomerData {

    @AuraEnabled(Cacheable=true)
    public static List<Map<String, Object>> getClosedOpportunity(String searchString, String accountId, Integer startIndex) {
        String query = creatQuery(searchString, accountId);
        
        Integer sizeQuery = Database.query(query).size();

        query += 'LIMIT 10 OFFSET :startIndex';
        List<AggregateResult> result = Database.query(query);

        List<String> accountIds = new List<String>();
        for (AggregateResult aggregate : result) {
            accountIds.add(String.valueOf(aggregate.get('AccountId')));
        }
        List<Opportunity> opportunities = getOpportunities(accountIds);

        List<Map<String, Object>> items = new List<Map<String, Object>>();
        for (AggregateResult agr : result) {
            List<Opportunity> childOpportunities = new List<Opportunity>();
            for (Opportunity opp : opportunities) {
                if (opp.AccountId == agr.get('AccountId')) {
                    childOpportunities.add(opp);
                }
            }
            items.add(new Map<String, Object>{
                    'label' => agr.get('Name') + ' $' + agr.get('expr0'),
                    'opportunities' => childOpportunities,
                    'sizeQuery' => sizeQuery
            });
        }
        System.debug(items);
        return items;
    }

    public static List<Opportunity> getOpportunities(List<String> accountIds) {
        return [
                SELECT Id, Name, CloseDate, CreatedDate, Amount, AccountId
                FROM Opportunity
                WHERE AccountId IN :accountIds AND (StageName = 'Closed Won' OR StageName = 'Closed Lost')
        ];
    }

    public static String creatQuery(String searchString, String accountId) {
        String query = 'SELECT Account.Name, AccountId, SUM(Amount) ' +
                'FROM Opportunity ' +
                'WHERE (StageName = \'Closed Won\' OR StageName = \'Closed Lost\') ' +
                'GROUP BY Account.Name, AccountId ';
        if (String.isNotBlank(accountId)) {
            query += 'HAVING AccountId = :accountId ';
        }
        if (String.isNotBlank(searchString)) {
            query += 'HAVING Account.Name LIKE \'%' + searchString + '%\' ';
            if (searchString.isNumeric()) {
                query += 'OR SUM(Amount) = ' + Decimal.valueOf(searchString) + ' ';
            }
        }
        return query;
    }

    @AuraEnabled(Cacheable=true)
    public static List<OpportunityLineItem> getOpportunityProduct(String opportunityId) {
        return [
                SELECT Id, Product2.Name
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
                ORDER BY Product2.Name
        ];
    }
}