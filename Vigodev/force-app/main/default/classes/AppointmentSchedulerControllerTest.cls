// LLP-1573

@IsTest
public without sharing class AppointmentSchedulerControllerTest {

       @testSetup static void createData() {

     Account acc = new Account();
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            acc.FirstName= 'testAccountApex';
            acc.LastName= 'patient';
            acc.OBA__c ='90463';
            // acc.Name = 'Test patient';
            insert acc;
    }

   public static User createSystemAdministratorUser(){
        String orgId = UserInfo.getOrganizationId();
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniq =orgId+randomInt;
        User tuser = new User(
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
            UserRoleId = UserInfo.getUserRoleId()
        );    
        insert tuser;
        System.assert((tuser.Id != null), 'User is created');
        return tuser;
    }
   
   @IsTest 
   static void validateGetWorkType(){

    WorkTypeGroup wtg = new WorkTypeGroup();
    wtg.Name = 'test Work Type Group';
    wtg.Business_Unit__c = 'Orthotics';
    wtg.Product_Group__c = 'Head';
    wtg.Product_SubGroup__c = 'Ear mask';
    wtg.Appointment_Type__c = 'Maintenance';
    insert wtg;

    WorkType wt = new WorkType();
    wt.Name = 'Test';
    wt.EstimatedDuration = 60;
    wt.DurationType = 'Minutes';
    insert wt;

    WorkTypeGroupMember wtgm = new WorkTypeGroupMember();
    wtgm.WorkTypeId = wt.Id;
    wtgm.WorkTypeGroupId = wtg.Id;
    insert wtgm;

    AppointmentSchedulerController.getWorkType(wtg.Business_Unit__c, wtg.Product_Group__c, wtg.Product_SubGroup__c, wtg.Appointment_Type__c);


    List<WorkTypeGroupMember> wts = [SELECT Id, Name FROM WorkTypeGroupMember WHERE 
    WorktypeGroup.Business_Unit__c = :wtg.Business_Unit__c AND 
    WorktypeGroup.Product_Group__c = :wtg.Product_Group__c AND 
    WorktypeGroup.Product_SubGroup__c = :wtg.Product_SubGroup__c AND 
    WorktypeGroup.Appointment_Type__c = :wtg.Appointment_Type__c];
    System.assertEquals(1, wts.size());

   }

   @IsTest
   static void validateGetData(){

        Date currentdate = Date.newInstance(2024, 7, 22);
        String bu = 'Orthotics';
        String pg = 'Head';
        String psg = 'Ear mask';
        String at = 'Maintenance';
        String dayValue = 'All';
        String TimeValue = 'All Day';
        String businessunit = 'test';

         system.runAs(createSystemAdministratorUser()){

      Account acc = [SELECT Id FROM Account WHERE FirstName = 'testAccountApex' LIMIT 1];


        WorkTypeGroup wtg = new WorkTypeGroup();
        wtg.Name = 'test Work Type Group';
        wtg.Business_Unit__c = bu;
        wtg.Product_Group__c = pg;
        wtg.Product_SubGroup__c = psg;
        wtg.Appointment_Type__c = at;
        insert wtg;

        WorkType wt = new WorkType();
        wt.Name = 'Test';
        wt.EstimatedDuration = 60;
        wt.DurationType = 'Minutes';
        insert wt;

        WorkTypeGroupMember wtgm = new WorkTypeGroupMember();
        wtgm.WorkTypeId = wt.Id;
        wtgm.WorkTypeGroupId = wtg.Id;
        insert wtgm;

        OperatingHours oh = new OperatingHours();
        oh.Name = 'test Or';
        insert oh;

        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'test territory';
        st.OBA__c = 'Global';
        st.OperatingHoursId = oh.Id;
        insert st;

        Integer duration = 30;
      
      User u = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

      ServiceResource sr = new ServiceResource();
      sr.Name = 'Test Resource';
      sr.ResourceType = 'T';
      sr.IsActive = true;
      sr.RelatedRecordId = u.Id;
      insert sr;

      List <String> srIds = new List <String>();
      srIds.add(sr.Id);

        String expectedResponse = '[' +
                                    // '  {' +
                                    // '    \"startTime\": \"2024-07-22T16:00:00.000+0000\",' +
                                    // '    \"endTime\": \"2024-07-22T17:00:00.000+0000\",' +
                                    // '    \"resources\": [' +
                                    // '      \" '+ sr.Id + '\"' +
                                    // '    ],' +
                                    // '    \"territoryId\": \"'+ st.Id +'\"' +
                                    // '  },' +
                                    '  {' +
                                    '    \"startTime\": \"2021-03-18T19:00:00.000+0000\",' +
                                    '    \"endTime\": \"2021-03-18T20:00:00.000+0000\",' +
                                    '    \"resources\": [' +
                                    '      \"' + sr.id + '\"' +
                                    '    ],' +
                                    '    \"territoryId\": \"'+ st.Id +'\"' +
                                    '  }' +
                                    ']';
         lxscheduler.SchedulerResources.setAppointmentCandidatesMock(expectedResponse);

      AppointmentSchedulerController.getData(new List<String>{sr.Id}, acc.Id, new List<String>{st.Id}, wt.id, bu, pg, psg, at, dayValue, TimeValue, currentdate, duration);
   }
}

@isTest
 static void validateGetMultiResourceData(){

        Date currentdate = Date.newInstance(2024, 7, 22);
        String bu = 'Orthotics';
        String pg = 'Head';
        String psg = 'Ear mask';
        String at = 'Maintenance';
        String dayValue = 'All';
        String TimeValue = 'All Day';
        String businessunit = 'test';

         system.runAs(createSystemAdministratorUser()){

            Account acc = [SELECT Id FROM Account WHERE FirstName = 'testAccountApex' LIMIT 1];


        WorkTypeGroup wtg = new WorkTypeGroup();
        wtg.Name = 'test Work Type Group';
        wtg.Business_Unit__c = bu;
        wtg.Product_Group__c = pg;
        wtg.Product_SubGroup__c = psg;
        wtg.Appointment_Type__c = at;
        insert wtg;

        WorkType wt = new WorkType();
        wt.Name = 'Test';
        wt.EstimatedDuration = 60;
        wt.DurationType = 'Minutes';
        insert wt;

        WorkTypeGroupMember wtgm = new WorkTypeGroupMember();
        wtgm.WorkTypeId = wt.Id;
        wtgm.WorkTypeGroupId = wtg.Id;
        insert wtgm;

        OperatingHours oh = new OperatingHours();
        oh.Name = 'test Or';
        insert oh;

        ServiceTerritory mrst = new ServiceTerritory();
        mrst.Name = 'test territory';
        mrst.OBA__c = 'Global';
        mrst.OperatingHoursId = oh.Id;
        insert mrst;

        Integer duration = 30;
      
      User u = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
      
      List <String> srIds = new List <String>();
      
      ServiceResource mrsr = new ServiceResource();
      mrsr.Name = 'Test Resource';
      mrsr.ResourceType = 'T';
      mrsr.IsActive = true;
      mrsr.RelatedRecordId = u.Id;
      insert mrsr;
      srIds.add(mrsr.Id);

      String orgId = UserInfo.getOrganizationId();
      Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
      String uniq =orgId+randomInt;
      User tuser2 = new User(
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
            UserRoleId = UserInfo.getUserRoleId()
        );    
        insert tuser2;
        System.debug('test user ' + tuser2);

      ServiceResource mrsr2 = new ServiceResource();
      mrsr2.Name = 'Test Resource2';
      mrsr2.ResourceType = 'T';
      mrsr2.IsActive = true;
      mrsr2.RelatedRecordId = tuser2.Id;
      insert mrsr2;
      srIds.add(mrsr2.Id);

      System.debug('mrsr id' + mrsr.id);
      System.debug('mrst id' + mrst.id);
      System.debug('mrsr2 id' + mrsr2.id);


      String expectedResponse = '[' +
                                    // '  {' +
                                    // '    \"startTime\": \"2024-07-22T16:00:00.000+0000\",' +
                                    // '    \"endTime\": \"2024-07-22T17:00:00.000+0000\",' +
                                    // '    \"resources\": [' +
                                    // '      \" '+ mrsr2.Id + '\"' +
                                    // '    ],' +
                                    // '    \"territoryId\": \"'+ mrst.Id +'\"' +
                                    // '  },' +
                                    '  {' +
                                    '    \"startTime\": \"2021-03-18T19:00:00.000+0000\",' +
                                    '    \"endTime\": \"2021-03-18T20:00:00.000+0000\",' +
                                    '    \"resources\": [' +
                                    '      \"' + mrsr.id + '\"' +
                                    '    ],' +
                                    '    \"territoryId\": \"'+ mrst.Id +'\"' +
                                    '  }' +
                                    ']';
         lxscheduler.SchedulerResources.setAppointmentSlotsMock(expectedResponse);

      Test.startTest();
      AppointmentSchedulerController.getMultiResourceData(new List<String>{mrsr.id, mrsr2.id}, acc.Id, new List<String>{mrst.Id}, wt.id, bu, pg, psg, at, dayValue, TimeValue, currentdate, duration);
      Test.stopTest();
   }
}


@isTest
static void valdiateCreateServiceAppointment(){

   Datetime startTime = Datetime.newInstance(2024, 07, 29, 10, 00, 0);
   Datetime endTime = Datetime.newInstance(2024, 07, 29, 11, 00, 0);
   Decimal duration = 60;

   OperatingHours oh = new OperatingHours();
   oh.Name = 'test Or';
   insert oh;

   ServiceTerritory st = new ServiceTerritory();
   st.Name = 'test territory';
   st.OBA__c = 'Global';
   st.IsActive = true;
   st.OperatingHoursId = oh.Id;
   insert st;
   
   User u = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

   ServiceResource sr = new ServiceResource();
   sr.Name = 'Test Resource';
   sr.ResourceType = 'T';
   sr.IsActive = true;
   sr.RelatedRecordId = u.Id;
   insert sr;

   Account acc = [SELECT Id FROM Account WHERE FirstName = 'testAccountApex' LIMIT 1];

   WorkType wt = new WorkType();
   wt.Name = 'Test';
   wt.EstimatedDuration = 60;
   wt.DurationType = 'Minutes';
   insert wt;

   String sr2Id = null;

   AppointmentSchedulerController.createServiceAppointment(st.Id, startTime, endTime, acc.Id, sr.Id, sr2Id, wt.Id, 'test description', duration);
}

   @isTest
   static void validateCalculateWeekDays(){
      Date startDate = Date.newInstance(2024, 07, 29);

      AppointmentSchedulerController.calculateWeekdays(startDate);
      
   }

   @isTest
   static void validateSetDate(){
      Date currentDate = Date.newInstance(2024, 07, 29);
      String actionName = 'Next';

      AppointmentSchedulerController.setDate(currentDate, actionName);
   }

   @isTest
   static void validateCalculateDays(){
      Date startDate = Date.newInstance(2024, 07, 29);
      String dayOfWeek = 'Tue';

      AppointmentSchedulerController.calculatedays(startDate, dayOfWeek);
   }
}