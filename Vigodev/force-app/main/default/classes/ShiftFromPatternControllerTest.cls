// LLP-1573

@IsTest
public with sharing class ShiftFromPatternControllerTest {
   @IsTest
   static void validateCreateShifts(){

    OperatingHours oh = new OperatingHours();
    oh.Name = 'test Or';
    insert oh;

    ServiceTerritory st = new ServiceTerritory();
    st.Name = 'test territory';
    st.OBA__c = '90463';
    st.IsActive = true;
    st.OperatingHoursId = oh.Id;
    insert st;

    Shift_Template__c sht = new Shift_Template__c();

    sht.Name = 'test Shift Template';
    sht.Start_Time__c = Time.newInstance(8, 0, 0, 0);
    sht.End_Time__c = Time.newInstance(17, 0, 0, 0);
    insert sht;

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
    insert sp;

    Shift_Pattern_Entry__c spe = new Shift_Pattern_Entry__c();
    spe.Shift_Pattern__c = sp.Id;
    spe.Week__c = '1';
    spe.Day__c = 'Monday';
    spe.Service_Resource__c = sr.Id;
    spe.Shift_Template__c = sht.Id;
    spe.Service_Resource__c = sr.Id;
    insert spe;

    Shift_Pattern_Entry__c spe2 = new Shift_Pattern_Entry__c();
    spe2.Shift_Pattern__c = sp.Id;
    spe2.Week__c = '2';
    spe2.Day__c = 'Tuesday';
    spe2.Shift_Template__c = sht.Id;
    spe2.Service_Resource__c = sr.Id;
    insert spe2;

    Shift_Pattern_Entry__c spe3 = new Shift_Pattern_Entry__c();
    spe3.Shift_Pattern__c = sp.Id;
    spe3.Week__c = '3';
    spe3.Day__c = 'Wednesday';
    spe3.Shift_Template__c = sht.Id;
    spe3.Service_Resource__c = sr.Id;
    insert spe3;

    Shift_Pattern_Entry__c spe4 = new Shift_Pattern_Entry__c();
    spe4.Shift_Pattern__c = sp.Id;
    spe4.Week__c = '4';
    spe4.Day__c = 'Thursday';
    spe4.Shift_Template__c = sht.Id;
    spe4.Service_Resource__c = sr.Id;
    insert spe4;

    Shift_Pattern_Entry__c spe5 = new Shift_Pattern_Entry__c();
    spe5.Shift_Pattern__c = sp.Id;
    spe5.Week__c = '1';
    spe5.Day__c = 'Friday';
    spe5.Shift_Template__c = sht.Id;
    spe5.Service_Resource__c = sr.Id;
    insert spe5;

    List<ShiftFromPatternController.shiftInput> ShiftInput = new List<ShiftFromPatternController.shiftInput>();
    ShiftFromPatternController.ShiftInput si = new ShiftFromPatternController.ShiftInput();

       si.StartDate = Date.newInstance(2024, 7, 29);
       si.endDate = Date.newInstance(2024, 8, 30);
       si.shiftPattern = sp.Id;
       si.status = 'Tentative';
       ShiftInput.add(si);

    ShiftFromPatternController.createShifts(ShiftInput);
    }
}