@isTest(seeAllData=true)
public class SelectRoomsQuickActionControllerTest {
	@isTest
    public static void testSelectRoom(){
        Id activity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KMSKA Activities').getRecordTypeId();
        Id Organization = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        Id Assets = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get('Assets').getRecordTypeId();
        
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
        
        Map<String,object> res = SelectRoomsQuickActionController.getOpportunityRecord(opp.Id);
        
        KMSKA_Asset__c ka = new KMSKA_Asset__c();
        ka.Name = 'Test_Asset';
        ka.Total_Quantity__c = 10;
        //ka.Type__c = 'Projector';
        insert ka;
        
        Resource__c r = new Resource__c();
        r.RecordTypeId = Assets;
        r.Name = 'Test_resource';
        r.KMSKA_Asset__c = ka.Id;
        r.Type__c = 'Andere Asset';
        insert r;
        
        Assigned_Resource__c ar = new Assigned_Resource__c();
        ar.Quantity__c = 1;
        ar.KMSKA_Opportunity__c = opp.Id;
        ar.Resource__c = r.Id;
        ar.Start_Activity_Product__c = Datetime.now();
        ar.End_Activity_Product__c = Datetime.now().addMonths(1);
        
        SelectRoomsQuickActionController.saveAssignedResource(ar);
        List<Assigned_Resource__c> res1 = SelectRoomsQuickActionController.getAssignedResources();
    }
}