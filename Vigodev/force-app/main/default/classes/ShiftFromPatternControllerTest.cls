// LLP-1575

@IsTest
public with sharing class ShiftFromPatternControllerTest {
    
    @IsTest
    static void validateCreateShifts(){
        
        Shift_planning__c cs = new Shift_planning__c();
        cs.Maximum_number_of_weeks__c = 36;
        cs.Minimal_number_of_weeks__c = 24;
        insert cs;
        
        OperatingHours oh = new OperatingHours();
        oh.Name = 'test Or';
        insert oh;
        
        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'test territory';
        st.OBA__c = '90463';
        st.IsActive = true;
        st.OperatingHoursId = oh.Id;
        insert st;
        
        Job_Profile__c jp = new Job_Profile__c();
        jp.Name = 'Job Profile';
        jp.All_work_types_supported__c = true;
        insert jp;
        
        Job_Profile__c jp1 = new Job_Profile__c();
        jp1.Name = 'Job Profile';
        insert jp1;
        
        Job_Profile_Skill__c jps = new Job_Profile_Skill__c();
        jps.Job_Profile__c = jp.Id;
        //jps.Skill__c = sk.id;
        insert jps;
        
        Job_Profile_Skill__c jps1 = new Job_Profile_Skill__c();
        jps1.Job_Profile__c = jp1.Id;
        //jps.Skill__c = sk.id;
        insert jps1;
        
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
        
        //  User u = [SELECT Id FROM User WHERE OBA__c = '90463' LIMIT 1];
        
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
            OBA__c = '90463'
        );    
        insert u;
        
        ServiceResource sr = new ServiceResource();
        sr.Name = 'Test Resource';
        sr.ResourceType = 'T';
        sr.IsActive = true;
        sr.RelatedRecordId = u.Id;
        insert sr;
        
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId = sr.Id;
        stm.ServiceTerritoryId = st.Id;
        stm.EffectiveStartDate = Datetime.newInstance(2024, 7, 1, 8, 0, 0);
        insert stm;
        
        Shift_Pattern__c sp = new Shift_Pattern__c();
        sp.Name = 'Testing';
        sp.Service_Territory__c = st.Id;
        sp.Automatically_create_shifts__c = true;
        insert sp;
        
        Shift_Pattern_Entry__c spe = new Shift_Pattern_Entry__c();
        spe.Shift_Pattern__c = sp.Id;
        spe.Day_s__c = 'Monday';
        spe.Service_Resource__c = sr.Id;
        spe.Shift_Template__c = sht.Id;
        spe.Service_Resource__c = sr.Id;
        insert spe;
        
        Shift_Pattern_Entry__c spe2 = new Shift_Pattern_Entry__c();
        spe2.Shift_Pattern__c = sp.Id;
        spe2.Day_s__c = 'Tuesday';
        spe2.Shift_Template__c = sht.Id;
        spe2.Service_Resource__c = sr.Id;
        insert spe2;
        
        Shift_Pattern_Entry__c spe3 = new Shift_Pattern_Entry__c();
        spe3.Shift_Pattern__c = sp.Id;
        spe3.Day_s__c = 'Wednesday';
        spe3.Valid_from__c = System.today();
        spe3.Shift_Template__c = sht.Id;
        spe3.Service_Resource__c = sr.Id;
        insert spe3;
        
        spe3.TF_End_of_Planning__c = System.today() - 7;
        update spe3;
        
        spe3.Valid_until__c = System.today() + 7;
        update spe3;        
        
        Shift_Pattern_Entry__c spe4 = new Shift_Pattern_Entry__c();
        spe4.Shift_Pattern__c = sp.Id;
        spe4.Day_s__c = 'Thursday';
        spe3.Valid_from__c = System.today();
        spe4.Shift_Template__c = sht1.Id;
        spe4.Service_Resource__c = sr.Id;
        insert spe4;
        
        Shift_Pattern_Entry__c spe5 = new Shift_Pattern_Entry__c();
        spe5.Shift_Pattern__c = sp.Id;
        spe5.Day_s__c = 'Friday';
        spe3.Valid_from__c = System.today()-50;
        spe5.TF_End_of_Planning__c = System.today()-2;
        spe5.Shift_Template__c = sht.Id;
        spe5.Service_Resource__c = sr.Id;
        insert spe5;
        
/*        List<ShiftFromPatternController.shiftInput> ShiftInput = new List<ShiftFromPatternController.shiftInput>();
        ShiftFromPatternController.ShiftInput si = new ShiftFromPatternController.ShiftInput();
        
        si.StartDate = Date.newInstance(2024, 7, 29);
        si.endDate = Date.newInstance(2024, 8, 30);
        si.shiftPattern = sp.Id;
        si.status = 'Tentative';
        ShiftInput.add(si);
      
        ShiftFromPatternController.createShifts(ShiftInput);
*/          
        

        
        Database.executeBatch(new ShiftFromPatternAutoNew(), 200);
        
        Shift s = new Shift();
        s.StartTime = System.now();
        s.EndTime = System.now() + 1000;
        s.Job_Profile__c = jp.Id;
        
        Shift s1 = new Shift();
        s1.StartTime = System.now();
        s1.EndTime = System.now() + 1000;
        s1.Job_Profile__c = jp.Id;
        insert s1;
        
        Database.executeBatch(new ShiftBatchClass(new List<Shift>{s}), 200);
        Database.executeBatch(new ShiftBatchClass(new List<Shift>{}), 200);
        
        ScheduledBatchable m = new ScheduledBatchable();
        String sch = '0 0 2 * * ?';
        String jobID = System.schedule('Auto Renew Shift Pattern Entries Job', sch, m);
        
        s1.Status = 'Tentative';
        s1.Job_Profile__c = jp1.Id;
        update s1;
    }
    
}