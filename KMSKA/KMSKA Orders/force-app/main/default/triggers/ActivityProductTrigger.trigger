trigger ActivityProductTrigger on Activity_Product__c (after insert, after update) {
    Set<Id> APIds = new Set<Id>();
    
    for(Activity_Product__c AP: Trigger.new){
        if(Trigger.isInsert && AP.Availablility__c!=null){
            APIds.add(AP.Id);
        }
        
        if(Trigger.isUpdate && AP.Availablility__c!=null && Trigger.oldMap.get(AP.Id).Availablility__c!=AP.Availablility__c){
            APIds.add(AP.Id);
        }
    }
    
    if(!APIds.isEmpty())
        ActivityProductTriggerHandler.handleAvailabilities(APIds);
    
    //If Availability is Removed from AP. 
    if(Trigger.isUpdate){
        Set<Id> AvailIdsToMerge = new Set<Id>();
        
        for(Activity_Product__c AP: Trigger.new){
            if(Trigger.oldMap.get(AP.Id).Availablility__c !=null && AP.Availablility__c != Trigger.oldMap.get(AP.Id).Availablility__c)
            {
                AvailIdsToMerge.add(Trigger.oldMap.get(AP.Id).Availablility__c);    
            }
        }
        
        if(!AvailIdsToMerge.isEmpty())
            ActivityProductTriggerHandler.handleAvailabilitiesMerge(AvailIdsToMerge);
    }
}