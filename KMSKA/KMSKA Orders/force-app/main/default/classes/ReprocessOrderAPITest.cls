@isTest(SeeAllData=true)
public class ReprocessOrderAPITest {
    
    @isTest
    public static void testReprocessOrderAPI(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test 1st';
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
        
        Test.startTest();
        ReprocessOrderAPI ba= new ReprocessOrderAPI();
        Id jobid= Database.executeBatch(ba,50);
        Test.stopTest();
    }
}