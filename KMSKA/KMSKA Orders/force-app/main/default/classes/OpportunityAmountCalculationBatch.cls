global class OpportunityAmountCalculationBatch implements Database.Batchable<sObject>, Schedulable {
    
    global void execute (SchedulableContext sc){
        Database.executeBatch(new OpportunityAmountCalculationBatch(), 10);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Discount__c, (SELECT Id, Price__c,Quantity__c,Type__c FROM Order_Lines__r) FROM Opportunity';
        if(!Test.isRunningTest()){
            query += ' WHERE LastModifiedDate = today AND Name LIKE \'Tickets - %\'';
        }else{
            query+= ' ORDER BY CreatedDate LIMIT 5';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        List<Opportunity> oppLstToup = new List<Opportunity>();
        for(Opportunity opp: scope){
            Decimal oppAmount = 0;
            if(opp.Order_Lines__r.size()>0){
                for(Order_Line__c OL: opp.Order_Lines__r){
                    if(OL.Price__c!=null){
                        oppAmount += (OL.Quantity__c!=null)?(OL.Price__c * OL.Quantity__c): OL.Price__c;
                    }
                }
                opp.Amount = (opp.Discount__c!=null)? (oppAmount-opp.Discount__c) : oppAmount;
                oppLstToup.add(opp);
            }
        }
        update oppLstToup;
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}