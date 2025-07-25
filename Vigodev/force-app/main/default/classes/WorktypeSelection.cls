public class WorktypeSelection {
    
    public WorktypeSelection () { }
    
    @AuraEnabled(cacheable=true) 
    public static List<BusinessUnit> getBusinessUnit() {
        
        try {
            List<WorkTypeGroup> typologies = new List<WorkTypeGroup>([
                SELECT Id, IsActive, Name, Business_Unit_Lookup__c, Appointment_Type_Lookup__c, Product_Group_Lookup__c, Product_Sub_Group_Lookup__c
                FROM WorkTypeGroup 
                WHERE IsActive = TRUE AND Visible_on_website__c = TRUE
            ]);
            
            Map<Id, Work_Type_Typology__c> typologyMap = new Map<Id, Work_Type_Typology__c>();
            typologyMap.putAll(new List<Work_Type_Typology__c>([SELECT Id, Name, Image_Developer_Name__c, 
                                                                Guiding_Text_EN__c, Guiding_Text_NL__c, Guiding_Text_FR__c, 
                                                                Image_Link__c, Typology_Name_NL__c, Typology_Name_FR__c            
                                                                FROM Work_Type_Typology__c]));
            
            //Map BUSINESS UNIT + all worktypes
            Map<Id, List<WorkTypeGroup>> buMap = new Map<Id, List<WorkTypeGroup>>();
            List<BusinessUnit> buList = new List<BusinessUnit>();
            for(WorkTypeGroup wtg : typologies) {
                if(!buMap.containsKey(wtg.Business_Unit_Lookup__c)) {
                    buMap.put(wtg.Business_Unit_Lookup__c, new List<WorkTypeGroup>());
                }
                buMap.get(wtg.Business_Unit_Lookup__c).add(wtg);
            }
            
            //Map BUSINESS UNIT + Map PRODUCT GROUP + all worktypes
            for(Id id2 : buMap.keySet()) {        
                
                Map<Id, List<WorkTypeGroup>> pgMap = new Map<Id, List<WorkTypeGroup>>();
                List<ProductGroup> pgList = new List<ProductGroup>();
                for(WorkTypeGroup wtg2 : buMap.get(id2)) {
                    if(!pgMap.containsKey(wtg2.Product_Group_Lookup__c)) {
                        pgMap.put(wtg2.Product_Group_Lookup__c, new List<WorkTypeGroup>());
                    }
                    pgMap.get(wtg2.Product_Group_Lookup__c).add(wtg2);
                }            
                
                //Map BUSINESS UNIT + Map PRODUCT GROUP + Map PRODUCT SUB-GROUP + all worktypes
                for(Id id3 : pgMap.keySet()) {            
                    Map<Id, List<WorkTypeGroup>> psgMap = new Map<Id, List<WorkTypeGroup>>();
                    List<ProductSubGroup> psgList = new List<ProductSubGroup>();
                    for(WorkTypeGroup wtg3 : pgMap.get(id3)) {
                        if(!psgMap.containsKey(wtg3.Product_Sub_Group_Lookup__c)) {
                            psgMap.put(wtg3.Product_Sub_Group_Lookup__c, new List<WorkTypeGroup>());
                        }
                        psgMap.get(wtg3.Product_Sub_Group_Lookup__c).add(wtg3);
                    }
                    
                    //Map BUSINESS UNIT + Map PRODUCT GROUP + Map PRODUCT SUB-GROUP + Map APPOINTMENT TYPE + all worktypes
                    for(Id id4 : psgMap.keySet()) {
                        List<WorkType2> atList = new List<WorkType2>();
                        for(WorkTypeGroup wtg4 : psgMap.get(id4)) {
                            
                            if(wtg4.Appointment_Type_Lookup__c <> null){
                                Work_Type_Typology__c typ = typologyMap.get(wtg4.Appointment_Type_Lookup__c);
                                WorkType2 at = new WorkType2(typ.Guiding_Text_EN__c, typ.Guiding_Text_FR__c, typ.Guiding_Text_NL__c, 
                                                             typ.Image_Link__c, typ.Image_Developer_Name__c, typ.Name, typ.Typology_Name_FR__c, typ.Typology_Name_NL__c, typ.id);
                                atList.add(at); 
                            }
                            
                        }
                        
                        if(id4 <> null) {
                            Work_Type_Typology__c typ = typologyMap.get(id4);
                            WorkType2 psg = new WorkType2(typ.Guiding_Text_EN__c, typ.Guiding_Text_FR__c, typ.Guiding_Text_NL__c, 
                                                          typ.Image_Link__c, typ.Image_Developer_Name__c, typ.Name, typ.Typology_Name_FR__c, typ.Typology_Name_NL__c, typ.id);
                            ProductSubGroup item = new ProductSubGroup(psg, atList);
                            psgList.add(new ProductSubGroup (psg, atList)); 
                        }
                        
                    }
                    
                    if(id3 <> null) {
                        Work_Type_Typology__c typ = typologyMap.get(id3);
                        WorkType2 pg = new WorkType2(typ.Guiding_Text_EN__c, typ.Guiding_Text_FR__c, typ.Guiding_Text_NL__c, 
                                                     typ.Image_Link__c, typ.Image_Developer_Name__c, typ.Name, typ.Typology_Name_FR__c, typ.Typology_Name_NL__c, typ.id);
                        pgList.add(new ProductGroup (pg, psgList));     
                    }
                    
                }
                
                if(id2 <> null) {
                    Work_Type_Typology__c typ = typologyMap.get(id2);
                    WorkType2 bu = new WorkType2(typ.Guiding_Text_EN__c, typ.Guiding_Text_FR__c, typ.Guiding_Text_NL__c, 
                                                 typ.Image_Link__c, typ.Image_Developer_Name__c, typ.Name, typ.Typology_Name_FR__c, typ.Typology_Name_NL__c, typ.id);
                    buList.add(new BusinessUnit (bu, pgList));
                }
            }
            
            return buList;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true) 
    public static String getJSON() {        
        try {
            String JSONstring = JSON.serializePretty(getBusinessUnit());
            return JSONString;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getWorkType(Id BusinessUnitId, Id ProductGroupId, Id ProductSubGroupId, Id AppointmentId) {

        try {
            String JSONstring = JSON.serializePretty(getFullWorkType(BusinessUnitId, ProductGroupId, ProductSubGroupId, AppointmentId));
            return JSONString;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }    
    
    @AuraEnabled(cacheable=true)
    public static FullWorkType getFullWorkType(Id BusinessUnitId, Id ProductGroupId, Id ProductSubGroupId, Id AppointmentId) {
        
        try {
            List<WorkTypeGroupMember> wtgroupmember = new List<WorkTypeGroupMember>([SELECT Id, WorkTypeId, WorkTypeGroupId, WorkTypeGroup.Bookable_on_website__c,
                                                                                     WorkType.Work_Type_Name_FR__c, WorkType.EstimatedDuration, WorkType.Name,
                                                                                     WorkTypeGroup.Appointment_Type_Translation__c, WorkTypeGroup.Appointment_Type_Translation_FR__c,
                                                                                     WorkTypeGroup.Product_Subgroup_Translation__c, WorkTypeGroup.Product_Subgroup_Translation_FR__c
                                                                                     FROM WorkTypeGroupMember
                                                                                     WHERE WorkTypeGroup.Appointment_Type_Lookup__c = :AppointmentId
                                                                                     AND WorkTypeGroup.Business_Unit_Lookup__c = :BusinessUnitId
                                                                                     AND WorkTypeGroup.Product_Group_Lookup__c = :ProductGroupId
                                                                                     AND WorkTypeGroup.Product_Sub_Group_Lookup__c = :ProductSubGroupId
                                                                                     AND WorkTypeGroup.isActive = TRUE
                                                                                     AND WorkTypeGroup.Visible_on_website__c = TRUE]);
            FullWorkType fullwt;        
            if(wtGroupMember.size() > 0) 
                fullwt = new FullWorkType (wtgroupmember[0].WorkType.Name, wtgroupmember[0].WorkType.Work_Type_Name_FR__c, 
                                           wtgroupmember[0].WorkType.EstimatedDuration, wtgroupmember[0].WorkTypeId, wtgroupmember[0].WorkTypeGroup.Bookable_on_website__c,
                                           wtgroupmember[0].WorkTypeGroup.Appointment_Type_Translation__c, wtgroupmember[0].WorkTypeGroup.Appointment_Type_Translation_FR__c,
                                           wtgroupmember[0].WorkTypeGroup.Product_Subgroup_Translation__c, wtgroupmember[0].WorkTypeGroup.Product_Subgroup_Translation_FR__c);
            return fullwt;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getLocations(Id WorkTypeId) {
        try {
            String JSONstring = JSON.serializePretty(getLocationList(WorkTypeId));
            return JSONString;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FullAddress> getLocationList(Id WorkTypeId) {
        try {
            List<ServiceTerritoryWorkType> territories = new List<ServiceTerritoryWorkType>([SELECT Id, ServiceTerritoryId, ServiceTerritory.Name, ServiceTerritory.Address
                                                                                             FROM ServiceTerritoryWorkType 
                                                                                             WHERE WorkTypeId = :WorkTypeId
                                                                                             ORDER BY ServiceTerritory.Name DESC]);
            List<FullAddress> addressList = new List<FullAddress>();        
            if(territories.size() > 0) {
                for(ServiceTerritoryWorkType terr : territories) {
                    FullAddress fullad = new FullAddress (terr.ServiceTerritoryId, terr.ServiceTerritory.Name, terr.ServiceTerritory.Address);
                    addressList.add(fullad);
                }
            }
            
            return addressList;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getPossibleTimeslot(Date selectedDate, Id locatonId, Id workTypeId ) {
        
        try {
            String JSONstring = JSON.serializePretty(getAvailableSlots(selectedDate, locatonId, workTypeId));
            System.debug(JSONstring);
            return JSONString;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AvailableSlot> getAvailableSlots(Date selectedDate, Id locatonId, Id workTypeId ) {
        
        try {
            //Get policy
            List <AppointmentSchedulingPolicy> policyId = [SELECT Id FROM AppointmentSchedulingPolicy WHERE MasterLabel ='VIGO Scheduling Policy' LIMIT 1];
            
            //Build WorkType
            lxscheduler.WorkType workType = new lxscheduler.WorkTypeBuilder()
                .setId(workTypeId)
                .build();
            
            //getAppointmentCandidates        
            Datetime startdatetime = DateTime.newInstance(selectedDate, Time.newInstance(0, 0, 0, 0));
            lxscheduler.GetAppointmentCandidatesInput input = new lxscheduler.GetAppointmentCandidatesInputBuilder()
                .setWorkType(workType)
                .setTerritoryIds(new List<String>{locatonId})
                .setStartTime(startdatetime.format('yyyy-MM-dd\'T\'HH:mm:ssZ'))
                .setEndTime(startdatetime.addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ssZ'))
                //  .setAccountId('001RM0000053iQgYAI')
                .setSchedulingPolicyId(policyId[0].Id)
                .setApiVersion(Double.valueOf('59.0'))
                .build();
            
            String response = lxscheduler.SchedulerResources.getAppointmentCandidates(input);
            System.debug(response);
            
            if(response <> null) {
                List<ResponseWrapper> wrapperResult = (List<ResponseWrapper>)JSON.deserialize(response, List<ResponseWrapper>.class);
                System.debug(wrapperResult);
                
                SkillRequirement skillreq = [SELECT SkillId FROM SkillRequirement WHERE RelatedRecordId = :workTypeId LIMIT 1];
                Id skillId = skillreq?.Skillid;
                
                Map<Id, List<DateTime>> resultMap = new Map<Id, List<DateTime>>();
                Set<Id> resourceList = new Set<Id>();
                for (ResponseWrapper wrapper : wrapperResult) {
                    
                    List<String> dateList = wrapper.startTime.split('T');
                    DateTime slot = Datetime.newInstanceGMT(Integer.valueOf(dateList[0].split('-')[0]), Integer.valueOf(dateList[0].split('-')[1]), Integer.valueOf(dateList[0].split('-')[2]), Integer.valueOf(dateList[1].split(':')[0]), Integer.valueOf(dateList[1].split(':')[1]), 0);
                    TimeZone tz = Timezone.getTimeZone('Europe/Brussels');
                    Integer milliSeconds = tz.getOffset(slot);
                    Integer minutes = milliSeconds / 60000;
                    Integer offSetHours = minutes / 60;
                    slot = slot.addHours(offSetHours);
                    
                    for (Id resourceId : wrapper.resources) {         
                        String keyname = string.valueOf(resourceId);
                        if(!resultMap.containsKey(keyname)){
                            resultMap.put(keyname, new List<DateTime>());
                        }
                        resultMap.get(keyname).add(slot);
                        resourceList.add(resourceId);
                    }
                    
                }
                
                List<AvailableSlot> fullSlots = new List<AvailableSlot>();
                // Map<Id, ServiceResource> resourceMap = new Map<Id, ServiceResource>([SELECT Id, Name, RelatedRecord.FirstName, RelatedRecord.LastName FROM ServiceResource WHERE Id IN :resourceList]);
                List<ServiceResourceSkill> resourceSkillList = [SELECT ServiceResourceId, ServiceResource.Name, ServiceResource.RelatedRecord.FirstName, ServiceResource.RelatedRecord.LastName, Service_Resource_Sort_Order__c 
                                                                FROM ServiceResourceSkill 
                                                                WHERE ServiceResourceId IN :resourceList AND Service_Resource_Sort_Order__c > 50 AND SkillId = :skillId
                                                                ORDER BY Service_Resource_Sort_Order__c DESC, ServiceResource.Name ASC];
                Map<Id, ServiceResourceSkill> resourceSkillMap = new Map<Id, ServiceResourceSkill>();
                for(ServiceResourceSkill srs : resourceSkillList) {
                    resourceSkillMap.put(srs.ServiceResourceId, srs);
                }
                
                for(Id resourceId : resourceSkillMap.keySet()) {
                    System.debug(resourceSkillMap.get(resourceId).ServiceResource.RelatedRecord.FirstName + ' - ' + resourceSkillMap.get(resourceId).Service_Resource_Sort_Order__c);
                    List<DateTime> slots = resultMap.get(resourceId);
                    if(slots <> null && slots.size() > 0) {
                        ServiceResource2 sr = new ServiceResource2(resourceId, resourceSkillMap.get(resourceId).ServiceResource.RelatedRecord.FirstName 
                                                                   + ' ' + resourceSkillMap.get(resourceId).ServiceResource.RelatedRecord.LastName.left(1) );
                        AvailableSlot av = new AvailableSlot(sr, slots);
                        fullSlots.add(av);
                    }
                }
                
                return fullSlots;
            }
            return null;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String saveLeadObject(String lead) {
        
        try {
            ResponseLead leadResult = (ResponseLead)JSON.deserialize(lead, ResponseLead.class);
            System.debug(leadResult);
            
            Lead l = new Lead();
            l.firstName = leadResult.firstName;
            l.LastName = leadResult.lastName;
            l.email = leadResult.email;
            l.Phone = leadResult.phone;
            
            l.No_Medical_Record_Number__c = leadResult.hasNoRSZ;
            l.HealthCloudGA__BirthDate__c = leadResult.birthdate;
            if(!leadResult.hasNoRSZ) {
                l.HealthCloudGA__MedicalRecordNumber__c = leadResult.RSZ;
            }
            
            l.Street = leadResult.street;   
            l.city = leadResult.city;
            l.PostalCode = leadResult.postalcode;
            l.country = leadResult.country;
            
            l.On_behalf_of_someone_else__c = !leadResult.bookedForSelf;    
            if(!leadResult.bookedForSelf) {
                l.Relationship_Type__c = leadResult.relationToPatient;
                l.First_Name_Relationship__c = leadResult.bookedForFirstName;
                l.Last_Name_Relationship__c = leadResult.bookedForLastName;
                l.email = leadResult.bookedForEmail;
                l.Phone = leadResult.bookedForPhone;
            }             
            
            l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vigo Lead').getRecordTypeId();
            l.OBA__c = '90463';
            
            List<Group> g = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND Name = 'VIGO Leads' LIMIT 1];
            l.OwnerId = g[0].Id;
            
            Database.insert(l, true);
            return l.id;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
        
    @AuraEnabled(cacheable=false)
    public static String saveLead(String firstName, String lastName, String email, string phone, 
                                  string rrNr, Boolean noRrNr, Date endUserBirthdate,
                                  String street, String postalcode, String city, String country,
                                  Boolean onBehalveOf, String relationship, String yourFirstName, String yourLastName, String yourEmail, String yourPhone) {
        try {
            Lead l = new Lead();
            l.firstName = FirstName;
            l.LastName = LastName;
            l.email = email;
            l.Phone = phone;
                                          
            l.No_Medical_Record_Number__c = noRrNr;
            l.HealthCloudGA__BirthDate__c = endUserBirthdate;
            if(!noRrNr) {
                l.HealthCloudGA__MedicalRecordNumber__c = rrNr;
            }
                
            l.Street = street;   
            l.city = city;
            l.PostalCode = postalcode;
            l.country = country;
                                
            l.On_behalf_of_someone_else__c = onBehalveOf;    
            if(onBehalveOf) {
                l.Relationship_Type__c = relationship;
                l.First_Name_Relationship__c = yourFirstName;
                l.Last_Name_Relationship__c = yourLastName;
                l.email = yourEmail;
                l.Phone = yourPhone;
            }
            
            l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vigo Lead').getRecordTypeId();
            l.OBA__c = '90463';
            
            List<Group> g = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND Name = 'VIGO Leads' LIMIT 1];
            l.OwnerId = g[0].Id;
            
            Database.insert(l, true);
            return l.id;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String saveTask(Id leadid, String worktypeName, String dagdeel, String dagen, Boolean voorschrift, String opmerkingen, String serviceTerritoryName, String rrNr) {
        try {
            Task t = new Task();
            
            t.Description = 'Worktype: ' + worktypeName
                +'\r\n \r\n'
                + 'Preferred day: ' + dagen
                +'\r\n \r\n'
                + 'Preferred part of day: ' + dagdeel
                +'\r\n \r\n'
                + 'I have a prescription: ' + voorschrift
                +'\r\n \r\n'
                + 'Remarks: ' + opmerkingen;
            
            List<Group> g = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND Name = :serviceTerritoryName LIMIT 1];
            if(g.size() > 0) {
                t.OwnerId = g[0].Id;
            } 
            
            List<Contact> contacts =  [SELECT Id FROM Contact WHERE Patient_Insurance_ID__c = :rrNr LIMIT 1];
            if(contacts <> null && contacts.size() > 0 && rrNr <> '') {
                t.WhoId = contacts[0].Id;
            } else {
                t.WhoId = leadid;
            }
            
            
            t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Vigo Task').getRecordTypeId();
            t.Subject = 'Bellen voor afspraak';
            t.Type = 'Appointment Request';
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            
            Database.insert(t, true);
            return t.Id;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String saveTaskObject(String task) {
        try {
            
            ResponseTask taskResult = (ResponseTask)JSON.deserialize(task, ResponseTask.class);
            System.debug(taskResult);
            
            Task t = new Task();
            
            t.Description = 'Worktype: ' + taskResult.worktypeName
                +'\r\n \r\n'
                + 'Preferred day: ' + taskResult.dagen
                +'\r\n \r\n'
                + 'Preferred part of day: ' + taskResult.dagdeel
                +'\r\n \r\n'
                + 'I have a prescription: ' + taskResult.voorschrift
                +'\r\n \r\n'
                + 'Remarks: ' + taskResult.opmerkingen;
            
            List<Group> g = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND Name = :taskResult.serviceTerritoryName LIMIT 1];
            if(g.size() > 0) {
                t.OwnerId = g[0].Id;
            } 
            
            List<Contact> contacts =  [SELECT Id FROM Contact WHERE Patient_Insurance_ID__c = :taskResult.rrNr LIMIT 1];
            if(contacts <> null && contacts.size() > 0 && taskResult.rrNr <> '') {
                t.WhoId = contacts[0].Id;
            } else {
                t.WhoId = taskResult.leadid;
            }
            
            t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Vigo Task').getRecordTypeId();
            t.Subject = 'Bellen voor afspraak';
            t.Type = 'Appointment Request';
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            
            Database.insert(t, true);
            return t.Id;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
/*	########################################     INNER CLASSES	   ########################################*/
    
    public class BusinessUnit {
        
        @AuraEnabled
        public WorkType2 businessUnit {get; set;}
        @AuraEnabled
        public List<ProductGroup> productGroups {get; set;}
        
        public BusinessUnit (WorkType2 bu, List<ProductGroup> pgs) {
            businessUnit = bu;
            productGroups = pgs;
        }
        
    }
    
    public class ProductGroup {
        
        @AuraEnabled
        public WorkType2 productGroup {get; set;}
        @AuraEnabled
        public List<ProductSubGroup> productSubGroups {get; set;}
        
        public ProductGroup (WorkType2 pg, List<ProductSubGroup> psgs) {
            productGroup = pg;
            productSubGroups = psgs;
        }
        
    }
    
    public class ProductSubGroup {
        
        @AuraEnabled
        public WorkType2 productSubGroup {get; set;}
        @AuraEnabled
        public List<WorkType2> appointmentTypes {get; set;}
        
        public ProductSubGroup (WorkType2 psg, List<WorkType2> ats) {
            productSubGroup = psg;
            appointmentTypes = ats;
        }
        
    }
    
    public class WorkType2 {
        
        @AuraEnabled
        public String Guiding_Text_EN  {get; set;}
        @AuraEnabled
        public String Guiding_Text_FR  {get; set;}
        @AuraEnabled
        public String Guiding_Text_NL  {get; set;} 
        @AuraEnabled
        public Boolean Has_Image_Link  {get; set;}
		@AuraEnabled
        public String Image_Link       {get; set;}
        @AuraEnabled
        public String Image_Dev_Name   {get; set;}
        @AuraEnabled
        public String Typology_Name_EN {get; set;}
        @AuraEnabled
        public String Typology_Name_FR {get; set;}
        @AuraEnabled
        public String Typology_Name_NL {get; set;}
        @AuraEnabled
        public String recordId			{get; set;}
        
        public WorkType2 (String gtEN, String gtFR, String gtNL, String image, String dev_name, String tnEN, String tnFR, String tnNL, String id) {
            Guiding_Text_EN = (gtEN != null) ? gtEN.unescapeHtml4() : null;
            Guiding_Text_FR = (gtFR != null) ? gtFR.unescapeHtml4() : null;
            Guiding_Text_NL = (gtNL != null) ? gtNL.unescapeHtml4() : null;
            Has_Image_Link = !(String.isEmpty(image) || String.isBlank(image));
            Image_Link = image;       
            Image_Dev_Name = image != null? image.substringAfterLast('/') : null;
            Typology_Name_EN = tnEN;
            Typology_Name_FR = tnFR;
            Typology_Name_NL = tnNL;
            recordId = id;
        }
        
    }
    
    public class FullWorkType {
        
        @AuraEnabled
        public String WorkTypeName {get; set;}
        @AuraEnabled
        public String WorkTypeNameFR {get; set;}
        @AuraEnabled
        public Decimal EstimatedDuration {get; set;}
        @AuraEnabled
        public Id RecordId {get; set;}
        @AuraEnabled
        public Boolean Bookable {get; set;}
        @AuraEnabled
        public String AppTypeTranslation {get; set;}
        @AuraEnabled
        public String AppTypeTranslationFR {get; set;}
        @AuraEnabled
        public String ProdSubGroupTranslation {get; set;}
        @AuraEnabled
        public String ProdSubGroupTranslationFR {get; set;}
        
        public FullWorkType (String wtn, String wtnFR, Decimal ed, Id ri, Boolean b, String att, String attFR, String psgt, String psgtFR) {
            WorkTypeName = wtn;
            WorkTypeNameFR = wtnFR;
            EstimatedDuration = ed;
            RecordId = ri;
            Bookable = b;
            AppTypeTranslation = att;
            AppTypeTranslationFR = attFR;
            ProdSubGroupTranslation = psgt;
            ProdSubGroupTranslationFR = psgtFR;
        }
        
    }
    
    public class FullAddress {
        
        @AuraEnabled
        public String recordId {get; set;}
        @AuraEnabled
        public String recordName {get; set;}
        @AuraEnabled
        public System.Address recordAdress {get; set;}
        
        public FullAddress (Id addressId, String name, System.Address adres) {
            recordId = addressId;
            recordName = name;
            recordAdress = adres;
        }
        
    }
    
    public class ServiceResource2 {
        
        @AuraEnabled
        public String recordId {get; set;}
        @AuraEnabled
        public String recordName {get; set;}
        
        public ServiceResource2 (Id resourceId, String resourceName) {
            recordId = resourceId;
            recordName = resourceName;
        }
        
    }
    
    public class AvailableSlot {
        
        @AuraEnabled
        public ServiceResource2 resource {get; set;}
        @AuraEnabled
        public List<DateTime> slots {get; set;}
        
        public AvailableSlot (ServiceResource2 resourceRecord, List<DateTime> slotList) {
            resource = resourceRecord;
            slots = slotList;
        }
        
    }
    
    public class ResponseWrapper {
        
        @AuraEnabled
        public String startTime;
        @AuraEnabled
        public String endTime;
        @AuraEnabled
        public List<Id> resources;
        @AuraEnabled
        public Id territoryId;
        
    }
    
    public class ResponseLead {
        
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public String RSZ;
        @AuraEnabled
        public Boolean hasNoRSZ;
        @AuraEnabled
        public String street;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String postalCode;
        @AuraEnabled
        public Date birthdate;
        @AuraEnabled
        public Boolean bookedForSelf;
        @AuraEnabled
        public String bookedForFirstName;
        @AuraEnabled
        public String bookedForLastName;
        @AuraEnabled
        public String bookedForEmail;
        @AuraEnabled
        public String bookedForPhone;
        @AuraEnabled
        public String relationToPatient;
        
    }
    
    public class responseTask {
        
        @AuraEnabled
        public Id leadid;
        @AuraEnabled
        public String worktypeName;
        @AuraEnabled
        public String dagdeel;
        @AuraEnabled
        public String dagen;
        @AuraEnabled
        public String voorschrift;
        @AuraEnabled
        public String opmerkingen;
        @AuraEnabled
        public String serviceTerritoryName;
        @AuraEnabled
        public String rrNr;
        
    }
    
}