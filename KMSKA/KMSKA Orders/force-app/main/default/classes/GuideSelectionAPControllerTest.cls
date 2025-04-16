@isTest(seeAllData=true)
public class GuideSelectionAPControllerTest {
    @isTest
    public static void testGuideActivitySelectionController(){
        Id availabilitySingle = Schema.SObjectType.Availablility__c.getRecordTypeInfosByName().get('Single').getRecordTypeId();
        
        Map<String,String> langMap = GuideSelectionAPController.getLanguageMap();
        Map<String,String> targetAudMap = GuideSelectionAPController.getTargetAudienceMap();
        
        Availablility__c AV = new Availablility__c();
        AV.Start__c = Datetime.now();
        AV.End__c = Datetime.now().addMinutes(15);
        AV.Guide__c = UserInfo.getUserId();
        AV.RecordTypeId = availabilitySingle;
        insert AV;
        
        Availablility__c AV1 = new Availablility__c();
        AV1.Start__c = Datetime.now();
        AV1.End__c = Datetime.now().addDays(1).addMinutes(15);
        AV1.Guide__c = UserInfo.getUserId();
        AV1.RecordTypeId = availabilitySingle;
        insert AV1;
        
        
        Availablility__c AV2 = new Availablility__c();
        AV2.Start__c = Datetime.now();
        AV2.End__c = Datetime.now().addMinutes(15);
        AV2.Guide__c = UserInfo.getUserId();
        AV2.RecordTypeId = availabilitySingle;
        insert AV2;
        
        Availablility__c AV3 = new Availablility__c();
        AV3.Start__c = Datetime.now().addMinutes(10);
        AV3.End__c = Datetime.now().addHours(11);
        AV3.Guide__c = UserInfo.getUserId();
        AV3.RecordTypeId = availabilitySingle;
        insert AV3;
        
        Id activity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KMSKA Activities').getRecordTypeId();
        Id Organization = [SELECT Id  FROM   RecordType WHERE SobjectType = 'Account'  AND    DeveloperName = 'Organization'].Id;
        
        Account act = new Account(Name='Test Class',RecordTypeId = Organization);
        insert act;
        
        Contact con = new Contact(LastName='Test Class', AccountId= act.Id, Email='test@class.com', Talen__c = 'Nederlands', Doelgroep__c='1ste leerjaar');
        insert con;
        
        Opportunity opp = new Opportunity(Name='Test class', AccountId = act.Id, CloseDate = Date.today(), StageName='Geaccepteerd', Amount=100, RecordTypeId = activity);
        opp.Start_Time__c = Datetime.now();
        opp.End_Time__c = Datetime.now().addDays(2);
        opp.npsp__Primary_Contact__c = con.Id;
        opp.Participants__c = 10;
        opp.Taal__c = 'Nederlands';
        opp.Doelgroep__c = '1ste leerjaar';
        insert opp;
        
        KMSKA_Product__c KP = new KMSKA_Product__c();
        KP.Start_Time__c =  Datetime.now().addMonths(-1);
        KP.End_Time__c = Datetime.now().addMonths(1); 
        KP.Comment__c = 'Testing';
        KP.Description__c = 'Testing';
        insert KP; 
        
        Activity_Product__c AP1 = new Activity_Product__c();
        AP1.Start_Time__c = Datetime.now().addMinutes(10);
        AP1.End_Time__c = Datetime.now().addMinutes(15);
        AP1.Opportunity__c = opp.Id;
        AP1.KMSKA_Product__c = KP.Id;
        insert AP1;
        
        AP1 = GuideSelectionAPController.getActivityProduct(AP1.Id);
        
        List<GuideSelectionAPController.guideAvailability> guides = GuideSelectionAPController.getAvailableGuide(AP1.Id,'1ste leerjaar' , 'Nederlands');
        GuideSelectionAPController.guideAvailability guide = guides[0];
        guide.availabilityId = AV3.Id;
        guide.Assign = true;
        Map<String,Object> res = GuideSelectionAPController.assignGuide(AP1.Id,JSON.serialize(guide));
        
        System.assertEquals(true, langMap.size()>0);
    }
}