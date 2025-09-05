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
                                                                                     WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_NL__c, 
                                                                                     WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_FR__c, 
                                                                                     WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_NL__c, 
                                                                                     WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_FR__c
//                                                                                     ,WorkTypeGroup.Appointment_Type_Translation__c, WorkTypeGroup.Appointment_Type_Translation_FR__c,
//                                                                                     WorkTypeGroup.Product_Subgroup_Translation__c, WorkTypeGroup.Product_Subgroup_Translation_FR__c
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
//                                           wtgroupmember[0].WorkTypeGroup.Appointment_Type_Translation__c, wtgroupmember[0].WorkTypeGroup.Appointment_Type_Translation_FR__c,
//                                           wtgroupmember[0].WorkTypeGroup.Product_Subgroup_Translation__c, wtgroupmember[0].WorkTypeGroup.Product_Subgroup_Translation_FR__c);
                                           wtgroupmember[0].WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_NL__c, wtgroupmember[0].WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_FR__c,
                                           wtgroupmember[0].WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_NL__c, wtgroupmember[0].WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_FR__c);
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
    public static List<AvailableSlot> getAvailableSlots(Date selectedDate, Id locatonId, Id workTypeId) {
        return getAvailableSlots2(selectedDate, locatonId, workTypeId, 1, null);
    }
        
    @AuraEnabled(cacheable=true)
    public static List<AvailableSlot> getAvailableSlots2(Date selectedDate, Id locatonId, Id workTypeId, Integer numberOfDays, Id fixedResourceId) {
        
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
                .setEndTime(startdatetime.addDays(numberOfDays).format('yyyy-MM-dd\'T\'HH:mm:ssZ'))
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
                    System.debug('wrapperResult: ' + wrapperResult);
                    List<String> dateList = wrapper.startTime.split('T');
                    DateTime slot = Datetime.newInstanceGMT(Integer.valueOf(dateList[0].split('-')[0]), Integer.valueOf(dateList[0].split('-')[1]), Integer.valueOf(dateList[0].split('-')[2]), Integer.valueOf(dateList[1].split(':')[0]), Integer.valueOf(dateList[1].split(':')[1]), 0);
                    TimeZone tz = Timezone.getTimeZone('Europe/Brussels');
                    Integer milliSeconds = tz.getOffset(slot);
                    Integer minutes = milliSeconds / 60000;
                    Integer offSetHours = minutes / 60;
                    slot = slot.addHours(offSetHours);
                    
                    for (Id resourceId : wrapper.resources) {     
                        if(fixedResourceId == null || fixedResourceId == resourceId) {
                            String keyname = string.valueOf(resourceId);
                            if(!resultMap.containsKey(keyname)){
                                resultMap.put(keyname, new List<DateTime>());
                            }
                            resultMap.get(keyname).add(slot);
                            resourceList.add(resourceId);
                        }
                    }
                    
                }
                
                List<AvailableSlot> fullSlots = new List<AvailableSlot>();
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
                        System.debug('Available Slot: ' + av);
                        fullSlots.add(av);
                    }
                }
                System.debug(fullSlots);
                return fullSlots;
            }
            return null;
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    @auraEnabled(cacheable=true)
    public static AllInformation getAllInformation(String parentId, String SAId) {
        
        try{
            AllInformation allInfo = new AllInformation();
            
            List<ServiceAppointment> saList = [SELECT Id, SchedStartTime, ServiceTerritoryId, ServiceTerritory.Name, ServiceTerritory.Address,
                                               workTypeId, workType.Name, Description, Lead__c, Lead__r.FirstName, Lead__r.LastName, 
                                               Lead__r.Email, Lead__r.Phone, Lead__r.First_Name_Relationship__c, Lead__r.Last_Name_Relationship__c, 
                                               Lead__r.Relationship_Type__c, AccountId, Account.FirstName, Account.LastName, Account.AccountEmail__c,
                                               Account.Phone, workType.EstimatedDuration, workType.Work_Type_Name_EN__c,
                                               Worktype.Work_Type_Name_FR__c
                                               FROM ServiceAppointment 
                                               WHERE Id = :SAId AND ParentRecordId = :parentId AND Status <> 'Canceled'];
            
            if(saList.size() > 0) {
                
                allInfo.noMatch = false;
                if(saList[0].SchedStartTime > System.now()) {
                    allInfo.matchInPast = false;
                    
                    if(saList[0].Lead__c <> null) {
                        allInfo.yourName = saList[0].Lead__r.FirstName + ' ' + saList[0].Lead__r.LastName;
                        allInfo.yourEmail = saList[0].Lead__r.Email;
                        allInfo.yourPhone = saList[0].Lead__r.Phone;
                        allInfo.bookedForName = saList[0].Lead__r.First_Name_Relationship__c + ' ' + saList[0].Lead__r.Last_Name_Relationship__c;
                        allInfo.Relation = saList[0].Lead__r.Relationship_Type__c;
                    } else if(saList[0].AccountId <> null) {
                        allInfo.yourName = saList[0].Account.FirstName + ' ' + saList[0].Account.LastName;
                        allInfo.yourEmail = saList[0].Account.AccountEmail__c;
                        allInfo.yourPhone = saList[0].Account.Phone;
                    }
                    
                    Location loc = new Location();
                    loc.locName = saList[0].ServiceTerritory.Name;
                    loc.locId = saList[0].ServiceTerritoryId;
                    loc.locAddress = saList[0].ServiceTerritory.Address;
                    allInfo.location = loc;
                    
                    List<WorkTypeGroupMember> wtgroupmember = new List<WorkTypeGroupMember>([SELECT Id,
                                                                                     WorkTypeGroup.Appointment_Type_Lookup__r.Name, 
                                                                                     WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_NL__c, 
                                                                                     WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_FR__c, 
                                                                                     WorkTypeGroup.Product_Sub_Group_Lookup__r.Name, 
                                                                                     WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_NL__c, 
                                                                                     WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_FR__c
                                                                                     FROM WorkTypeGroupMember
                                                                                     WHERE WorkTypeId = :saList[0].workTypeId]);
                    
                    Tool tool = new tool();
                    tool.toolId = saList[0].workTypeId;
                    tool.toolName = saList[0].workType.Name;
                    tool.toolNameEN = saList[0].workType.Work_Type_Name_EN__c;
                    tool.toolNameFR = saList[0].workType.Work_Type_Name_FR__c;
                    tool.toolAppName = wtgroupmember[0].WorkTypeGroup.Appointment_Type_Lookup__r.Name;
                    tool.toolAppNameFR = wtgroupmember[0].WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_NL__c;
                    tool.toolAppNameNL = wtgroupmember[0].WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_FR__c;
                    tool.toolSubGrName = wtgroupmember[0].WorkTypeGroup.Product_Sub_Group_Lookup__r.Name;
                    tool.toolSubGrNameFR = wtgroupmember[0].WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_NL__c;
                    tool.toolSubGrNameNL = wtgroupmember[0].WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_FR__c;
                    tool.EstimatedDuration = saList[0].workType.EstimatedDuration;
                    allInfo.tool = tool;
                    
                    AssignedResource res = [SELECT Id, ServiceResourceId, ServiceResource.Name FROM AssignedResource WHERE ServiceAppointmentId = :saId];
                    
                    TimeZone tz = Timezone.getTimeZone('Europe/Brussels');
                    Integer milliSeconds = tz.getOffset(saList[0].SchedStartTime);
                    Integer minutes = milliSeconds / 60000;
                    Integer offSetHours = minutes / 60;
                    
                    List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :SAId];
                    
                    AppointmentInfo appInfo = new AppointmentInfo();
                    appInfo.resourceName = res?.ServiceResource.Name;
                    appInfo.AssignedResourceId = res?.Id;
                    appInfo.resourceId = res?.ServiceResourceId;
                    appInfo.startTime = saList[0].SchedStartTime.addHours(offSetHours);
                    appInfo.remarks = saList[0].Description;
                    appInfo.attachments = links.size() > 0;
                    allInfo.appInfo = appInfo;
                    
                } else {
                    allInfo.matchInPast = true;
                }
            } else {
                allInfo.noMatch = true;
            }
            system.debug(allInfo);
            return allInfo;
            
        } catch (Exception e) {
            System.debug('Something went wrong: ' + e.getMessage());
            ApplicationLogger.logError(e, false);
            return null;
        }
    }
    
    @auraEnabled(cacheable=true)
    public static InviteInformation getInviteInformation(String AccountId, String OrderLineId, String ServiceResourceId, String ServiceLocationId, String Phase) {
        
        try {
            InviteInformation ii = new InviteInformation();
            
            //Check if ServiceResourceId is valid
            List<ServiceResource> resources = new List<ServiceResource>();
            if (ServiceResourceId <> null && ServiceResourceId <> '') {
                resources = [SELECT Id FROM ServiceResource WHERE Id = :ServiceResourceId];
                ii.validServiceResourceId = resources.size() > 0;
            } else {
                ii.validServiceResourceId = false;
            }
                        
            List<Sales_Document_Line_Item__c>  sdlitems = [ SELECT Id, Material_Number__c, Product_Category__c, Product_Subcategory__c, Product_Hierarchy__c, 
                                                           		   Sales_Document__r.Service_Location__c, Sales_Document__r.CPO_ServiceResource__c,
                                                                   Sales_Document__r.Patient__r.FirstName, Sales_Document__r.Patient__r.LastName, 
                                                                   Sales_Document__r.Patient__r.PersonEmail, Sales_Document__r.Patient__r.PersonMobilePhone
                                                              FROM Sales_Document_Line_Item__c
                                                             WHERE Id = :OrderLineId AND Sales_Document__r.Patient__c = :AccountId];

            if(sdlitems.size() > 0) {
                ii.firstName = sdlitems[0].Sales_Document__r.Patient__r.FirstName; 
                ii.lastName = sdlitems[0].Sales_Document__r.Patient__r.LastName;
                ii.email = sdlitems[0].Sales_Document__r.Patient__r.PersonEmail;
                ii.phone = sdlitems[0].Sales_Document__r.Patient__r.PersonMobilePhone;   
                            
                Id worktypeId;
                Id ServiceTerritoryId;
                
                Id ServiceTerritoryMappingID = Schema.SObjectType.Metadata__c.getRecordTypeInfosByName().get('ServiceTerritoryMapping').getRecordTypeId();
                Id WorkTypeMappingID = Schema.SObjectType.Metadata__c.getRecordTypeInfosByName().get('WorkTypeMapping').getRecordTypeId();
                
                List<Metadata__c> metadataList = new List<Metadata__c>([SELECT Id, Name, Material_Number__c, Product_Category__c , Product_Subcategory__c , Product_Hierarchy__c, Phase__c, 
                                                                        	   RecordTypeId, Service_Location__c, Service_Territory__c, Work_Type__c 
                                                                          FROM Metadata__c 
                                                                         WHERE RecordTypeId = :ServiceTerritoryMappingID OR
                                                                        		((Material_Number__c = :sdlitems[0].Material_Number__c OR Product_Category__c = :sdlitems[0].Product_Category__c
                                                                       			OR Product_Subcategory__c = :sdlitems[0].Product_Subcategory__c OR Product_Hierarchy__c = :sdlitems[0].Product_Hierarchy__c)
                                                                       			AND Phase__c = :phase)]);
                Map<Integer, List<Metadata__c >> wtmMap = new  Map<Integer, List<Metadata__c >>();
                wtmMap.put(1, new List<Metadata__c >());
                wtmMap.put(2, new List<Metadata__c >());
                wtmMap.put(3, new List<Metadata__c >());
                wtmMap.put(4, new List<Metadata__c >());
 
                for (Metadata__c no : metadataList) {
                    if(no.RecordTypeId == WorkTypeMappingID) {
                    	if(no.Material_Number__c  == sdlitems[0].Material_Number__c && no.Product_Category__c  == sdlitems[0].Product_Category__c
                    	   && no.Product_Subcategory__c  == sdlitems[0].Product_Subcategory__c && no.Product_Hierarchy__c  == sdlitems[0].Product_Hierarchy__c) {
                    	       wtmMap.get(4).add(no);
                    	} else 
                           if ((no.Material_Number__c  == sdlitems[0].Material_Number__c && no.Product_Category__c  == sdlitems[0].Product_Category__c
                       						&& (no.Product_Subcategory__c  == sdlitems[0].Product_Subcategory__c || no.Product_Hierarchy__c  == sdlitems[0].Product_Hierarchy__c)) 
                                  || ((no.Material_Number__c  == sdlitems[0].Material_Number__c || no.Product_Category__c  == sdlitems[0].Product_Category__c)
                       						&& no.Product_Subcategory__c  == sdlitems[0].Product_Subcategory__c && no.Product_Hierarchy__c  == sdlitems[0].Product_Hierarchy__c)) {
                           wtmMap.get(3).add(no);
                        } else
                           if ((no.Material_Number__c  == sdlitems[0].Material_Number__c && no.Product_Category__c  == sdlitems[0].Product_Category__c) 
                                  || (no.Material_Number__c  == sdlitems[0].Material_Number__c && no.Product_Subcategory__c  == sdlitems[0].Product_Subcategory__c)
                                  || (no.Material_Number__c  == sdlitems[0].Material_Number__c && no.Product_Hierarchy__c  == sdlitems[0].Product_Hierarchy__c)
                                  || (no.Product_Category__c  == sdlitems[0].Product_Category__c && no.Product_Subcategory__c  == sdlitems[0].Product_Subcategory__c)
                                  || (no.Product_Category__c  == sdlitems[0].Product_Category__c && no.Product_Hierarchy__c  == sdlitems[0].Product_Hierarchy__c)
                                  || (no.Product_Subcategory__c  == sdlitems[0].Product_Subcategory__c && no.Product_Hierarchy__c  == sdlitems[0].Product_Hierarchy__c) ) {
                           wtmMap.get(2).add(no);
                        } else
                           if (no.Material_Number__c  == sdlitems[0].Material_Number__c || no.Product_Category__c  == sdlitems[0].Product_Category__c
                                  || no.Product_Subcategory__c  == sdlitems[0].Product_Subcategory__c || no.Product_Hierarchy__c  == sdlitems[0].Product_Hierarchy__c) {
                           wtmMap.get(1).add(no);  
                        }
                    }
                    if(no.RecordTypeId == ServiceTerritoryMappingID && no.Service_Location__c == ServiceLocationId) {
                        ServiceTerritoryId = no.Service_Territory__c;
                    }
                }
                
                if(wtmMap.get(4).size() > 0) {
                    worktypeId = wtmMap.get(4)[0].Work_Type__c;
                } else if (wtmMap.get(3).size() > 0) {
                    worktypeId = wtmMap.get(3)[0].Work_Type__c;
                } else if (wtmMap.get(2).size() > 0) {
                    worktypeId = wtmMap.get(2)[0].Work_Type__c;
                } else if (wtmMap.get(1).size() > 0) {
                    worktypeId = wtmMap.get(1)[0].Work_Type__c;
                }   
                
                
                //Check if ServiceTerritoryId is valid
                List<ServiceTerritory> territories = new List<ServiceTerritory>();
                if (ServiceTerritoryId <> null) {
                    territories = [SELECT Id, Name, Address FROM ServiceTerritory WHERE Id = :ServiceTerritoryId];
                    ii.validServiceTerritoryId = territories.size() > 0;
                    if(territories.size() > 0) {
                        Location l = new Location();
                        l.locName = territories[0].Name;
                        l.locAddress = territories[0].Address;
                        l.locId = territories[0].Id;
                        ii.location = l;
                    }
                } else {
                    ii.validServiceTerritoryId = false;
                }
                
                List<WorkTypeGroupMember> wtgroupmember = new List<WorkTypeGroupMember>([SELECT Id, workTypeId, workType.Name, workType.Work_Type_Name_EN__c,
                                                                                         workType.Work_Type_Name_FR__c, workType.EstimatedDuration, 
                                                                                         WorkTypeGroup.Appointment_Type_Lookup__r.Name, 
                                                                                         WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_NL__c, 
                                                                                         WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_FR__c, 
                                                                                         WorkTypeGroup.Product_Sub_Group_Lookup__r.Name, 
                                                                                         WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_NL__c, 
                                                                                         WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_FR__c
                                                                                         FROM WorkTypeGroupMember
                                                                                         WHERE WorkTypeId = :workTypeId]);
                
                if(workTypeId <> null) {
                    Tool tool = new tool();
                    tool.toolId = wtgroupmember[0].workTypeId;
                    tool.toolName = wtgroupmember[0].workType.Name;
                    tool.toolNameEN = wtgroupmember[0].workType.Work_Type_Name_EN__c;
                    tool.toolNameFR = wtgroupmember[0].workType.Work_Type_Name_FR__c;
                    tool.toolAppName = wtgroupmember[0].WorkTypeGroup.Appointment_Type_Lookup__r.Name;
                    tool.toolAppNameFR = wtgroupmember[0].WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_NL__c;
                    tool.toolAppNameNL = wtgroupmember[0].WorkTypeGroup.Appointment_Type_Lookup__r.Typology_Name_FR__c;
                    tool.toolSubGrName = wtgroupmember[0].WorkTypeGroup.Product_Sub_Group_Lookup__r.Name;
                    tool.toolSubGrNameFR = wtgroupmember[0].WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_NL__c;
                    tool.toolSubGrNameNL = wtgroupmember[0].WorkTypeGroup.Product_Sub_Group_Lookup__r.Typology_Name_FR__c;
                    tool.EstimatedDuration = wtgroupmember[0].workType.EstimatedDuration;
                    ii.tool = tool;
                }
                            
            }
            
            System.debug('ii: ' + ii);
            return ii;
        
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
            l.HealthCloudGA__Language__c = leadResult.language;
            
            l.No_Medical_Record_Number__c = leadResult.hasNoRSZ;
            l.HealthCloudGA__BirthDate__c = leadResult.birthdate;
            if(!leadResult.hasNoRSZ) {
                l.HealthCloudGA__MedicalRecordNumber__c = leadResult.RSZ;
            }
            
            l.Street = leadResult.street;   
            l.city = leadResult.city;
            l.PostalCode = leadResult.postalcode;
            l.country = leadResult.country;
            
            l.On_behalf_of_someone_else__c = leadResult.bookedForSomeoneElse;    
            if(leadResult.bookedForSomeoneElse) {
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
            System.debug(l.HealthCloudGA__BirthDate__c);
            
            return l.id;
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
    
    public class InviteInformation {
        
        @AuraEnabled
        public Boolean validServiceResourceId {get;set;}
        @AuraEnabled
        public Boolean validServiceTerritoryId {get;set;}
        
        @AuraEnabled
        public string firstName {get;set;}
        @AuraEnabled
        public string lastName {get;set;}
        @AuraEnabled
        public string email {get;set;}
        @AuraEnabled
        public string phone {get;set;}
    
        @AuraEnabled
        public Location location {get;set;}
        
        @AuraEnabled
        public Tool tool {get;set;}
    }
    
    
    public class AllInformation {
        
        @AuraEnabled
        public Boolean noMatch {get;set;}
        @AuraEnabled
        public Boolean matchInPast {get;set;}        
        
        @AuraEnabled
        public string yourName {get;set;}
        @AuraEnabled
        public string yourEmail {get;set;}
        @AuraEnabled
        public string yourPhone {get;set;}
        @AuraEnabled
        public string bookedForName {get;set;}
        @AuraEnabled
        public string Relation {get;set;}
        @AuraEnabled
        public Location location {get;set;}
        @AuraEnabled
        public Tool tool {get;set;}
        @AuraEnabled
        public AppointmentInfo appInfo {get;set;}
    }
    
    public class Location {
        
        @AuraEnabled
        public String locName {get;set;}
        @AuraEnabled
        public System.Address locAddress {get;set;}
        @AuraEnabled
        public Id locId {get;set;}
        
    }
    
    public class Tool {
        
        @AuraEnabled
        public String toolName {get;set;}
        @AuraEnabled
        public String toolNameFR {get;set;}
        @AuraEnabled
        public String toolNameEN {get;set;}
        @AuraEnabled
        public String toolAppName {get;set;}
        @AuraEnabled
        public String toolAppNameFR {get;set;}
        @AuraEnabled
        public String toolAppNameNL {get;set;}
        @AuraEnabled
        public String toolSubGrName {get;set;}
        @AuraEnabled
        public String toolSubGrNameFR {get;set;}
        @AuraEnabled
        public String toolSubGrNameNL {get;set;}
        @AuraEnabled
        public Id toolId {get;set;}
        @AuraEnabled
        public Decimal EstimatedDuration {get;set;}
        
    }
    
    public class AppointmentInfo {
        
        @AuraEnabled
        public String resourceName {get;set;}
        @AuraEnabled
        public Id assignedResourceId {get;set;}
        @AuraEnabled
        public Id resourceId {get;set;}
        @AuraEnabled
        public DateTime startTime {get;set;}
        @AuraEnabled
        public String remarks {get;set;}
        @AuraEnabled
        public Boolean attachments {get;set;}
        
    }
    
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
        public Boolean bookedForSomeoneElse;
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
        @AuraEnabled
        public String language;
        
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