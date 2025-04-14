public with sharing class GetCandidatesController {
@InvocableMethod(label='get eligible service resources')
  public static List<Result> getEligibleServiceResources(List <ShiftInput> shiftInput) {

//---------------------------------------------------------------------------------------------------------------------------------


        ShiftInput si = shiftInput[0];

        Id jobProfileId = si.jobProfileId;
        Id territoryId = si.territoryId;

        List<Service_Resource_Profile__c> serviceResourceProfiles = [
            SELECT Id, Job_Profile__c, Service_Resource__c FROM Service_Resource_Profile__c WHERE Job_Profile__c IN (SELECT Id FROM Job_Profile__c WHERE Id = :jobProfileId)
        ];

        Set<Id> serviceResourceProfileIds = new Set<Id>();
        for (Service_Resource_Profile__c srp : serviceResourceProfiles) {
            serviceResourceProfileIds.add(srp.Service_Resource__c);
        }

        List<ServiceTerritoryMember> serviceTerritoryMembers = [
            SELECT Id, ServiceResourceId, ServiceTerritoryId FROM ServiceTerritoryMember 
            WHERE ServiceResourceId IN :serviceResourceProfileIds AND ServiceTerritoryId IN (SELECT Id from ServiceTerritory WHERE Id = :territoryId)
        ];

        Set<Id> qualifiedServiceResourceIds = new Set<Id>();
            for (ServiceTerritoryMember srid : serviceTerritoryMembers) {
                qualifiedServiceResourceIds.add(srid.ServiceResourceId);
        }
     
        
        // // Get WorkTypeGroupIds associated with the Shift
        // List<ShiftWorkTopic> shiftWorkTopics = [
        //     SELECT WorkTypeGroupId 
        //     FROM ShiftWorkTopic 
        //     WHERE ShiftId = :si.shiftId
        // ];     
        // // Collect WorkTypeGroupIds
        // Set<Id> workTypeGroupIds = new Set<Id>();
        // for (ShiftWorkTopic swt : shiftWorkTopics) {
        //     workTypeGroupIds.add(swt.WorkTypeGroupId);
        // }
        
        // // Get WorkTypeIds from WorkTypeGroupMember
        // List<WorkTypeGroupMember> wtgmList = [
        //     SELECT WorkTypeId 
        //     FROM WorkTypeGroupMember 
        //     WHERE WorkTypeGroupId IN :workTypeGroupIds
        // ];
        
        // // Collect WorkTypeIds
        // Set<Id> workTypeIds = new Set<Id>();
        // for (WorkTypeGroupMember wtgm : wtgmList) {
        //     workTypeIds.add(wtgm.WorkTypeId);
        // }
        
        // // Get SkillRequirements for the WorkTypes
        // List<SkillRequirement> skillRequirements = [
        //     SELECT SkillId 
        //     FROM SkillRequirement 
        //     WHERE RelatedRecordId IN :workTypeIds
        // ];
        
        // // Collect SkillIds
        // Set<Id> skillIds = new Set<Id>();
        // for (SkillRequirement sr : skillRequirements) {
        //     skillIds.add(sr.SkillId);
        // }
        
        // // Get ServiceResourceSkills matching the SkillIds
        // List<ServiceResourceSkill> serviceResourceSkills = [
        //     SELECT ServiceResourceId, SkillId 
        //     FROM ServiceResourceSkill 
        //     WHERE SkillId IN :skillIds
        // ];
        
        // // Map to count skills per Service Resource
        // Map<Id, Set<Id>> serviceResourceSkillMap = new Map<Id, Set<Id>>();
        // for (ServiceResourceSkill srs : serviceResourceSkills) {
        //     if (!serviceResourceSkillMap.containsKey(srs.ServiceResourceId)) {
        //         serviceResourceSkillMap.put(srs.ServiceResourceId, new Set<Id>());
        //     }
        //     serviceResourceSkillMap.get(srs.ServiceResourceId).add(srs.SkillId);
        // }
        
        // Filter Service Resources who have all required skills
        // Set<Id> qualifiedServiceResourceIds = new Set<Id>();
        // for (Id serviceResourceId : serviceResourceSkillMap.keySet()) {
        //     if (serviceResourceSkillMap.get(serviceResourceId).size() == skillIds.size()) {
        //         qualifiedServiceResourceIds.add(serviceResourceId);
        //     }
        // }
        
        // Get overlapping Shifts
        List<Shift> overlappingShifts = [
            SELECT ServiceResourceId 
            FROM Shift 
            WHERE ServiceResourceId IN :qualifiedServiceResourceIds 
            AND (StartTime < :si.endDate AND EndTime > :si.startDate AND Status = 'Confirmed')
        ];
        
        // Collect ServiceResourceIds with overlapping Shifts
        Set<Id> overlappingShiftResourceIds = new Set<Id>();
        for (Shift shift : overlappingShifts) {
            overlappingShiftResourceIds.add(shift.ServiceResourceId);
        }
        qualifiedServiceResourceIds.removeAll(overlappingShiftResourceIds);
        
        // Get eligible ServiceResources
        List<ServiceResource> eligibleServiceResources = [
            SELECT Id, Name, RelatedRecordId 
            FROM ServiceResource 
            WHERE Id IN :qualifiedServiceResourceIds
        ];
        
        // Collect RelatedRecordIds of eligible ServiceResources
        Set<Id> eligibleServiceResourceUserIds = new Set<Id>();
        for (ServiceResource sr : eligibleServiceResources) {
            eligibleServiceResourceUserIds.add(sr.RelatedRecordId);
        }
        
        // Get overlapping Events
        List<Event> overlappingEvents = [
            SELECT OwnerId 
            FROM Event 
            WHERE OwnerId IN :eligibleServiceResourceUserIds 
            AND (StartDateTime < :si.endDate AND EndDateTime > :si.startDate AND (ShowAs !='Busy' OR ShowAs != 'Out of Office'))
        ];
        
        // Collect UserIds with overlapping Events
        Set<Id> overlappingEventUserIds = new Set<Id>();
        for (Event evt : overlappingEvents) {
            overlappingEventUserIds.add(evt.OwnerId);
        }
        
        // Collect ServiceResourceIds with overlapping Events
        Set<Id> overlappingServiceResourceIds = new Set<Id>();
        if (!overlappingEventUserIds.isEmpty()) {
            List<ServiceResource> overlappingServiceResources = [
                SELECT Id 
                FROM ServiceResource 
                WHERE RelatedRecordId IN :overlappingEventUserIds
            ];
            for (ServiceResource sr : overlappingServiceResources) {
                overlappingServiceResourceIds.add(sr.Id);
            }
        }
        
        // Remove ServiceResources with overlapping Events
        qualifiedServiceResourceIds.removeAll(overlappingServiceResourceIds);
        
        // Get available ServiceResources
        List<ServiceResource> availableServiceResources = [
            SELECT Id, Name, RelatedRecordId 
            FROM ServiceResource 
            WHERE Id IN :qualifiedServiceResourceIds
        ];
        
        // Prepare the result
        Result result = new Result();
        result.serviceResources = availableServiceResources;
        
        return new List<Result>{result};
    }

    public class ShiftInput {
        @InvocableVariable
        public Datetime startDate;
        @InvocableVariable
        public Datetime endDate;
        @InvocableVariable
        public Id shiftId;
        @InvocableVariable
        public Id jobProfileId;
        @InvocableVariable
        public Id territoryId;
    }

    public class Result {
        @InvocableVariable
        public List<ServiceResource> serviceResources;
    }
}





