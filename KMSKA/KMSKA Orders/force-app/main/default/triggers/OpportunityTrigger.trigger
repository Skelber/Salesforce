trigger OpportunityTrigger on Opportunity (before insert, before update) {
    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    
    for (Opportunity opp : Trigger.new) {
        if(Trigger.isInsert) {
          System.debug('Insert');
            if (opp.Start_Time__c != null) {
                opportunitiesToUpdate.add(opp);  
            } 
        }
        if(Trigger.isUpdate){
                System.debug('Update');
                if (opp.Start_Time__c != Trigger.oldMap.get(opp.Id).Start_Time__c) {
                    opportunitiesToUpdate.add(opp);
                } 
        }
        
    }

    if (!opportunitiesToUpdate.isEmpty()) {
        OpportunityClass.setTimeValue(opportunitiesToUpdate);
    }
}