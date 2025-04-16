@isTest(seeAllData=true)
public class GuideActivitySelectionControllerTest {
    @isTest
    public static void testGuideActivitySelectionController(){
        Id single = Schema.SObjectType.Availablility__c.getRecordTypeInfosByName().get('Single').getRecordTypeId();
        
        Boolean isLoggedUserGuide = GuideActivitySelectionController.isLoggedUserGuide();
        Map<String,Object> response = GuideActivitySelectionController.getMonthLabel(Date.today());
        response = GuideActivitySelectionController.getNextMonth((Date)response.get('toDate'));
        response = GuideActivitySelectionController.getPreviousMonth((Date)response.get('fromDate'));
        
        Availablility__c AV = new Availablility__c();
        AV.Start__c = Datetime.now();
        AV.End__c = Datetime.now().addMinutes(15);
        AV.Guide__c = UserInfo.getUserId();
        AV.RecordTypeId = single;
        insert AV;
        
        Availablility__c AV1 = new Availablility__c();
        AV1.Start__c = Datetime.now().addMonths(1);
        AV1.End__c = Datetime.now().addMonths(1).addMinutes(15);
        AV1.Guide__c = UserInfo.getUserId();
        AV1.RecordTypeId = single;
        insert AV1;
        
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
        opp.StageName = 'Geaccepteerd';
        opp.Stuur_naar_gidsen_platform__c = true;
        insert opp;
        
        KMSKA_Product__c KP = new KMSKA_Product__c();
        KP.Start_Time__c =  Datetime.now().addMonths(-1);
        KP.End_Time__c = Datetime.now().addMonths(1); 
        KP.Comment__c = 'Testing';
        KP.Description__c = 'Testing';
        insert KP; 
        
        Activity_Product__c AP = new Activity_Product__c();
        AP.Start_Time__c = Datetime.now();
        AP.End_Time__c = Datetime.now().addMinutes(15);
        AP.Opportunity__c = opp.Id;
        AP.KMSKA_Product__c = KP.Id;
        AP.Availablility__c = AV.Id;
        AP.Taal__c = 'Nederlands';
        AP.Doelgroep__c = '1ste leerjaar';
        insert AP;
        
        Activity_Product__c AP1 = new Activity_Product__c();
        AP1.Start_Time__c = Datetime.now().addMonths(1);
        AP1.End_Time__c = Datetime.now().addMonths(1).addMinutes(10);
        AP1.Opportunity__c = opp.Id;
        AP1.KMSKA_Product__c = KP.Id;
        AP1.Taal__c = 'Nederlands';
        AP1.Doelgroep__c = '1ste leerjaar';
        insert AP1;
        
        List<GuideActivitySelectionController.activityData> assignedTours = GuideActivitySelectionController.AssignedActivityProducts(UserInfo.getUserId(),Date.today().toStartOfMonth(),Date.today().addMonths(1));
        List<GuideActivitySelectionController.activityData> upcomingTours = GuideActivitySelectionController.UpCommingActivityProducts(UserInfo.getUserId(),Date.today(),Date.today().addMonths(2));
        List<GuideActivitySelectionController.activityData> tourSelection = new List<GuideActivitySelectionController.activityData>();
        for(GuideActivitySelectionController.activityData ad : upcomingTours){
            ad.isSelected = true;
            tourSelection.add(ad);
        }
        
        Map<String,Object> res = GuideActivitySelectionController.saveActivitySelection(tourSelection);
        
        System.assertEquals(false, isLoggedUserGuide);
    }
}