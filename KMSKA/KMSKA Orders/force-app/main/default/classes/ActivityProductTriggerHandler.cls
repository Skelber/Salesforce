public class ActivityProductTriggerHandler {
    
    @future
    public static void handleAvailabilities(Set<Id> APIds){
        Id singleRecordTypeId;
        List<RecordType> recTypes = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Availablility__c'];
        for(RecordType r: recTypes){
            if(r.Name=='Single')
                singleRecordTypeId = r.Id;
        }
        
        List<Activity_Product__c> APlst = [SELECT Id, Start_Time__c, End_Time__c, 
                                           Availablility__c, Availablility__r.Start__c, Availablility__r.End__c,
                                           Availablility__r.Guide__c, Availablility__r.Parent_Availablility__c,
                                           Availablility__r.Parent__c, Availablility__r.RecordTypeId, Availablility__r.OwnerId
                                           FROM Activity_Product__c
                                           WHERE Id IN: APIds
                                          ];
        
        List<Availablility__c> availabilityToInsert = new List<Availablility__c>();
        List<Availablility__c> availabilityToUpdate = new List<Availablility__c>();
        
        for(Activity_Product__c AP: APlst){
            Boolean isParentUpdate = false;
            Availablility__c AV = new Availablility__c(Id = AP.Availablility__c,
                                                       Start__c = AP.Availablility__r.Start__c,
                                                       End__c = AP.Availablility__r.End__c,
                                                       Guide__c = AP.Availablility__r.Guide__c,
                                                       Parent_Availablility__c = AP.Availablility__r.Parent_Availablility__c,
                                                       Parent__c = AP.Availablility__r.Parent__c,
                                                       RecordTypeId = AP.Availablility__r.RecordTypeId,
                                                       OwnerId = AP.Availablility__r.OwnerId
                                                      );
            if(AP.Start_Time__c!=AV.Start__c && AV.Start__c < AP.Start_Time__c){
                Availablility__c bAV = new Availablility__c();
                bAV.Start__c = AV.Start__c;
                bAV.End__c = AP.Start_Time__c;
                bAV.Guide__c = AV.Guide__c;
                bAV.RecordTypeId = singleRecordTypeId;
                bAV.OwnerId = AV.OwnerId;
                availabilityToInsert.add(bAV);
                
                AV.Start__c = AP.Start_Time__c;
                isParentUpdate = true;
            }
            
            if(AP.End_Time__c!=AV.End__c && AV.End__c > AP.End_Time__c){
                Availablility__c aAV = new Availablility__c();
                aAV.Start__c = AP.End_Time__c;
                aAV.End__c = AV.End__c;
                aAV.Guide__c = AV.Guide__c;
                aAV.RecordTypeId = singleRecordTypeId;
                aAV.OwnerId = AV.OwnerId;
                availabilityToInsert.add(aAV);
                
                AV.End__c = AP.End_Time__c;
                isParentUpdate = true;
            }
            if(isParentUpdate)
                availabilityToUpdate.add(AV);
        }
        if(!availabilityToUpdate.isEmpty())
            updateParentAvailability(availabilityToUpdate);
        if(!availabilityToInsert.isEmpty())
            insert availabilityToInsert;
    }
    
    /*
1. If pAV's are the Single Availability.
1.1 - Update it.
2. If pAV's are the Recurring Availability.
2.1. If pAV is Parent Availability of the Recurring availability.
- Update all the child availability with the 'First Next' availability and Make it Single Availability.
2.2. If pAV is not Parent Availability of the Recurring availability.
- Update only pAV to Single Availability.
*/
    public static void updateParentAvailability(List<Availablility__c> pAVLst){
        Id singleRecordTypeId; Id recurringRecordTypeId;
        List<RecordType> recTypes = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Availablility__c'];
        for(RecordType r: recTypes){
            if(r.Name=='Recurring')
                recurringRecordTypeId = r.Id;
            if(r.Name=='Single')
                singleRecordTypeId = r.Id;
        }
        
        Set<Id> pAVIds = new Set<Id>();
        List<Availablility__c> availabilityToUpdate = new List<Availablility__c>();
        for(Availablility__c pAV : pAVLst){
            if(pAV.RecordTypeId == singleRecordTypeId){
                availabilityToUpdate.add(pAV);
            }else if(pAV.RecordTypeId == recurringRecordTypeId){
                pAV.RecordTypeId = singleRecordTypeId;
                pAV.Parent_Availablility__c = null;
                pAV.Start_Recurring__c = null;
                pAV.End_Recurring__c = null;
                
                if(pAV.Parent__c){
                    pAV.Parent__c = false;
                    pAVIds.add(pAV.Id);
                }
                availabilityToUpdate.add(pAV);
            }
        }
        
        if(!pAVIds.isEmpty()){
            List<Availablility__c> availabilitiesLst = [SELECT Id, (SELECT Id,Start__c, Parent__c FROM Availablilities__r ORDER BY Start__c ASC) FROM Availablility__c WHERE Id IN :pAVIds];
            for(Availablility__c AV: availabilitiesLst){
                if(AV.Availablilities__r.size()>0){
                    Id newParentId = AV.Availablilities__r[0].Id;
                    Integer index = 0;
                    for(Availablility__c cAV: AV.Availablilities__r){
                        if(index==0){
                            cAV.Parent__c = true;
                            cAV.Parent_Availablility__c = null;
                        }else{
                            cAV.Parent_Availablility__c = newParentId;
                        }
                        availabilityToUpdate.add(cAV);
                        index++;
                    }
                }
            }
        }
        
        if(!availabilityToUpdate.isEmpty())
            update availabilityToUpdate;
        
    }
    
    
    @future
    public static void handleAvailabilitiesMerge(Set<Id> AvailIdsToMerge){
        List<Availablility__c> availabilitiesLst = [SELECT Id, Start__c, End__c, Guide__c 
                                                    FROM Availablility__c 
                                                    WHERE Id IN :AvailIdsToMerge
                                                   ];
        
        List<Availablility__c> availbilitiesToDelete = new List<Availablility__c>();
        List<Availablility__c> availbilitiesToUpdate = new List<Availablility__c>();
        
        for(Availablility__c AV : availabilitiesLst){
            Boolean isUpdate = false;
            List<Availablility__c> prevAvailabilities = [SELECT Id, Start__c, End__c, Guide__c, (SELECT Id FROM Activity_Products__r)  
                                                         FROM Availablility__c 
                                                         WHERE End__c =: AV.Start__c
                                                         AND RecordType.Name = 'Single'
                                                         AND Guide__c =: AV.Guide__c
                                                        ];
            
            List<Availablility__c> nextAvailabilities = [SELECT Id, Start__c, End__c, Guide__c, (SELECT Id FROM Activity_Products__r)  
                                                         FROM Availablility__c 
                                                         WHERE Start__c =: AV.End__c
                                                         AND RecordType.Name = 'Single'
                                                         AND Guide__c =: AV.Guide__c
                                                        ];
            
            if(nextAvailabilities.size()>0 && nextAvailabilities[0].Activity_Products__r.size()==0){
                AV.End__c = nextAvailabilities[0].End__c;
                availbilitiesToDelete.add(nextAvailabilities[0]);
                isUpdate = true;
            }
            
            if(prevAvailabilities.size()>0 && prevAvailabilities[0].Activity_Products__r.size()==0){
                AV.Start__c = prevAvailabilities[0].Start__c;
                availbilitiesToDelete.add(prevAvailabilities[0]);
                isUpdate = true;
            }
            
            if(isUpdate){
                availbilitiesToUpdate.add(AV);
            }
        }
        
        if(availbilitiesToDelete.size()>0) delete availbilitiesToDelete;
        if(availbilitiesToUpdate.size()>0) update availbilitiesToUpdate;
    }
}