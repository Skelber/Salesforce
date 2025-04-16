@isTest(seeAllData=true)
public class ActivityProductTriggerTest {
    @isTest
    public static void testAvailabilityTrigger(){
        Id single = Schema.SObjectType.Availablility__c.getRecordTypeInfosByName().get('Single').getRecordTypeId();
        
        Availablility__c av = new Availablility__c();
        av.Start__c = Datetime.now().addHours(-2);
        av.End__c = Datetime.now().addHours(11);
        av.Guide__c = UserInfo.getUserId();
        av.RecordTypeId = single;
        insert av;
        
        Id activity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KMSKA Activities').getRecordTypeId();
        Id Organization = [SELECT Id  FROM   RecordType WHERE SobjectType = 'Account'  AND    DeveloperName = 'Organization'].Id;
        
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
        insert KP; 
        
        Activity_Product__c AP = new Activity_Product__c();
        AP.Start_Time__c = Datetime.now().addHours(2);
        AP.End_Time__c = Datetime.now().addHours(3);
        AP.Opportunity__c = opp.Id;
        AP.KMSKA_Product__c = KP.Id;
        AP.Availablility__c = av.Id;
        Test.startTest();
        insert AP;
        
        System.assertEquals(true, AP.Id!=null);
    }
    
    @isTest
    public static void testAvailabilityTriggerMerge(){
        Id single = Schema.SObjectType.Availablility__c.getRecordTypeInfosByName().get('Single').getRecordTypeId();
        
        Availablility__c av = new Availablility__c();
        av.Start__c = Datetime.now().addHours(-2);
        av.End__c = Datetime.now().addHours(11);
        av.Guide__c = UserInfo.getUserId();
        av.RecordTypeId = single;
        insert av;
        
        Id activity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KMSKA Activities').getRecordTypeId();
        Id Organization = [SELECT Id  FROM   RecordType WHERE SobjectType = 'Account'  AND    DeveloperName = 'Organization'].Id;
        
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
        insert KP; 
        
        Activity_Product__c AP = new Activity_Product__c();
        AP.Start_Time__c = Datetime.now().addHours(2);
        AP.End_Time__c = Datetime.now().addHours(3);
        AP.Opportunity__c = opp.Id;
        AP.KMSKA_Product__c = KP.Id;
        AP.Availablility__c = av.Id;
        Test.startTest();
        insert AP;
        
        AP.Availablility__c = null;
        update AP;
        
        System.assertEquals(true, AP.Id!=null);
    }
    
    @isTest
    public static void testRecurringAvailabilityTrigger(){
        Id recurring = Schema.SObjectType.Availablility__c.getRecordTypeInfosByName().get('Recurring').getRecordTypeId();
        
        Availablility__c av = new Availablility__c();
        av.Start__c = Datetime.now().addHours(-2);
        av.End__c = Datetime.now().addHours(11);
        av.Start_Recurring__c = Date.today();
        av.End_Recurring__c = Date.today().addDays(50);
        av.Guide__c = UserInfo.getUserId();
        av.RecordTypeId = recurring;
        insert av;
        
        Id activity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KMSKA Activities').getRecordTypeId();
        Id Organization = [SELECT Id  FROM   RecordType WHERE SobjectType = 'Account'  AND    DeveloperName = 'Organization'].Id;
        
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
        insert KP; 
        
        Activity_Product__c AP = new Activity_Product__c();
        AP.Start_Time__c = Datetime.now().addHours(2);
        AP.End_Time__c = Datetime.now().addHours(3);
        AP.Opportunity__c = opp.Id;
        AP.KMSKA_Product__c = KP.Id;
        AP.Availablility__c = av.Id;
        Test.startTest();
        insert AP;
        
        System.assertEquals(true, AP.Id!=null);
    }
    
}