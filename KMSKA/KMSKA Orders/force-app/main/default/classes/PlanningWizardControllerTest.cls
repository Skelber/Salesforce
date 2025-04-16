@isTest(seeAllData=true)
public class PlanningWizardControllerTest {
    @isTest
    public static void testGeneralMethods(){
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
        
        Room__c room = new Room__c(Name='Test Resource');
        insert room;
        
        Planning__c plan = new Planning__c(Start__c = Datetime.now(), End__c = Datetime.now().addDays(1), 
                                           KMSKA_Activity__c = opp.Id, Description__c = 'Test Class');
        insert plan;
        
        Planning__c plan2 = new Planning__c(Start__c = Datetime.now(), End__c = Datetime.now().addDays(1), 
                                           KMSKA_Activity__c = opp.Id, Description__c = 'Test Class', Room__c=room.Id);
        insert plan2;
        
        Date toDate = PlanningWizardController.getToday();
        
        Planning__c newPlan = new Planning__c(Start__c = Datetime.now(), End__c = Datetime.now().addDays(1), 
                                              KMSKA_Activity__c = opp.Id, Description__c = 'Test Class');
        
        Map<String,Object> resSave = PlanningWizardController.savePlanning(opp.Id,newPlan);
        
        
        plan = PlanningWizardController.getPlanningRecord(plan.Id);
        Map<Date, List<PlanningWizardController.Plannings>> res =  PlanningWizardController.getPlannings(opp.Id);
        Map<String,object> datares = PlanningWizardController.getOpportunityRecord(opp.Id);
        List<Room__c> rooms = PlanningWizardController.getResources('Test');
        rooms = PlanningWizardController.getResources('');
        List<Planning__c> planRes = PlanningWizardController.getAssignedResources(plan);
        PlanningWizardController.deletePlanningRecord(plan);
    }
}