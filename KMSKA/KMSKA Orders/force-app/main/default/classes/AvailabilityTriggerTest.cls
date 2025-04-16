@isTest(seeAllData=true)
public class AvailabilityTriggerTest {
    @isTest
    public static void testAvailabilityTrigger(){
        Availablility__c av = new Availablility__c();
        av.Start__c = Datetime.now();
        av.End__c = Datetime.now().addHours(1);
        av.Guide__c = UserInfo.getUserId();
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
        AP.Start_Time__c = Datetime.now().addMonths(-1);
        AP.End_Time__c = Datetime.now().addMonths(1);
        AP.Opportunity__c = opp.Id;
        AP.KMSKA_Product__c = KP.Id;
        AP.Availablility__c = av.Id;
        insert AP;
        
        try{
            Delete av;  
        }catch(exception ex){
            
        }
        Availablility__c av1 = [SELECT Id FROM Availablility__c WHERE Id =: av.Id];
        System.assertEquals(true, av1.Id!=null);
    }
    
    @isTest
    public static void testAvailabilityRecurringTrigger(){
        Id singleRecordTypeId; Id recurringRecordTypeId;
        List<RecordType> recTypes = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Availablility__c'];
        for(RecordType r: recTypes){
            if(r.Name=='Recurring')
                recurringRecordTypeId = r.Id;
        }
        
        Availablility__c av = new Availablility__c();
        av.Start__c = Datetime.now();
        av.End__c = Datetime.now().addHours(1);
        av.Guide__c = UserInfo.getUserId();
        av.Parent__c = true;
        av.Start_Recurring__c = Date.today();
        av.End_Recurring__c = Date.today().addDays(40);
        av.RecordTypeId = recurringRecordTypeId;
        insert av;
        
        Availablility__c avc1 = new Availablility__c();
        avc1.Start__c = Datetime.now().addDays(7);
        avc1.End__c = Datetime.now().addHours(1).addDays(7);
        avc1.Guide__c = UserInfo.getUserId();
        avc1.Parent__c = true;
        avc1.Start_Recurring__c = Date.today();
        avc1.End_Recurring__c = Date.today().addDays(40);
        avc1.Parent_Availablility__c = av.Id;
        avc1.RecordTypeId = recurringRecordTypeId;
        insert avc1;
        
        Availablility__c avc2 = new Availablility__c();
        avc2.Start__c = Datetime.now().addDays(14);
        avc2.End__c = Datetime.now().addHours(1).addDays(14);
        avc2.Guide__c = UserInfo.getUserId();
        avc2.Parent__c = true;
        avc2.Start_Recurring__c = Date.today();
        avc2.End_Recurring__c = Date.today().addDays(40);
        avc2.Parent_Availablility__c = av.Id;
        avc2.RecordTypeId = recurringRecordTypeId;
        insert avc2;
        
        av.End_Recurring__c = Date.today().addDays(10);
        update av;
        
        av.End_Recurring__c = Date.today().addDays(50);
        update av;
    }
}