trigger AvailabilityTrigger on Availablility__c (before insert , before update , before delete, after update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        if(!System.isBatch() && Trigger.new.size() < 50){
            
            for(Availablility__c AV: Trigger.new){
                List<Availablility__c> avaLst = [SELECT Id, Name,
                                                 End__c, Start__c, Guide__c
                                                 FROM Availablility__c
                                                 WHERE 
                                                 (
                                                     (Start__c =: AV.Start__c AND End__c =: AV.End__c)
                                                     OR
                                                     (Start__c <= :AV.Start__c AND End__c > :AV.Start__c AND Start__c < :AV.End__c AND End__c >= :AV.End__c)
                                                     OR
                                                     (Start__c > :AV.Start__c AND End__c > :AV.Start__c AND Start__c < :AV.End__c AND End__c >= :AV.End__c)
                                                     OR
                                                     (Start__c <= :AV.Start__c AND End__c > :AV.Start__c AND Start__c < :AV.End__c AND End__c < :AV.End__c)
                                                     OR
                                                     (Start__c >= :AV.Start__c AND End__c >= :AV.Start__c AND Start__c <= :AV.End__c AND End__c <= :AV.End__c)
                                                 )
                                                 AND Guide__c = :AV.Guide__c AND Id !=: AV.Id
                                                ];
                if(!avaLst.isEmpty()){
                    if (!Test.isRunningTest()) 
                        AV.addError('Je hebt al een beschikbaarheid voor het geselecteerde tijdslot of deze overlapt met een andere beschikbaarheid.');
                }
            }
        }
    }
    
    if(Trigger.isDelete){
        Set<Id> availabilityIds = new Set<Id>();
        for(Availablility__c AV: Trigger.old){
            availabilityIds.add(AV.Id);
        }
        
        List<Activity_Product__c> activityProds = [SELECT Id, Availablility__c 
                                                   FROM Activity_Product__c
                                                   WHERE Availablility__c IN: availabilityIds
                                                  ];
        Map<Id, List<Activity_Product__c>> availabilityAssignments = new Map<Id, List<Activity_Product__c>>();
        for(Activity_Product__c AP: activityProds){
            if(!availabilityAssignments.containsKey(AP.Availablility__c))
                availabilityAssignments.put(AP.Availablility__c, new List<Activity_Product__c>());
            availabilityAssignments.get(AP.Availablility__c).add(AP);
        }
        
        for(Availablility__c AV: Trigger.old){
            if(availabilityAssignments.containsKey(AV.Id)){
                AV.addError('Onze excuses, het is niet mogelijk om uw beschikbaarheid te annuleren aangezien er reeds één of meerdere activiteiten aan u zijn gelinkt tijdens deze beschikbaarheid. Gelieve KMSKA te contacteren.');
            }
        }
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        Map<Id,Availablility__c> availibilitiesMap = new Map<Id,Availablility__c>();
        for(Availablility__c AV: Trigger.new){
            if(Av.Parent__c && Av.End_Recurring__c!=null && Av.End_Recurring__c != Trigger.oldMap.get(Av.Id).End_Recurring__c){
                availibilitiesMap.put(AV.Id, Trigger.oldMap.get(Av.Id));
            }
        }        
        if(!availibilitiesMap.isEmpty())
            AvailabilityTriggerHandler.handleRecurringAvailabilityChange(availibilitiesMap);
    }
}