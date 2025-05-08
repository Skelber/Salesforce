// LLP-1575

public with sharing class ShiftTriggerHandlerClass {
 
    //Delete ShiftWorkTopics related to the given Shifts (shiftList)
    public static void deleteShiftWorkTopics(List<Shift> shiftList, Map<Id, Shift> oldMap) {
        System.debug('DELETE shiftList : ' + shiftList);
        System.debug('DELETE oldMap : ' + oldMap);
        
        if (shiftList == null || shiftList.isEmpty()) return;
        
        //Check if there is a change in Job Profile. If not, ignore Shift.
        List <Shift> shiftListToDelete = new List <Shift>();
        for(Shift shift : shiftList){
            if (shift.Job_Profile__c != oldMap.get(shift.Id).Job_Profile__c) {
                shiftListToDelete.add(shift);
            }
        }
        //Get all ShiftWorkTopic of Shifts with change in Job Profile
        if(shiftListToDelete.size() > 0) {
            List<ShiftWorkTopic> shiftWorkTopicsToDelete = [SELECT Id FROM ShiftWorkTopic WHERE ShiftId IN :shiftList];
            if (!shiftWorkTopicsToDelete.isEmpty()) {
                System.debug('shiftWorkTopicsToDelete : ' + shiftWorkTopicsToDelete);
                delete shiftWorkTopicsToDelete;
            }
        }
    }

   
    public static void createShiftWorkTopics(List<Shift> newList, Map<Id, Shift> oldMap) {
        System.debug('CREATE newList : ' + newList);
        System.debug('CREATE oldMap : ' + oldMap);

        List<ShiftWorkTopic> toCreate = new List<ShiftWorkTopic>();
        
        //Boolean jumpToShiftWorkTopicCreation = False;
        if (newList == null || newList.isEmpty()) return;
        
        //Create list of all Shifts where Shift Work Topics should be created  (new with Job Profile filled or Job Profile changed)
        List <Shift> shiftList = new List <Shift>();
        Map<Id, List<Id>> jobProfileShiftMap = new Map<Id, List<Id>>();   //Map  Job Profile Id + Shift Id
        for(Shift shift : newList) {
            
            if(oldMap == null || shift.Job_Profile__c != oldMap.get(shift.Id).Job_Profile__c) {
                if(shift.Job_Profile__c != null){
                    shiftList.add(shift);
                    if (!jobProfileShiftMap.containsKey(shift.Job_Profile__c)) {
                        jobProfileShiftMap.put(shift.Job_Profile__c, new List<Id>());
                    }
                    jobProfileShiftMap.get(shift.Job_Profile__c).add(shift.Id);
                }
            }
             
        }      
        if (shiftList.isEmpty()) return;  

        //Create List of all Job Profile Ids of Job Profiles with All_work_types_supported__c = false
        //If All_work_types_supported__c = true, create immediately the ShiftWorkTopic
        Set<Id> jobProfileIds = new Set<Id>();
        for (Job_Profile__c jp : [SELECT Id, All_work_types_supported__c FROM Job_Profile__c WHERE Id IN :jobProfileShiftMap.KeySet()]) {
            System.debug('jp : ' + jp + ' - ' + jp.All_work_types_supported__c);
            if(jp.All_work_types_supported__c) {    //If All Work Types are supported, a general Shift Work Topic is created
                for(Id shiftId : jobProfileShiftMap.get(jp.Id)) {
                    ShiftWorkTopic swt = new ShiftWorkTopic();
                    swt.ShiftId = shiftId;
                    swt.AreAllTopicsSupported = true;
                    toCreate.add(swt);
                }
            } else {                                //If not, then the logic should be used
                jobProfileIds.add(jp.Id);
            }
            
        }
        System.debug('toCreate (only All_work_types_supported__c) : ' + toCreate);
        System.debug('jobProfileIds : ' + jobProfileIds);
        //if (jobProfileIds.isEmpty()) return;
        
        Map<String, Id> skillMap = new Map<String, Id>();
        for (Skill skill : [SELECT Id, MasterLabel FROM Skill]) {
            skillMap.put(skill.MasterLabel, skill.Id);
        }

        //Create Map of Job_Profile__c id with corresponding list of Skill Ids
        Map<Id, List<Id>> jobProfileTOSkillMap = new Map<Id, List<Id>>();
        Set<Id> skillIdSet = new Set<Id>();
        for (Job_Profile_Skill__c jps : [SELECT Id, Job_Profile__c, Skill__c, Skill__r.Id, Skill__r.Name 
                                           FROM Job_Profile_Skill__c WHERE Job_Profile__c IN :jobProfileIds]) {
            if (skillMap.containsKey(jps.Skill__r.Name)) {
                if (!jobProfileTOSkillMap.containsKey(jps.Job_Profile__c)) {
                    jobProfileTOSkillMap.put(jps.Job_Profile__c, new List<Id>());
                }
                jobProfileTOSkillMap.get(jps.Job_Profile__c).add(skillMap.get(jps.Skill__r.Name));
                skillIdSet.add(skillMap.get(jps.Skill__r.Name));
            }
        }
        System.debug('jobProfileTOSkillMap : ' + jobProfileTOSkillMap);
        System.debug('skillIdSet : ' + skillIdSet);

        //Create Map of Skill Id with list of corresponding Skill Requirements (field RelatedRecordId)
        Set<Id> relatedRecordIds = new Set<Id>();
        Map<Id, List<Id>> skillRequirementMap = new Map<Id, List<Id>>();
        for (SkillRequirement sr : [SELECT Id, RelatedRecordId, SkillId FROM SkillRequirement WHERE SkillId IN :skillIdSet]) {
            if (!skillRequirementMap.containsKey(sr.SkillId)) {
                skillRequirementMap.put(sr.SkillId, new List<Id>());
            }
            skillRequirementMap.get(sr.SkillId).add(sr.RelatedRecordId);
            relatedRecordIds.add(sr.RelatedRecordId);
        }
        System.debug('relatedRecordIds : ' + relatedRecordIds);
        System.debug('skillRequirementMap : ' + skillRequirementMap);
        
        //Create Map of Work Type Id (related id) with list of corresponding WorkTypeGroupId
        Map<Id, List<String>> workTypeGroupMemberMap = new Map<Id, List<String>>();
        for (WorkTypeGroupMember wtgm : [SELECT Id, WorkTypeGroupId, WorkTypeId FROM WorkTypeGroupMember WHERE WorkTypeId IN :relatedRecordIds]) {
            if (!workTypeGroupMemberMap.containsKey(wtgm.WorkTypeId)) {
                workTypeGroupMemberMap.put(wtgm.WorkTypeId, new List<String>());
            }
            workTypeGroupMemberMap.get(wtgm.WorkTypeId).add(wtgm.WorkTypeGroupId);
        }
        System.debug('workTypeGroupMemberMap : ' + workTypeGroupMemberMap);
               
        //Create Shift Work Types for the job profiles with All_work_types_supported__c= false
        for (Id JobProfileId : jobProfileIds) {  
            System.debug('FOR LOOP JobProfileId : ' + JobProfileId);
            
            if(jobProfileTOSkillMap.get(JobProfileId) <> null) 
            for (Id skillId : jobProfileTOSkillMap.get(JobProfileId)) { 
                System.debug('FOR LOOP skillId : ' + skillId);
                
                if(skillRequirementMap.get(skillId) <> null)
                for (id relatedId : skillRequirementMap.get(skillId)) {
                    System.debug('FOR LOOP relatedId : ' + relatedId);
                    
                    if(workTypeGroupMemberMap.get(relatedId) <> null)
                    for (String wtgId : workTypeGroupMemberMap.get(relatedId)) {
                        System.debug('FOR LOOP wtgId : ' + wtgId);
                        
                        for(Id shiftId : jobProfileShiftMap.get(JobProfileId)) {
                            ShiftWorkTopic swt = new ShiftWorkTopic();
                            swt.ShiftId = shiftId;
                            swt.WorkTypeGroupId = wtgId;
                            toCreate.add(swt);
                        }
                    }
                }
            }            
        }
        
        System.debug('toCreate (all) :' + toCreate);
        System.debug('toCreate (all) :' + toCreate.size());
        
        if (!toCreate.isEmpty()) {
            //Database.executeBatch(new ShiftWorkTopicsBatchClass(toCreate), 200);
            insert toCreate;
        }
    }
    
    
/*
  public with sharing class ShiftTriggerHandlerClass {

    //Delete ShiftWorkTopics related to the given Shifts (shiftList)
    public static void deleteShiftWorkTopics(List<Shift> shiftList) {
        if (shiftList == null || shiftList.isEmpty()) return;

        List<ShiftWorkTopic> shiftWorkTopicsToDelete = [SELECT Id FROM ShiftWorkTopic WHERE ShiftId IN :shiftList];

        if (!shiftWorkTopicsToDelete.isEmpty()) {
            delete shiftWorkTopicsToDelete;
        }
    }

   
    public static void createShiftWorkTopics(List<Shift> shiftList) {

        //Boolean jumpToShiftWorkTopicCreation = False;
        if (shiftList == null || shiftList.isEmpty()) return;

        //Create List of all jobProfileIds
        Set<Id> jobProfileIds = new Set<Id>();
        for (Shift shift : shiftList) {
            if (shift.Job_Profile__c != null) {
                jobProfileIds.add(shift.Job_Profile__c);
            }
        }
        if (jobProfileIds.isEmpty()) return;

        //Create Map of Job_Profile__c is with corresponding record
        Map<Id, Job_Profile__c> jobProfileMap = new Map<Id, Job_Profile__c>();
        for (Job_Profile__c jp : [SELECT Id, All_work_types_supported__c FROM Job_Profile__c WHERE Id IN :jobProfileIds]) {
            jobProfileMap.put(jp.Id, jp);
        }

        //Create Map of Job_Profile__c id with corresponding list of job_Profile_Skills
        Map<Id, List<Job_Profile_Skill__c>> jobProfileSkillMap = new Map<Id, List<Job_Profile_Skill__c>>();
        for (Job_Profile_Skill__c jps : [SELECT Id, Job_Profile__c, Skill__c FROM Job_Profile_Skill__c WHERE Job_Profile__c IN :jobProfileIds]) {
            if (jps.Job_Profile__c != null) {
                if (!jobProfileSkillMap.containsKey(jps.Job_Profile__c)) {
                    jobProfileSkillMap.put(jps.Job_Profile__c, new List<Job_Profile_Skill__c>());
                }
                jobProfileSkillMap.get(jps.Job_Profile__c).add(jps);
            }
        }

        Set<Id> skillIds = new Set<Id>();
        if(!jobProfileSkillMap.isEmpty()){
            for (List<Job_Profile_Skill__c> jpsList : jobProfileSkillMap.values()) {
                for (Job_Profile_Skill__c jps : jpsList) {
                    skillIds.add(jps.Skill__c);
                }
            }
        }
        

        // if (skillIds.isEmpty()) return;

        Map<Id, String> skillNameMap = new Map<Id, String>();
        for (Skill__c skill : [
            SELECT Id, Name 
            FROM Skill__c 
            WHERE Id IN :skillIds
        ]) {
            skillNameMap.put(skill.Id, skill.Name);
        }


        Map<String, List<Skill>> skillMap = new Map<String, List<Skill>>();
        for (Skill skill : [
            SELECT Id, MasterLabel 
            FROM Skill 
            WHERE MasterLabel IN :skillNameMap.values()
        ]) {
            if (!skillMap.containsKey(skill.MasterLabel)) {
                skillMap.put(skill.MasterLabel, new List<Skill>());
            }
            skillMap.get(skill.MasterLabel).add(skill);
        }

        Set<Id> skillIdSet = new Set<Id>();
        for (List<Skill> skills : skillMap.values()) {
            for (Skill skill : skills) {
                skillIdSet.add(skill.Id);
            }
        }

        // if (skillIdSet.isEmpty()) return;


        Map<Id, List<SkillRequirement>> skillRequirementMap = new Map<Id, List<SkillRequirement>>();
        for (SkillRequirement sr : [
            SELECT Id, RelatedRecordId, SkillId 
            FROM SkillRequirement 
            WHERE SkillId IN :skillIdSet
        ]) {
            if (!skillRequirementMap.containsKey(sr.SkillId)) {
                skillRequirementMap.put(sr.SkillId, new List<SkillRequirement>());
            }
            skillRequirementMap.get(sr.SkillId).add(sr);
        }

        Set<Id> relatedRecordIds = new Set<Id>();
        for (List<SkillRequirement> srList : skillRequirementMap.values()) {
            for (SkillRequirement sr : srList) {
                relatedRecordIds.add(sr.RelatedRecordId);
            }
        }

        // if (relatedRecordIds.isEmpty()) return;

        Map<Id, List<WorkTypeGroupMember>> workTypeGroupMemberMap = new Map<Id, List<WorkTypeGroupMember>>();
        for (WorkTypeGroupMember wtgm : [
            SELECT Id, WorkTypeGroupId, WorkTypeId 
            FROM WorkTypeGroupMember 
            WHERE WorkTypeId IN :relatedRecordIds
        ]) {
            if (!workTypeGroupMemberMap.containsKey(wtgm.WorkTypeId)) {
                workTypeGroupMemberMap.put(wtgm.WorkTypeId, new List<WorkTypeGroupMember>());
            }
            workTypeGroupMemberMap.get(wtgm.WorkTypeId).add(wtgm);
        }

        List<ShiftWorkTopic> shiftWorkTopicsToCreate = new List<ShiftWorkTopic>();
        List<ShiftWorkTopic> shiftWorkTopicsAvailableForAllToCreate = new List<ShiftWorkTopic>();

        for (Shift shift : shiftList) {

            Job_Profile__c jobProfile = jobProfileMap.get(shift.Job_Profile__c);
            if (jobProfile == null) continue;

            Boolean availableForAllTopics = jobProfile.All_work_types_supported__c;

             if(availableForAllTopics) {
                    ShiftWorkTopic shiftWorkTopicAvailableForAllWorktypes = new ShiftWorkTopic();
                    shiftWorkTopicAvailableForAllWorktypes.ShiftId = shift.Id;
                    shiftWorkTopicAvailableForAllWorktypes.AreAllTopicsSupported = true;
                    shiftWorkTopicsAvailableForAllToCreate.add(shiftWorkTopicAvailableForAllWorktypes);
                } else {

            List<Job_Profile_Skill__c> jobProfileSkills = jobProfileSkillMap.get(shift.Job_Profile__c);
            if (jobProfileSkills == null) continue;

            for (Job_Profile_Skill__c jps : jobProfileSkills) {
                String skillName = skillNameMap.get(jps.Skill__c);
                if (skillName == null) continue;

                List<Skill> skills = skillMap.get(skillName);
                if (skills == null) continue;

                for (Skill skill : skills) {
                    List<SkillRequirement> skillRequirements = skillRequirementMap.get(skill.Id);
                    if (skillRequirements == null) continue;

                    for (SkillRequirement sr : skillRequirements) {
                        List<WorkTypeGroupMember> workTypeGroups = workTypeGroupMemberMap.get(sr.RelatedRecordId);
                        if (workTypeGroups == null) continue;

                        for (WorkTypeGroupMember wtgm : workTypeGroups) {
                            ShiftWorkTopic shiftWorkTopic = new ShiftWorkTopic();
                            shiftWorkTopic.ShiftId = shift.Id;
                            shiftWorkTopic.WorkTypeGroupId = wtgm.WorkTypeGroupId;
                            shiftWorkTopicsToCreate.add(shiftWorkTopic);
                        }
                    }
                }
            }
            }
        }
        
        if (!shiftWorkTopicsToCreate.isEmpty()) {
            Database.executeBatch(new ShiftWorkTopicsBatchClass(shiftWorkTopicsToCreate), 200);
        } else if (!shiftWorkTopicsAvailableForAllToCreate.isEmpty()){
            insert shiftWorkTopicsAvailableForAllToCreate;
        }
    }
}    
    
*/    
    
    
}