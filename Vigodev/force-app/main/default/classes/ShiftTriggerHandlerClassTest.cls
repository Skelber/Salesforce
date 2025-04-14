@IsTest
public with sharing class ShiftTriggerHandlerClassTest {

    @testSetup static void createData() {

        Job_Profile__c jp = new Job_Profile__c();
        jp.Name = 'job profile to test';
        insert jp;

        Shift shift = new Shift();
        shift.StartTime = Datetime.newInstance(2024, 7, 1, 8, 0, 0);
        shift.EndTime = Datetime.newInstance(2024, 7, 1, 17, 0, 0);
        shift.Status = 'Tentative';
        shift.label = 'test shift for apex test';
        shift.Job_Profile__c = jp.id;
        insert shift;
    }

    @IsTest
    public static void validateCreateShiftWorkTopics(){

        Skill__c skillc = new Skill__c();
        skillc.Name = 'Prothesen';
        insert skillc;
        
        Job_Profile__c jp = [SELECT Id FROM Job_Profile__c WHERE Name = 'job profile to test' LIMIT 1];

        Job_Profile_Skill__c jps = new Job_Profile_Skill__c();
        jps.Skill__c = skillc.Id;
        jps.Job_Profile__c = jp.Id;
        insert jps;

        WorkTypeGroup wtg = new WorkTypeGroup();
        wtg.Name = 'Mobility - bikes - test - test';
        wtg.Business_Unit__c = 'Orthotics';
        wtg.Product_Group__c = 'Head';
        wtg.Product_SubGroup__c = 'Crash helmet';
        wtg.Appointment_Type__c = 'Delivery';
        wtg.GroupType = 'Default';
        insert wtg;
        
        WorkType wt = new WorkType();
        wt.Name = 'test worktype';
        wt.EstimatedDuration = 60;
        wt.DurationType = 'minutes';
        insert wt;

        WorkTypeGroupMember wtgm = new WorkTypeGroupMember();
        wtgm.WorkTypeId = wt.Id;
        wtgm.WorkTypeGroupId = wtg.Id;
        insert wtgm;
        
        Skill skill = [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel = :skillc.Name];

        SkillRequirement sr = new SkillRequirement();
        sr.SkillId = skill.Id;
        sr.RelatedRecordId = wt.Id;
        insert sr;
  
        // Shift shift = [SELECT Id, Job_Profile__c FROM Shift WHERE Job_Profile__c != null LIMIT 1];

        Shift shift = [SELECT Id, Job_Profile__c FROM Shift WHERE label = 'test shift for apex test' LIMIT 1];

        List<Shift> shiftList = new List <Shift>();
        shiftList.add(shift);

        Test.startTest();
        ShiftTriggerHandlerClass.createShiftWorkTopics(shiftList);
        Test.stopTest();
    }

    @IsTest
    public static void validateDeleteShiftWorkTopics(){
        // Shift shift = new Shift();
        // shift.StartTime = Datetime.newInstance(2024, 7, 1, 8, 0, 0);
        // shift.EndTime = Datetime.newInstance(2024, 7, 1, 17, 0, 0);
        // shift.Status = 'Tentative';
        // insert shift;

        Shift shift = [SELECT Id, Job_Profile__c FROM Shift WHERE label = 'test shift for apex test' LIMIT 1];

        WorkTypeGroup wtg = new WorkTypeGroup();
        wtg.Name = 'test Work Type Group';
        wtg.Business_Unit__c = 'Orthotics';
        wtg.Product_Group__c = 'Head';
        wtg.Product_SubGroup__c = 'Crash helmet';
        wtg.Appointment_Type__c = 'Measurement';
        wtg.GroupType = 'Default';
        insert wtg;
        
        ShiftWorkTopic swt = new ShiftWorkTopic();
        swt.ShiftId =  shift.Id;
        swt.WorkTypeGroupId = wtg.Id;
        insert swt;

        Job_Profile__c jp = new Job_Profile__c();
        jp.Name = 'Test job profile';
        insert jp;

        shift.Job_Profile__c = jp.Id;
        update shift;

         List<Shift> shiftList = new List <Shift>();
        shiftList.add(shift);

        Test.startTest();
        ShiftTriggerHandlerClass.deleteShiftWorkTopics(shiftList);
        Test.stopTest();
    }
}