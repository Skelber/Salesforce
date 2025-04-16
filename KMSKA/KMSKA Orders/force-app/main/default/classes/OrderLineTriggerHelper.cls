public class OrderLineTriggerHelper {
    @future
    public static void handleOppParticipantsAndAmountFuture(set<Id> amountOppIds,set<Id> participantsOppIds){
        handleOppParticipantsAndAmount(amountOppIds,participantsOppIds);
    }
    
    public static void handleOppParticipantsAndAmount(set<Id> amountOppIds,set<Id> participantsOppIds){
        List<Opportunity> oppAmountLst = [SELECT Id,Name, Discount__c, 
                                          (SELECT Id, Price__c,Quantity__c,Type__c FROM Order_Lines__r) 
                                          FROM Opportunity 
                                          WHERE Id IN:amountOppIds AND (NOT Name LIKE 'Tickets - %')
                                         ];
        List<Opportunity> oppParticipantsLst = [SELECT Id,Name, Discount__c, 
                                                (SELECT Id, Price__c,Quantity__c,Type__c FROM Order_Lines__r WHERE Type__c = 'Ticket') 
                                                FROM Opportunity 
                                                WHERE Id IN:amountOppIds AND (NOT Name LIKE 'Tickets - %')
                                               ];
        
        Map<Id,Opportunity> oppLstToup = new Map<Id,Opportunity>();
        
        for(Opportunity opp: oppAmountLst){
            Decimal oppAmount = 0;
            if(opp.Order_Lines__r.size()>0){
                for(Order_Line__c OL: opp.Order_Lines__r){
                    if(OL.Price__c!=null)
                        oppAmount += (OL.Quantity__c!=null)?(OL.Price__c * OL.Quantity__c): OL.Price__c; 
                }
            }
            opp.Amount = (opp.Discount__c!=null)? (oppAmount-opp.Discount__c) : oppAmount;
            oppLstToup.put(opp.Id,opp);
        }
        
        for(Opportunity opp: oppParticipantsLst){
            Decimal oppParticipants = 0;
            if(opp.Order_Lines__r.size()>0){
                for(Order_Line__c OL: opp.Order_Lines__r){
                    if(OL.Quantity__c!=null)
                        oppParticipants += OL.Quantity__c;
                }
            }
            
            if(oppLstToup.containsKey(opp.Id)){
                Opportunity oppM = oppLstToup.get(opp.Id);
                oppM.Participants__c = Integer.valueOf(oppParticipants);
                oppLstToup.put(oppM.Id, oppM);
            }else{
                opp.Participants__c = oppParticipants;
                oppLstToup.put(opp.Id,opp);
            }
        }
        if( (!Test.isRunningTest()) && oppLstToup.size()>0)
            update oppLstToup.values();
    }
}