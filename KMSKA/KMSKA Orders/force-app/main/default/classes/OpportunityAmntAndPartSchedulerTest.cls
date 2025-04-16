@isTest(SeeAllData=true)
public class OpportunityAmntAndPartSchedulerTest {
    @isTest
    public static void testOrderLineTrigger(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Tickets - 1st';
        opp.GT_Unique_ID__c = '123TestClass';
        opp.GT_Order_Date_Time__c = Date.today();
        opp.Rec_Type__c = 'membership';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today();
        insert opp;
        
        Order_Line__c ol = new Order_Line__c();
        ol.Price__c = 123;
        ol.Bruto_Price__c = 123;
        ol.Order__c = opp.Id;
        ol.Sub_Type__c = 'Normaal';
        ol.Quantity__c = 1;
        insert ol;
        
        Order_Line__c ol2 = new Order_Line__c();
        ol2.Price__c = 123;
        ol2.Bruto_Price__c = 123;
        ol2.Order__c = opp.Id;
        ol2.Quantity__c = 1;
        insert ol2;
        Test.startTest();
        new OpportunityAmountAndParticipantScheduler().execute(null);
        Set<Id> oppId = new Set<Id>();
        oppId.add(opp.Id);
        OpportunityAmountAndParticipantScheduler.calculateAmountAndParticipants(oppId);
    }
}