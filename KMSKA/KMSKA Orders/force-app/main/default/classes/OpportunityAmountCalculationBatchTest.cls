@isTest(SeeAllData=true)
public class OpportunityAmountCalculationBatchTest {
    @isTest
    public static void testCalculationBatch(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Tickets - 10-10-2000';
        opp.GT_Unique_ID__c = '123TestClass';
        opp.GT_Order_Date_Time__c = Date.today();
        opp.Rec_Type__c = 'order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today();
        opp.Membership_Renewed__c = false;
        insert opp;
        
        Order_Line__c ol = new Order_Line__c();
        ol.Price__c = 123;
        ol.Bruto_Price__c = 123;
        ol.Order__c = opp.Id;
        ol.Sub_Type__c = 'Normaal';
        ol.Quantity__c = 1;
        insert ol;
        
        Test.startTest();
        String sch = '0 0 23 * * ?';
        system.schedule('test now', sch, new OpportunityAmountCalculationBatch());
        //Database.executeBatch(new OpportunityAmountCalculationBatch(), 10);
        Test.stopTest();
    }
}