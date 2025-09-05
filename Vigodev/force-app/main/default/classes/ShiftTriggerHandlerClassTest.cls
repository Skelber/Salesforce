@IsTest
public with sharing class ShiftTriggerHandlerClassTest {

    @testSetup static void createData() {
        
        //OperatingHours
        OperatingHours oh = new OperatingHours();
        oh.Name = 'test Or';
        insert oh;
        
        //Service Territory
        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'test territory';
        st.OBA__c = '90463';
        st.IsActive = true;
        st.OperatingHoursId = oh.Id;
        insert st;
        
        //Job Profiles
        Job_Profile__c jp = new Job_Profile__c();
        jp.Name = 'Job Profile to test';
        jp.All_work_types_supported__c = true;
        insert jp;
        
        Job_Profile__c jp1 = new Job_Profile__c();
        jp1.Name = 'Job Profile';
        insert jp1;
        
        //JOb Profile Skills
        Job_Profile_Skill__c jps = new Job_Profile_Skill__c();
        jps.Job_Profile__c = jp.Id;
        //jps.Skill__c = sk.id;
        insert jps;
        
        Job_Profile_Skill__c jps1 = new Job_Profile_Skill__c();
        jps1.Job_Profile__c = jp1.Id;
        //jps.Skill__c = sk.id;
        insert jps1;
        
        //Shift Templates
        Shift_Template__c sht = new Shift_Template__c();
        sht.Name = 'test Shift Template';
        sht.Start_Time__c = Time.newInstance(8, 0, 0, 0);
        sht.End_Time__c = Time.newInstance(17, 0, 0, 0);
        sht.Job_Profile__c = jp.Id;
        insert sht;
        
        Shift_Template__c sht1 = new Shift_Template__c();
        sht1.Name = 'test Shift Template';
        sht1.Start_Time__c = Time.newInstance(8, 0, 0, 0);
        sht1.End_Time__c = Time.newInstance(17, 0, 0, 0);
        sht1.Job_Profile__c = jp1.Id;
        insert sht1;
        
        try{
            Shift_Template__c sht2 = new Shift_Template__c();
            sht2.Name = 'test Shift Template';
            sht2.Start_Time__c = Time.newInstance(8, 0, 0, 0);
            sht2.End_Time__c = Time.newInstance(17, 0, 0, 0);
            sht2.Job_Profile__c = jp1.Id;
            insert sht2;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        //User
        String orgId = UserInfo.getOrganizationId();
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniq =orgId+randomInt;
        User u = new User(
            firstname = 'TestFirst' +uniq,
            lastName = 'TestLast' +uniq,
            email = uniq + '@test' + orgId + '.org',
            Username = uniq + '@test' + orgId + '.org',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniq.substring(10, 15),
            TimeZoneSidKey =String.valueof(UserInfo.getTimeZone()),
            LocaleSidKey = userinfo.getLocale(),
            LanguageLocaleKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            UserRoleId = UserInfo.getUserRoleId(),
            OBA__c = '90463', 
            isActive = true
        );    
        insert u;
        
        //Service Resource
        ServiceResource sr = new ServiceResource();
        sr.Name = 'Test Resource';
        sr.ResourceType = 'T';
        sr.IsActive = true;
        sr.RelatedRecordId = u.Id;
        insert sr;
        
        //Service Territory Member
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId = sr.Id;
        stm.ServiceTerritoryId = st.Id;
        stm.EffectiveStartDate = Datetime.newInstance(2024, 7, 1, 8, 0, 0);
        insert stm;
        
        //Shift Pattern
        Shift_Pattern__c sp = new Shift_Pattern__c();
        sp.Name = 'Testing';
        sp.Service_Territory__c = st.Id;
        insert sp;
        
        Shift_Pattern__c sp1 = new Shift_Pattern__c();
        sp1.Name = 'Testing';
        sp1.Service_Territory__c = st.Id;
        sp1.Automatically_create_shifts__c = TRUE;
        insert sp1;

        Shift shift = new Shift();
        shift.StartTime = Datetime.newInstance(2024, 7, 1, 8, 0, 0);
        shift.EndTime = Datetime.newInstance(2024, 7, 1, 17, 0, 0);
        shift.Status = 'Tentative';
        shift.label = 'test shift for apex test';
        shift.Job_Profile__c = jp.id;
        shift.ServiceResourceId = sr.Id;
        insert shift;
    }

    @IsTest
    public static void validateCreateShiftWorkTopics(){

        Skill__c skillc = new Skill__c();
        skillc.Name = 'Prothesen';
        insert skillc;
        
        Job_Profile__c jp = [SELECT Id FROM Job_Profile__c WHERE Name = 'Job Profile to test' LIMIT 1];

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
//ShiftTriggerHandlerClass.createShiftWorkTopics(shiftList, null);
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
        //update shift;

         List<Shift> shiftList = new List <Shift>();
        shiftList.add(shift);

        Test.startTest();
        ShiftTriggerHandlerClass.deleteShiftWorkTopics(shiftList, null);
        Test.stopTest();
    }
}