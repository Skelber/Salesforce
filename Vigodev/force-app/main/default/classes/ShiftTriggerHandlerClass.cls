public with sharing class ShiftTriggerHandlerClass {


    public static void deleteShiftWorkTopics(List<Shift> shiftList) {
        if (shiftList == null || shiftList.isEmpty()) return;

        List<ShiftWorkTopic> shiftWorkTopicsToDelete = [
            SELECT Id 
            FROM ShiftWorkTopic 
            WHERE ShiftId IN :shiftList
        ];

        if (!shiftWorkTopicsToDelete.isEmpty()) {
            delete shiftWorkTopicsToDelete;
        }
    }

    public static void createShiftWorkTopics(List<Shift> shiftList) {

        Boolean jumpToShiftWorkTopicCreation = False;
        if (shiftList == null || shiftList.isEmpty()) return;

        Set<Id> jobProfileIds = new Set<Id>();
        for (Shift shift : shiftList) {
            if (shift.Job_Profile__c != null) {
                jobProfileIds.add(shift.Job_Profile__c);
            }
        }

        if (jobProfileIds.isEmpty()) return;

        Map<Id, Job_Profile__c> jobProfileMap = new Map<Id, Job_Profile__c>();
            for (Job_Profile__c jp : [
                SELECT Id, All_work_types_supported__c 
                FROM Job_Profile__c 
                WHERE Id IN :jobProfileIds
            ]) {
                jobProfileMap.put(jp.Id, jp);
            }

        Map<Id, List<Job_Profile_Skill__c>> jobProfileSkillMap = new Map<Id, List<Job_Profile_Skill__c>>();
        for (Job_Profile_Skill__c jps : [
            SELECT Id, Job_Profile__c, Skill__c 
            FROM Job_Profile_Skill__c 
            WHERE Job_Profile__c IN :jobProfileIds
        ]) {
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
