@isTest(seeAllData=true)
public class KMSKAActivitiesCalendarControllerTest {
    @isTest
    public static void testActivityCalendar(){
        Map<String, String> res = KMSKAActivitiesCalendarController.getTypeValues();
        
        Calendar_Colour_Configuration__c ccc = new Calendar_Colour_Configuration__c();
        ccc.Calendar__c = 'Opportunity';
        ccc.Color__c = '#f6bf26';
        ccc.Type__c = 'Rondleiding';
        ccc.Name = 'Testclasss';
        insert ccc;
        
        
        res = KMSKAActivitiesCalendarController.getCalendarColors('Opportunity');
        
        Id activity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KMSKA Activities').getRecordTypeId();
        Id Organization = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        
        Account act = new Account(Name='Test Class',RecordTypeId = Organization);
        insert act;
        
        Contact con = new Contact(LastName='Test Class', AccountId= act.Id, Email='test@class.com');
        insert con;
        
        Opportunity opp = new Opportunity(Name='Test class', AccountId = act.Id, CloseDate = Date.today(), StageName='Geaccepteerd', Amount=100, RecordTypeId = activity);
        opp.Start_Time__c = Datetime.now();
        opp.End_Time__c = Datetime.now().addDays(2);
        opp.npsp__Primary_Contact__c = con.Id;
        opp.Participants__c = 10;
        insert opp;
        
        KMSKA_Product__c KP = new KMSKA_Product__c();
        KP.Start_Time__c =  Datetime.now().addMonths(-1);
        KP.End_Time__c = Datetime.now().addMonths(1); 
        KP.Comment__c = 'Testing';
        KP.Description__c = 'Testing';
        KP.Type__c = 'Rondleiding';
        insert KP; 
        
        Activity_Product__c AP = new Activity_Product__c();
        AP.Start_Time__c = Datetime.now().addMonths(-1);
        AP.End_Time__c = Datetime.now().addMonths(1);
        AP.Opportunity__c = opp.Id;
        AP.KMSKA_Product__c = KP.Id;
        
        insert AP;
        
        insert new Vacation__c(Name='Test', Start_date__c = Date.today() ,End_date__c = date.today(), Type__c = 'Vakantie');
        Map<String, List<Vacation__c>> vcMap = KMSKAActivitiesCalendarController.getVacations();
        List<KMSKAActivitiesCalendarController.calendarData> res1 = KMSKAActivitiesCalendarController.getData('Opportunity',null,false,'',Date.today().addDays(-50),Date.today().addDays(50));
        List<KMSKAActivitiesCalendarController.calendarData> res2 = KMSKAActivitiesCalendarController.getData('activitity',null,false,'',Date.today().addDays(-50),Date.today().addDays(50));
        List<KMSKAActivitiesCalendarController.calendarData> res3 = KMSKAActivitiesCalendarController.getData('activitity',null,true,'Alle',Date.today().addDays(-50),Date.today().addDays(50));
        List<KMSKAActivitiesCalendarController.calendarData> res4 = KMSKAActivitiesCalendarController.getData('activitity',null,true,'Rondleiding',Date.today().addDays(-50),Date.today().addDays(50));
        Id recTypeId = KMSKAActivitiesCalendarController.getRecordTypeId();
    }
}