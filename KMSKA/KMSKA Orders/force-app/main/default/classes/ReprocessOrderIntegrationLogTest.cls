@isTest
public class ReprocessOrderIntegrationLogTest {
	@isTest
    public static void testIntegrationLogs(){
        Integration_Log__c IL = new Integration_Log__c();
        IL.Request_Date_Time__c = System.now();
        IL.Request_URL__c = 'test.com';
        IL.Request__c = '{}';
        IL.Request_Method__c = 'POST';
        IL.Response__c = '{}';
        IL.Response_Code__c = '400';
        IL.Response_Date_Time__c = System.now();
        insert IL;
        
        Test.startTest();
        new ReprocessOrderIntegrationLog().execute(null);
        
        //ReprocessOrderIntegrationLog ba= new ReprocessOrderIntegrationLog();
        //Database.executeBatch(ba,5);
        
        Test.stopTest();
    }
}