@isTest
public class GidsenAvailablilitiesCalendarCntrlTest {
    @isTest
    public static void testgetAllGuides (){
        Id single = Schema.SObjectType.Availablility__c.getRecordTypeInfosByName().get('Single').getRecordTypeId();
        Id recurring = Schema.SObjectType.Availablility__c.getRecordTypeInfosByName().get('Recurring').getRecordTypeId();
        
        Boolean isGuide = GidsenAvailablilitiesCalendarController.isLoggedUserGuide();
        Date recD = GidsenAvailablilitiesCalendarController.getRecurringDate(Datetime.now());
        
        Map<String,String> recTypes = GidsenAvailablilitiesCalendarController.getRecordTypes();
        Map<String,String> resMap = GidsenAvailablilitiesCalendarController.getAllGuides();
        List<Availablility__c> avalabilities = GidsenAvailablilitiesCalendarController.getAvailabilities('all','','');
        avalabilities = GidsenAvailablilitiesCalendarController.getAvailabilities(UserInfo.getUserId(),'','');
        
        Map<String,String> LanMap = GidsenAvailablilitiesCalendarController.getLanguageMap();
        Map<String,String> TargetAudMap = GidsenAvailablilitiesCalendarController.getTargetAudienceMap();
        
        
        Availablility__c av = new Availablility__c();
        av.Start__c = Datetime.now();
        av.End__c = Datetime.now();
        av.Guide__c = UserInfo.getUserId();
        av.RecordTypeId = single;
        Map<String,Object> res = GidsenAvailablilitiesCalendarController.saveAvailability(av);
        
        av.End__c = Datetime.now().addHours(2);
        res = GidsenAvailablilitiesCalendarController.saveAvailability(av);
        
        Map<String,Object> data = GidsenAvailablilitiesCalendarController.getData(UserInfo.getUserId(),'','');
        
        av = [SELECT Id, Start__c,End__c FROM Availablility__c LIMIT 1];
        av.Start__c = Datetime.now();
        av.End__c = Datetime.now();
        res = GidsenAvailablilitiesCalendarController.updateAvailability(av);
        av = GidsenAvailablilitiesCalendarController.getAvailability(av.Id);
        res = GidsenAvailablilitiesCalendarController.updateAvailability(av);
        
        av.Start__c = Datetime.now();
        av.End__c = Datetime.now().addHours(2);
        res = GidsenAvailablilitiesCalendarController.updateAvailability(av);
        
        av = GidsenAvailablilitiesCalendarController.getAvailability(av.Id);
        res = GidsenAvailablilitiesCalendarController.deleteAvailability(av);        
        
        Availablility__c avr = new Availablility__c();
        avr.Start__c = Datetime.now();
        avr.End__c = Datetime.now().addHours(1);
        avr.Guide__c = UserInfo.getUserId();
        avr.RecordTypeId = recurring;
        avr.Start_Recurring__c = Date.today();
        avr.End_Recurring__c = Date.today().addMonths(3);
        res = GidsenAvailablilitiesCalendarController.saveAvailability(avr);
        
        avr = [SELECT Id, Parent__c FROM Availablility__c LIMIT 1];
        GidsenAvailablilitiesCalendarController.deleteRecurringAvailability(avr, 'all');
        System.assertEquals(true, data!=null);
    }
}