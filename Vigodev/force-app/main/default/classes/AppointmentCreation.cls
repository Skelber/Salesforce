public without sharing class AppointmentCreation {
    
    @AuraEnabled(cacheable=false)
    public static String saveServiceAppointmentObject(String serviceappointment) {
        try {
            
            ResponseSA saResult = (ResponseSA)JSON.deserialize(serviceappointment, ResponseSA.class);
            System.debug(saResult);
            
            
            TimeZone tz = Timezone.getTimeZone('Europe/Brussels');
            Integer milliSeconds = tz.getOffset(saResult.startTime);
            Integer minutes = milliSeconds / 60000;
            Integer offSetHours = minutes / 60;
            saResult.startTime = saResult.startTime.addHours(-1*offSetHours);
            
            
            List<AssignedResource> overlappingAppointment = [SELECT id FROM AssignedResource 
                                                             WHERE ServiceResourceId = :saResult.resourceId AND ServiceAppointment.Status != 'Canceled' 
                                                             AND (
                                                                 (ServiceAppointment.SchedStartTime >= :saResult.startTime AND ServiceAppointment.SchedStartTime < :saResult.starttime.addMinutes(saResult.duration))
                                                                 OR (ServiceAppointment.SchedEndTime > :saResult.startTime AND ServiceAppointment.SchedEndTime <= :saResult.starttime.addMinutes(saResult.duration))   
                                                                 OR (ServiceAppointment.SchedStartTime <= :saResult.startTime AND ServiceAppointment.SchedEndTime >= :saResult.starttime.addMinutes(saResult.duration)) 
                                                                 OR (ServiceAppointment.SchedStartTime >= :saResult.startTime AND ServiceAppointment.SchedEndTime <= :saResult.starttime.addMinutes(saResult.duration)) 
                                                             )
                                                            ];
            
            List<ResourceAbsence> overlappingResourceAbsence = [SELECT Id FROM ResourceAbsence
                                                                WHERE ResourceId = :saResult.resourceId
                                                                AND (
                                                                    (Start >= :saResult.startTime AND Start < :saResult.starttime.addMinutes(saResult.duration))
                                                                    OR (End > :saResult.startTime AND End <= :saResult.starttime.addMinutes(saResult.duration)) 
                                                                    OR (Start <= :saResult.startTime AND End >= :saResult.starttime.addMinutes(saResult.duration))
                                                                    OR (Start >= :saResult.startTime AND End <= :saResult.starttime.addMinutes(saResult.duration)) 
                                                                )                                                                                                          
                                                               ];
            
            ServiceAppointment sa = new ServiceAppointment();
            //Response response = new Response();
            if(overlappingAppointment.size() == 0 && overlappingResourceAbsence.size() == 0){
                
                
                System.debug('rrNr: ' + saResult.rrNr);
                List<Account> accounts =  [SELECT Id FROM Account WHERE Patient_Insurance_ID__pc = :saResult.rrNr LIMIT 1];
                System.debug('accounts: ' + accounts);
                if(accounts <> null && accounts.size() > 0  && saResult.rrNr <> '') {
                    sa.ParentRecordId = accounts[0].Id;
                } else {
                    sa.ParentRecordId = saResult.leadid;
                }
                sa.Lead__c = saResult.leadid;
                sa.ServiceTerritoryId = saResult.locationId;
                sa.Status = 'Scheduled';
                sa.DurationType = 'Minutes';
                sa.SchedStartTime = saResult.startTime;
                sa.EarliestStartTime = saResult.startTime;
                sa.SchedEndTime = saResult.starttime.addMinutes(saResult.duration);
                sa.DueDate = saResult.starttime.addMinutes(saResult.duration);
                sa.workTypeId = saResult.workTypeId;
                sa.Description = saResult.description;
                sa.Email = saResult.email;
                
                List<Group> g = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND Name = 'VIGO Service Appointments' LIMIT 1];
                sa.OwnerId = g[0].Id;
                
                Database.insert(sa, true);
                
                AssignedResource asrec = new AssignedResource();
                asrec.ServiceAppointmentId = sa.Id;
                asrec.ServiceResourceId = saResult.resourceId;
                asrec.IsPrimaryResource = true;
                asrec.IsRequiredResource = true;
                Database.insert(asrec, true);
            } 
            
            
            List<ServiceAppointment> saList = new List<ServiceAppointment>([SELECT Id, AppointmentNumber FROM ServiceAppointment WHERE Id = :sa.Id]);
            
            CreatedSA csa = new CreatedSA();
            if(saList.size() > 0) {
                csa.saId = saList[0].Id;
                csa.saName = saList[0].AppointmentNumber ;
                csa.doubleBooked = false;
            } else {
                csa.doubleBooked = true;
            }
            
            return JSON.serializePretty(csa);
            
            
            
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }

    @AuraEnabled(cacheable=false)
    public static String updateServiceAppointmentObject(String serviceappointment) {
        try {
            ResponseSAUpdate saResult = (ResponseSAUpdate)JSON.deserialize(serviceappointment, ResponseSAUpdate.class);
            System.debug(saResult);
            
                ServiceAppointment sa = new ServiceAppointment();
            
            if(saResult.startTime <> null) {
                
                TimeZone tz = Timezone.getTimeZone('Europe/Brussels');
                Integer milliSeconds = tz.getOffset(saResult.startTime);
                Integer minutes = milliSeconds / 60000;
                Integer offSetHours = minutes / 60;
                saResult.startTime = saResult.startTime.addHours(-1*offSetHours);
                
                sa.Id = saResult.saId;
                sa.SchedStartTime = saResult.startTime;
                sa.EarliestStartTime = saResult.startTime;
                sa.SchedEndTime = saResult.starttime.addMinutes(saResult.duration);
                sa.DueDate = saResult.starttime.addMinutes(saResult.duration);
                
                Database.update(sa, true);
            }
            
            if(saResult.resourceId <> null) {
                
                AssignedResource asrec = new AssignedResource();
                asrec.Id = saResult.AssignedResourceId;
                asrec.ServiceResourceId = saResult.resourceId;
                Database.update(asrec, true);
            
            }
            
            return sa.Id;
            
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }

    @AuraEnabled(cacheable=false)
    public static String cancelServiceAppointmentObject(String serviceappointment) {
        try {
            ResponseSACancel saResult = (ResponseSACancel)JSON.deserialize(serviceappointment, ResponseSACancel.class);
            System.debug(saResult);
            
            ServiceAppointment sa = new ServiceAppointment();
            sa.Id = saResult.saId;
            sa.Cancellation_Reason__c = saResult.cancelPicklist;
            sa.CancellationReason = saResult.cancelText;
            sa.Cancellation_Reason__c = saResult.cancelPicklist;
            sa.Status = 'Canceled';
            Database.update(sa, true);
            
            return sa.Id;
            
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    public class CreatedSA {
        @AuraEnabled
         public Id saId;
        @AuraEnabled
         public String saName;
        @AuraEnabled
         public Boolean doubleBooked;
    }
    
    public class ResponseSA {
         
         @AuraEnabled
         public Id leadid;
         @AuraEnabled
         public Id locationId;
         @AuraEnabled
         public Datetime startTime;
         @AuraEnabled
         public Integer duration;
         @AuraEnabled
         public Id resourceId;
         @AuraEnabled
         public Id workTypeId;
         @AuraEnabled
         public String description;
         @AuraEnabled
         public String rrNr;
         @AuraEnabled
         public String email;
         
     }
    
    public class ResponseSAUpdate {
         
         @AuraEnabled
         public Id saId;
         @AuraEnabled
         public Datetime startTime;
         @AuraEnabled
         public Integer duration;
         @AuraEnabled
         public Id AssignedResourceId;
         @AuraEnabled
         public Id resourceId;
         
     }
    
    public class ResponseSACancel {
         
         @AuraEnabled
         public Id saId;
         @AuraEnabled
         public String cancelPicklist;
         @AuraEnabled
         public String cancelText;
         
     }
    
}