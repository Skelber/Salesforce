global class OpportunityAmountAndParticipantScheduler Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        Datetime lastModified = Datetime.now().addMinutes(-32);
        List<AggregateResult> lstOrderLines = [SELECT Order__c 
                                               FROM Order_Line__c 
                                               WHERE LastModifiedDate >=:lastModified AND Order__r.Name LIKE 'Tickets - %' 
                                               GROUP BY Order__c 
                                              ];
        Set<Id> oppId = new Set<Id>();
        for (AggregateResult ar : lstOrderLines) {
            oppId.add((Id)ar.get('Order__c'));
        }
        if(oppId.size()>0) calculateAmountAndParticipants(oppId);
    }
    
    public static void calculateAmountAndParticipants(Set<Id> oppId){
        List<Opportunity> oppLst = [SELECT Id,Name, Discount__c, 
                                    (SELECT Id, Price__c,Quantity__c,Type__c FROM Order_Lines__r) 
                                    FROM Opportunity 
                                    WHERE Id IN:oppId
                                   ];
        
        List<Opportunity> oppLstToUp = new List<Opportunity>();
        for(Opportunity opp : oppLst){
            Decimal oppParticipants = 0;
            Decimal oppAmount = 0;
            if(opp.Order_Lines__r.size()>0){
                for(Order_Line__c OL: opp.Order_Lines__r){
                    if(OL.Price__c!=null)
                        oppAmount += (OL.Quantity__c!=null)?(OL.Price__c * OL.Quantity__c): OL.Price__c; 
                    if(OL.Quantity__c!=null && OL.Type__c=='Ticket')
                        oppParticipants += OL.Quantity__c;
                }
            }
            opp.Amount = (opp.Discount__c!=null)? (oppAmount-opp.Discount__c) : oppAmount;
            opp.Participants__c = oppParticipants;
            oppLstToUp.add(opp);
        }
        if(oppLstToUp.size()>0)
            update oppLstToUp;
    }
}