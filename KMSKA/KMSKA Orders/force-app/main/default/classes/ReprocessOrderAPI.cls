global class ReprocessOrderAPI implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, Participants__c, RecordType.Name, (SELECT Id,Price__c,Quantity__c, Type__c FROM Order_Lines__r)'
            +' FROM Opportunity WHERE (RecordType.Name = \'Order\' OR RecordType.Name =\'KMSKA Activities\') '
            +' AND Type !=\'Event\' AND Type !=\'Receptie\' AND Type !=\'Commercieel - non profit\' AND Type !=\'Commercieel - profit\' AND Type !=\'Partnerevent\'';
        if(Test.isRunningTest()){
            query += ' LIMIT 10';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppLst) {
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        for(Opportunity opp : oppLst){
            Integer NoOfTickets = 0;
            for(Order_Line__c OL: opp.Order_Lines__r){
                if(OL.Type__c=='Ticket')
                    NoOfTickets += (OL.Quantity__c!=null)?(Integer.valueOf(OL.Quantity__c)): 0; 
            }
            
            if(opp.Participants__c != NoOfTickets){
                opp.Participants__c = NoOfTickets;
            }
            oppToUpdate.add(opp);
        }
        if(oppToUpdate.size()>0) update oppToUpdate;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}