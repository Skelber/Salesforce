public class WorktypeSelection {
    
    public WorktypeSelection () { }
    
    @AuraEnabled(cacheable=true) 
    public static String getJSON() {
        
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
      System.debug(typologies);
        System.debug(typologyMap);
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
        
        String JSONstring = JSON.serializePretty(buList);
        return JSONString;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getWorkType(Id BusinessUnitId, Id ProductGroupId, Id ProductSubGroupId, Id AppointmentId) {
        
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
        
        String JSONstring = JSON.serializePretty(fullwt);
        return JSONString;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getLocations(Id WorkTypeId) {
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
            
        String JSONstring = JSON.serializePretty(addressList);
        return JSONString;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getPossibleTimeslot(Date selectedDate, Id locatonId, Id workTypeId ) {
        
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
            Id skillId = skillreq <> null ? skillreq.SkillId : null;
            
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
            
            String JSONstring = JSON.serializePretty(fullSlots);
            System.debug(JSONstring);
            return JSONString;
        }
        return null;
    }
        
    @AuraEnabled(cacheable=false)
    public static String saveLead(String firstName, String lastName, String email, string phone, 
                                  string rrNr, Boolean noRrNr, Date endUserBirthdate,
                                  String street, String postalcode, String city, String country,
                                  Boolean onBehalveOf, String relationship, String yourFirstName, String yourLastName, String yourEmail, String yourPhone) {
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

        Database.insert(l, true);
        return l.id;
    }
    
    @AuraEnabled(cacheable=false)
    public static String saveTask(Id leadid, String worktypeName, String dagdeel, String dagen, Boolean voorschrift, String opmerkingen, String serviceTerritoryName, String rrNr) {
        Task t = new Task();
        
        t.Description = 'Gekozen werktype: ' + worktypeName
            				+'\r\n \r\n'
            				+ 'Voorkeur dag: ' + dagen
            				+'\r\n \r\n'
            				+ 'Voorkeur dagdeel: ' + dagdeel
            				+'\r\n \r\n'
            				+ 'Ik heb een voorschrift: ' + voorschrift
            				+'\r\n \r\n'
            				+ 'Opmerkingen: ' + opmerkingen;
        
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
    }
    
/*	########################################     INNER CLASSES	   ########################################*/
    
    private class BusinessUnit {
        
        private WorkType2 businessUnit {get; set;}
        private List<ProductGroup> productGroups {get; set;}
        
        private BusinessUnit (WorkType2 bu, List<ProductGroup> pgs) {
            businessUnit = bu;
            productGroups = pgs;
        }
        
    }
    
    private class ProductGroup {
        
        private WorkType2 productGroup {get; set;}
        private List<ProductSubGroup> productSubGroups {get; set;}
        
        private ProductGroup (WorkType2 pg, List<ProductSubGroup> psgs) {
            productGroup = pg;
            productSubGroups = psgs;
        }
        
    }
    
    private class ProductSubGroup {
        
        private WorkType2 productSubGroup {get; set;}
        private List<WorkType2> appointmentTypes {get; set;}
        
        private ProductSubGroup (WorkType2 psg, List<WorkType2> ats) {
            productSubGroup = psg;
            appointmentTypes = ats;
        }
        
    }
    
    private class WorkType2 {
        
        private String Guiding_Text_EN  {get; set;}
        private String Guiding_Text_FR  {get; set;}
        private String Guiding_Text_NL  {get; set;} 
        private Boolean Has_Image_Link  {get; set;}
        private String Image_Link       {get; set;}
        private String Image_Dev_Name   {get; set;}
        private String Typology_Name_EN {get; set;}
        private String Typology_Name_FR {get; set;}
        private String Typology_Name_NL {get; set;}
        private String recordId			{get; set;}
        
        private WorkType2 (String gtEN, String gtFR, String gtNL, String image, String dev_name, String tnEN, String tnFR, String tnNL, String id) {
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
    
    private class FullWorkType {
        
        private String WorkTypeName {get; set;}
        private String WorkTypeNameFR {get; set;}
        private Decimal EstimatedDuration {get; set;}
        private Id RecordId {get; set;}
        private Boolean Bookable {get; set;}
        private String AppTypeTranslation {get; set;}
        private String AppTypeTranslationFR {get; set;}
        private String ProdSubGroupTranslation {get; set;}
        private String ProdSubGroupTranslationFR {get; set;}
        
        private FullWorkType (String wtn, String wtnFR, Decimal ed, Id ri, Boolean b, String att, String attFR, String psgt, String psgtFR) {
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
    
    private class FullAddress {
        
        private String recordId {get; set;}
        private String recordName {get; set;}
        private System.Address recordAdress {get; set;}
        
        private FullAddress (Id addressId, String name, System.Address adres) {
            recordId = addressId;
            recordName = name;
            recordAdress = adres;
        }
        
    }
    
    private class ServiceResource2 {
        
        private String recordId {get; set;}
        private String recordName {get; set;}
        
        private ServiceResource2 (Id resourceId, String resourceName) {
            recordId = resourceId;
            recordName = resourceName;
        }
        
    }
    
    private class AvailableSlot {
        
        private ServiceResource2 resource {get; set;}
        private List<DateTime> slots {get; set;}
        
        private AvailableSlot (ServiceResource2 resourceRecord, List<DateTime> slotList) {
            resource = resourceRecord;
            slots = slotList;
        }
        
    }
    
    public class ResponseWrapper {
        
        public String startTime;
        public String endTime;
        public List<Id> resources;
        public Id territoryId;
        
    }
    
}