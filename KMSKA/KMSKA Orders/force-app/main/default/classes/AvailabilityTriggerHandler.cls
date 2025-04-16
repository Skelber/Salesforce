public class AvailabilityTriggerHandler {
	
    public static void handleRecurringAvailabilityChange(Map<Id,Availablility__c> availibilitiesMap){
        Map<Id,Availablility__c> parentAvailabilities = new Map<Id,Availablility__c>([SELECT Id,Start__c,End__c,Start_Recurring__c,End_Recurring__c,RecordTypeId, Guide__c,OwnerId,
                                                                                      (SELECT Id,Start__c,End__c,End_Recurring__c FROM Availablilities__r ORDER BY Start__c ASC) 
                                                                                      FROM Availablility__c WHERE Id IN :availibilitiesMap.keySet()
                                                                                     ]);
        Set<Id> childTobeDeleted = new Set<Id>();
        List<Availablility__c> childTobeInserted = new List<Availablility__c>();
        List<Availablility__c> childTobeUpdated = new List<Availablility__c>();
        
        for(Id avId : parentAvailabilities.keySet()){
            Availablility__c parentAV = parentAvailabilities.get(avId);
            Availablility__c oldAV = availibilitiesMap.get(avId);
            
            if(parentAV.End_Recurring__c > oldAV.End_Recurring__c){
                for(Availablility__c av : parentAV.Availablilities__r){
                    av.End_Recurring__c = parentAV.End_Recurring__c;
                    childTobeUpdated.add(av);
                }
                
                List<Availablility__c> avToInsert = createNewChildAVs(parentAV, oldAV.End_Recurring__c);
                if(avToInsert.size()>0)
                    childTobeInserted.addAll(avToInsert);
                
            }else if(parentAV.End_Recurring__c < oldAV.End_Recurring__c){
                Set<Id> avToDelete = new Set<Id>();
                if(parentAV.Availablilities__r!=null && parentAV.Availablilities__r.size()>0){
                    for(Availablility__c av : parentAV.Availablilities__r){
                        if( (av.End__c).Date() > parentAV.End_Recurring__c){
                            childTobeDeleted.add(av.Id);
                        }else{
                            av.End_Recurring__c = parentAV.End_Recurring__c;
                            childTobeUpdated.add(av);
                        }
                    }
                }
            }
        }

        if(childTobeInserted.size()>0)
            insert childTobeInserted;

		if(childTobeUpdated.size()>0)
            update childTobeUpdated;
        
        if(childTobeDeleted.size()>0)
            deleteAvs(childTobeDeleted);
    }
    
    public static List<Availablility__c> createNewChildAVs(Availablility__c parentAV, Date oldRecurringDate){
        List<Availablility__c> childRecords = new List<Availablility__c>();
        Datetime nextDate = (parentAV.Start__c).addDays(7);
        Datetime nextEndDate = (parentAV.End__c).addDays(7);
        
        while( nextDate.Date() <= parentAV.End_Recurring__c ){
            
            if(nextDate.Date() > oldRecurringDate){
                Availablility__c cAvail = new Availablility__c();
                cAvail.Start__c = nextDate;
                cAvail.End__c = nextEndDate;
                cAvail.Start_Recurring__c = parentAV.Start_Recurring__c;
                cAvail.End_Recurring__c = parentAV.End_Recurring__c;
                cAvail.Parent__c = false;
                cAvail.Parent_Availablility__c = parentAV.Id;
                cAvail.RecordTypeId = parentAV.RecordTypeId;
                cAvail.Guide__c = parentAV.Guide__c;
                cAvail.OwnerId = parentAV.OwnerId;
                
                childRecords.add(cAvail);
            }
            
            nextDate = nextDate.addDays(7);
            nextEndDate = nextEndDate.addDays(7);
            System.debug(nextDate);
        }
        return childRecords;
    }
    
    public static void deleteAvs(Set<Id> avToDelete){
        List<Availablility__c> avLst = [SELECT Id, (SELECT Id FROM Activity_Products__r) FROM Availablility__c WHERE Id IN: avToDelete];
        
        List<Availablility__c> avLstToDelete = new List<Availablility__c>();
        for(Availablility__c AV: avLst){
            system.debug('AV.Activity_Products__r : ' + AV.Activity_Products__r.size());
            if(AV.Activity_Products__r.size()==0){
                avLstToDelete.add(AV);
            }
        }
        
        if(avLstToDelete.size()>0){
            Delete avLstToDelete;
        }
    }
}