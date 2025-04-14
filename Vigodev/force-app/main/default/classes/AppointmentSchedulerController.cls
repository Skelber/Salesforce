// LLP-1573

public without sharing class AppointmentSchedulerController {

    @AuraEnabled
    public static ASWorkType getWorkType(String bu, String pg, String psg, String at){
       List <WorkTypeGroupMember> workTypeGroupMember = [SELECT Id, WorkTypeId, WorkType.EstimatedDuration, WorkTypeGroupId, WorkType.Name FROM WorkTypeGroupMember 
        WHERE WorkTypeGroup.Appointment_Type__c = :at AND 
        WorkTypeGroup.Business_Unit__c = :bu AND
        WorkTypeGroup.Product_Group__c = :pg AND
        WorkTypeGroup.Product_SubGroup__c = :psg
        LIMIT 1];

        ASWorkType worktype = new ASWorkType();
        worktype.id = workTypeGroupMember[0].workTypeId;
        worktype.duration = workTypeGroupMember[0].WorkType.EstimatedDuration;
        worktype.name = workTypeGroupMember[0].WorkType.Name;


        return workType;
    }

    @AuraEnabled 
    public static List<String> getServiceTerritoryIds (List<String> serviceResourceIds) {

        List<String> serviceTerritoryIds = new List<String>();
        List<ServiceTerritoryMember> stms = [SELECT Id, ServiceResourceId, ServiceTerritoryId FROM ServiceTerritoryMember WHERE ServiceResourceId IN :serviceResourceIds];

        for(ServiceTerritoryMember stm : stms) {
            serviceTerritoryIds.add(stm.ServiceTerritoryId);
        }

        Set<String> serviceTerritorySet = new Set<String>();
        serviceTerritorySet.addAll(serviceTerritoryIds);
        List<String>serviceTerritoryList = new List<String>();
        serviceTerritoryList.addAll(serviceTerritorySet);

        return serviceTerritoryList;
    }

    @AuraEnabled
    public static List<TerritoryEvent> getMultiResourceData( List<String> serviceResourceId, Id accountId, List<String> location, Id wt, String bu, String pg, String psg, String at, String dayValue, String TimeValue, Date currentDate, Integer duration){
    
        DateTime currentDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 0, 0, 0);

        List <WorkTypeGroupMember> workTypeGroupMember = [SELECT Id, WorkTypeId, WorkType.EstimatedDuration, WorkTypeGroupId FROM WorkTypeGroupMember 
        WHERE WorkTypeGroup.Appointment_Type__c = :at AND 
        WorkTypeGroup.Business_Unit__c = :bu AND
        WorkTypeGroup.Product_Group__c = :pg AND
        WorkTypeGroup.Product_SubGroup__c = :psg
        LIMIT 1];

        List <WorkTypeGroupMember> workTypeRecord = [SELECT Id,WorkTypeId,  WorkType.EstimatedDuration FROM WorkTypeGroupMember WHERE WorkTypeId = :wt LIMIT 1];
        String wtId = workTypeRecord[0].WorkTypeId;

        workType originalWorkType = [SELECT Id,EstimatedDuration FROM WorkType WHERE Id = :wtId LIMIT 1];
        Double originalDuration = originalWorkType.EstimatedDuration;

        if(duration != originalDuration) {
            originalWorkType.EstimatedDuration = duration;
            update originalWorkType;
        }

        List <AppointmentSchedulingPolicy> policyId = [SELECT Id FROM AppointmentSchedulingPolicy WHERE MasterLabel ='VIGO Scheduling Policy' LIMIT 1];
        
        lxscheduler.WorkType workType = new lxscheduler.WorkTypeBuilder()
        .setId(wt != null ? wt : workTypeGroupMember[0].WorkTypeId)
        .build();

        System.debug('location ' + location);

         lxscheduler.GetAppointmentSlotsInput mrInput = new lxscheduler.GetAppointmentSlotsInputBuilder()
            .setWorkType(workType)
            .setTerritoryIds(location)
            .setPrimaryResourceId(serviceResourceId[0])
            .setRequiredResourceIds(new List<String>{serviceResourceId[1]})
            .setAccountId(accountId)
            .setSchedulingPolicyId(policyId[0].Id)
            .setApiVersion(Double.valueOf('59.0'))
            .build();

            
            String mrResponse = lxscheduler.SchedulerResources.getAppointmentSlots(mrInput);
            System.debug(mrInput);
             List<ResponseWrapper> wrapperResult = (List<ResponseWrapper>)JSON.deserialize(mrResponse, List<ResponseWrapper>.class);

             System.debug('WrapperResultpretty ' + JSON.serialize(wrapperResult) );

             Set<Id> territoryIds = new Set<Id>();
                for (Integer i = 0; i < location.size(); i++) {
                    territoryIds.add(location[i]);
                }

                system.debug('territory size ' + territoryIds);
  
        Map<String, List <Result>> resultMap = new Map<String, List<Result>>();
        List<Result> results = new List<Result>();
        for (ResponseWrapper wrapper : wrapperResult) {

            Result res = new Result();

            List <String> dateList = wrapper.startTime.split('T');
            res.startTime = Datetime.newInstance(Integer.valueOf(dateList[0].split('-')[0]), Integer.valueOf(dateList[0].split('-')[1]), Integer.valueOf(dateList[0].split('-')[2]), Integer.valueOf(dateList[1].split(':')[0]), Integer.valueOf(dateList[1].split(':')[1]), 0);
            TimeZone tz = UserInfo.getTimeZone();
            Integer milliSeconds = tz.getOffset(res.startTime);
            Integer minutes = milliSeconds / 60000;
            Integer offSetHours = minutes / 60;
            res.startTime = res.startTime.addHours(offSetHours);
            // res.endTime = wt == null ? res.startTime.addMinutes(workTypeGroupMember[0].WorkType.EstimatedDuration.intValue()) : res.startTime.addMinutes(workTypeRecord[0].WorkType.EstimatedDuration.intValue());
            res.endTime = res.startTime.addMinutes(duration);
            res.eventDate = res.startTime.date();
            res.eventDate.format();
            res.dayOfWeek = res.endTime.format('E');
            res.timeVal = res.endTime.hour() > 12 ? 'PM' : 'AM';
            res.id = wrapper.id;
            res.territoryId = wrapper.territoryId;
            system.debug('wrapper territory id ' + res.territoryId);
            for (Id territoryId : territoryIds) {
                if(res.territoryId == territoryId){
                    if(dayValue =='All' || res.dayOfWeek == dayValue){
                        if(TimeValue == 'All Day' || TimeValue == res.timeVal) {
                            String keyname = string.valueOf(res.territoryId);
                            if(!resultMap.containsKey(keyname)){
                                resultMap.put(keyname, new List <Result>());
                            }
                            resultMap.get(keyname).add(res);
                        }
                    }        
                }
            }
           
        }

        system.debug('resultmap ' + resultMap.keyset());

        Map<Id, ServiceTerritory> territoryMap = new Map<Id, ServiceTerritory>([SELECT Id, Name FROM ServiceTerritory WHERE Id IN :territoryIds]);

        List <TerritoryEvent> TerritoryEvents = new List <TerritoryEvent>();

        for(String key : resultMap.keySet()){
            TerritoryEvent TerritoryEvent = new TerritoryEvent();
            TerritoryEvent.territoryName = territoryMap.get(key).Name;
            TerritoryEvent.territoryId = territoryMap.get(key).Id;
            TerritoryEvent.results = resultMap.get(key);
            TerritoryEvents.add(TerritoryEvent);
        }

        originalWorkType.EstimatedDuration = originalDuration;
        update originalWorkType;

        system.debug(TerritoryEvents);
        
        return TerritoryEvents;

    }

   @AuraEnabled
    public static List<ResourceEvent> getData( List<String> serviceResourceId, Id accountId, List<String> location, Id wt, String bu, String pg, String psg, String at, String dayValue, String TimeValue, Date currentDate, Integer duration) {
        DateTime currentDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 0, 0, 0);

        List <WorkTypeGroupMember> workTypeGroupMember = [SELECT Id, WorkTypeId, WorkType.EstimatedDuration, WorkTypeGroupId FROM WorkTypeGroupMember 
        WHERE WorkTypeGroup.Appointment_Type__c = :at AND 
        WorkTypeGroup.Business_Unit__c = :bu AND
        WorkTypeGroup.Product_Group__c = :pg AND
        WorkTypeGroup.Product_SubGroup__c = :psg
        LIMIT 1];

        List <WorkTypeGroupMember> workTypeRecord = [SELECT Id,WorkTypeId,  WorkType.EstimatedDuration FROM WorkTypeGroupMember WHERE WorkTypeId = :wt LIMIT 1];
        String wtId = workTypeRecord[0].WorkTypeId;

        workType originalWorkType = [SELECT Id,EstimatedDuration FROM WorkType WHERE Id = :wtId LIMIT 1];
        Double originalDuration = originalWorkType.EstimatedDuration;

        if(duration != originalDuration) {
            originalWorkType.EstimatedDuration = duration;
            update originalWorkType;
        }

        List <AppointmentSchedulingPolicy> policyId = [SELECT Id FROM AppointmentSchedulingPolicy WHERE MasterLabel ='VIGO Scheduling Policy' LIMIT 1];

        lxscheduler.WorkType workType = new lxscheduler.WorkTypeBuilder()
        .setId(wt != null ? wt : workTypeGroupMember[0].WorkTypeId)
        // .setDurationInMinutes(duration)
        .build();

    

    lxscheduler.GetAppointmentCandidatesInput input = new lxscheduler.GetAppointmentCandidatesInputBuilder()
        .setWorkType(workType)
        .setTerritoryIds(location)
        .setStartTime(currentDateTime.format('yyyy-MM-dd\'T\'HH:mm:ssZ'))
        .setAccountId(accountId)
        .setSchedulingPolicyId(policyId[0].Id)
        .setApiVersion(Double.valueOf('59.0'))
        .build();


    String response = lxscheduler.SchedulerResources.getAppointmentCandidates(input);
        List<ResponseWrapper> wrapperResult = (List<ResponseWrapper>)JSON.deserialize(response, List<ResponseWrapper>.class);
        Set<Id> resourceIds = new Set<Id>();
        for (ResponseWrapper wrapper : wrapperResult) {
            resourceIds.addAll(wrapper.resources);
        }
 
    //    Query all resources
        Map<Id, ServiceResource> resourceMap =  new Map<Id, ServiceResource> ([SELECT Id,RelatedRecord.Name FROM ServiceResource WHERE Id IN : resourceIds]);

        Map<String, List <Result>> resultMap = new Map<String, List<Result>>();
        List<Result> results = new List<Result>();
        Set<Id> territoryIds = new Set<Id>();
        for (ResponseWrapper wrapper : wrapperResult) {

            Result res = new Result();

            List <String> dateList = wrapper.startTime.split('T');
            res.startTime = Datetime.newInstance(Integer.valueOf(dateList[0].split('-')[0]), Integer.valueOf(dateList[0].split('-')[1]), Integer.valueOf(dateList[0].split('-')[2]), Integer.valueOf(dateList[1].split(':')[0]), Integer.valueOf(dateList[1].split(':')[1]), 0);
            TimeZone tz = UserInfo.getTimeZone();
            Integer milliSeconds = tz.getOffset(res.startTime);
            Integer minutes = milliSeconds / 60000;
            Integer offSetHours = minutes / 60;
            res.startTime = res.startTime.addHours(offSetHours);
            res.endTime = res.startTime.addMinutes(duration);
            // res.endTime = wt == null ? res.startTime.addMinutes(workTypeGroupMember[0].WorkType.EstimatedDuration.intValue()) : res.startTime.addMinutes(workTypeRecord[0].WorkType.EstimatedDuration.intValue());
            res.eventDate = res.startTime.date();
            res.eventDate.format();
            res.dayOfWeek = res.endTime.format('E');
            res.timeVal = res.endTime.hour() > 12 ? 'PM' : 'AM';
            res.id = wrapper.id;
            res.territoryId = wrapper.territoryId;
            Boolean addToRespons = false;
            for (Id resourceId : wrapper.resources) {
                 if(serviceResourceId[0] == null || ( serviceResourceId.contains(resourceId))){
                    if(dayValue =='All' || res.dayOfWeek == dayValue){
                        if(TimeValue == 'All Day' || TimeValue == res.timeVal) {
                            String keyname = string.valueOf(resourceId) +  '-' + string.valueOf(res.territoryId);
                            territoryIds.add(res.territoryId);
                            if(!resultMap.containsKey(keyname)){
                                resultMap.put(keyname, new List <Result>());
                            }
                            resultMap.get(keyname).add(res);
                        }
                    }
                }           
            }
        }

        Map<Id, ServiceTerritory> territoryMap = new Map<Id, ServiceTerritory>([SELECT Id, Name FROM ServiceTerritory WHERE Id IN :territoryIds]);

        List <ResourceEvent> resourceEvents = new List <ResourceEvent>();

        for(String key : resultMap.keySet()){
            ResourceEvent resourceEvent = new ResourceEvent();
            resourceEvent.id = key;
            resourceEvent.resourceName = resourceMap.get(key.split('-')[0]).RelatedRecord.Name;
            resourceEvent.territoryName = territoryMap.get(key.split('-')[1]).Name;
            resourceEvent.territoryId = territoryMap.get(key.split('-')[1]).Id;
            resourceEvent.results = resultMap.get(key);
            resourceEvents.add(resourceEvent);
        }

        originalWorkType.EstimatedDuration = originalDuration;
        update originalWorkType;

        return resourceEvents;
    }

    @AuraEnabled
    public static Response createServiceAppointment(String Location, Datetime startTime, Datetime endTime, String account, String user, String user2, String workType, String description, Decimal duration) {

        List<AssignedResource> overlappingAppointment = [SELECT id FROM AssignedResource 
                                                        WHERE ServiceResourceId = :user AND ServiceAppointment.Status != 'Canceled' 
                                                        AND (
                                                            (ServiceAppointment.SchedStartTime >= :startTime AND ServiceAppointment.SchedStartTime < :endTime)
                                                            OR (ServiceAppointment.SchedEndTime > :startTime AND ServiceAppointment.SchedEndTime <= :endTime)   
                                                            OR (ServiceAppointment.SchedStartTime <= :startTime AND ServiceAppointment.SchedEndTime >= :endTime) 
                                                            OR (ServiceAppointment.SchedStartTime >= :startTime AND ServiceAppointment.SchedEndTime <= :endTime) 
                                                            )
                                                        ];
        
        List<ResourceAbsence> overlappingResourceAbsence = [SELECT Id FROM ResourceAbsence
                                                            WHERE ResourceId = :user
                                                            AND (
                                                                (Start >= :startTime AND Start < :endTime)
                                                                OR (End > :startTime AND End <= :endTime) 
                                                                OR (Start <= :startTime AND End >= :endTime)
                                                                OR (Start >= :startTime AND End <= :endTime) 
                                                                )                                                                                                          
                                                            ];

        Response response = new Response();
        if(overlappingAppointment.size() == 0 && overlappingResourceAbsence.size() == 0){
       
        // Create a ServiceAppointment
        ServiceAppointment sa = new ServiceAppointment();
        sa.ServiceTerritoryId = location;
        sa.Status = 'Scheduled';
        sa.Duration = duration;
        sa.DurationType = 'Minutes';
        sa.SchedStartTime = startTime;
        sa.EarliestStartTime = startTime;
        sa.SchedEndTime = endtime;
        sa.DueDate = endtime;
        sa.ParentRecordId = account;
        sa.workTypeId = workType;
        sa.Description = description;

        insert sa;

        AssignedResource asrec = new AssignedResource();
        asrec.ServiceAppointmentId = sa.Id;
        asrec.ServiceResourceId = user;
        asrec.IsPrimaryResource = true;
        asrec.IsRequiredResource = true;

        insert asrec;

        if(user2 != null){

        AssignedResource asrec2 = new AssignedResource();
        asrec2.ServiceAppointmentId = sa.Id;
        asrec2.ServiceResourceId = user2;
        asrec2.IsPrimaryResource = false;
        asrec2.IsRequiredResource = true;

        insert asrec2;
        }

        
        response.title = System.label.AppointmentSchedulerSASuccessTitle;
        response.message = System.label.AppointmentSchedulerSuccessBody;
        response.type = 'success';
            
         } else {
            response.title = System.label.AppointmentSchedulerSAErrorTitle;
            response.message = System.label.AppointmentSchedulerSAErroBody;
            response.type = 'error';
            
    }
    return response;
    }

    @AuraEnabled
    public static weekDays calculatedays(Date startDate, string dayOfWeek){

        integer dayOffset = 0;

        if(dayOfWeek == 'Tue'){
         dayOffset = 1;
        } else if (dayOfWeek =='Wed') {
         dayOffset = 2;
        } else if (dayOfWeek == 'Thu') {
         dayOffset = 3;
        } else if (dayOfWeek == 'Fri') {
         dayOffset = 4;
        } 

        weekDays wDays = new weekDays();

            wDays.startDate = Date.valueOf(startDate).toStartOfWeek();
            wDays.mondayDate = wDays.startDate.addDays(dayOffset);
            wDays.tuesdayDate = wDays.startDate.addDays(7).addDays(dayOffset);
            wDays.wednesdayDate = wDays.startDate.addDays(14).addDays(dayOffset);
            wDays.thursdayDate = wDays.startDate.addDays(21).addDays(dayOffset);
            wDays.fridayDate = wDays.startDate.addDays(28).addDays(dayOffset);
            wDays.saturdayDate = wDays.startDate.addDays(29).addDays(dayOffset);
        return wDays;
    }

    @AuraEnabled
    public static weekDays calculateWeekdays(Date startDate){

        weekDays wDays = new weekDays();
        if (UserInfo.getLocale() == 'en_US') {
            wDays.startDate = startDate.toStartOfWeek();
            wDays.mondayDate = wDays.startDate.addDays(1);
            wDays.tuesdayDate = wDays.startDate.addDays(2);
            wDays.wednesdayDate = wDays.startDate.addDays(3);
            wDays.thursdayDate = wDays.startDate.addDays(4);
            wDays.fridayDate = wDays.startDate.addDays(5);
            wDays.saturdayDate = wDays.startDate.addDays(6);
        } else{
            wDays.startDate = startDate.toStartOfWeek();
            wDays.mondayDate = wDays.startDate;
            wDays.tuesdayDate = wDays.startDate.addDays(1);
            wDays.wednesdayDate = wDays.startDate.addDays(2);
            wDays.thursdayDate = wDays.startDate.addDays(3);
            wDays.fridayDate = wDays.startDate.addDays(4);
            wDays.saturdayDate = wDays.startDate.addDays(5);
        }
        return wDays;
    }

    @AuraEnabled 
    public static Date setDate(Date currentDate, String actionName) {

        Integer year = currentDate.year();
        Integer month = currentDate.month();
        Integer day = currentDate.day();
        Date newDate = Date.newInstance(year, month, day);
        Integer dayOffset = 0;
        if (UserInfo.getLocale() == 'en_US') {
            dayOffset = 1;
        } 
        if (actionName == 'Next') {
           newDate = newDate.addDays(7).toStartOfWeek().addDays(dayOffset);
           System.debug('quidity ' + Request.getCurrent().getQuiddity());
        } else {
            newDate = newDate.addDays(-7).toStartOfWeek().addDays(dayOffset);
        }
        return newDate;
    }

    // inner object
    public class ResponseWrapper {
        public String startTime;
        public String endTime;
        public String id;
        public List<Id> resources;
        public Id territoryId;
    }

    // Exposed object
    public class Result {
        @AuraEnabled
        public Datetime startTime;
        @AuraEnabled
        public Datetime endTime;
        @AuraEnabled
         public String id;
        @AuraEnabled
        public String resourceName;
        @AuraEnabled
        public String dayOfWeek;
        @AuraEnabled 
        public Date eventDate;
        @auraEnabled 
        public String timeVal;
        @AuraEnabled
        public String territoryId;
        @AuraEnabled
        public String territoryName;
    }

    public class ResourceEvent {
        @auraEnabled
        public String id;
        @auraEnabled
        public String resourceName;
        @auraEnabled
        public String territoryName;
        @auraEnabled
        public String territoryId;
        @auraEnabled
        public List <Result> results;
    }

    public class TerritoryEvent {
        @auraEnabled
        public String territoryName;
        @auraEnabled
        public String territoryId;
        @auraEnabled
        public List <Result> results;
    }

    public class ASWorkType {
        @auraEnabled 
        public String id;
        @auraEnabled 
        public Decimal duration;
        @AuraEnabled
        public String name;
    }

    public class Weekdays{
        @auraEnabled
        public Date mondayDate;
        @auraEnabled
        public Date tuesdayDate;
        @auraEnabled
        public Date wednesdayDate;
        @auraEnabled
        public Date thursdayDate;
        @auraEnabled 
        public Date fridayDate;
        @auraEnabled 
        public Date startDate;
        @auraEnabled 
        public Date saturdayDate;
    }

    public class Response {
        @auraEnabled
        public String title;
        @auraEnabled
        public String message;
        @auraEnabled
        public String type;
    }

}