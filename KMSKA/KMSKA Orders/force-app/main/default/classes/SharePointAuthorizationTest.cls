@isTest
public class SharePointAuthorizationTest {
	@isTest
    public static void getAuthInfoTest(){
        try{
           Sharepoint_Integration__c SI = SharePointAuthorization.getAuthInfo(); 
        }catch(Exception ex){
            System.assertEquals('Please configure credentials to Custom setting named "Sharepoint_Integration__c"', ex.getMessage());
        }
        
        Sharepoint_Integration__c SI = new Sharepoint_Integration__c();
        SI.Name = 'Test Class PS';
        SI.Tenant_Id__c = 'Test class TI';
        SI.Client_Id__c = 'Test Class CS';
        SI.Token_Endpoint__c = 'https://www.testclass.com';
        SI.Base_Endpoint__c = 'https://www.testclass.com';
        SI.Scope__c = 'Test';
        SI.Grant_Type__c = 'code';
        SI.List_Id__c = 'Test';
        SI.Site_Id__c = 'Test';
        SI.Parent_Folder_Name__c = 'Test';
        SI.Parent_Id__c = 'Test';
        insert SI;
        Sharepoint_Integration__c SINew = SharePointAuthorization.getAuthInfo(); 
        System.assertEquals(SI.Id, SINew.Id);
    }
    
    @IsTest
    public static void getAuthTokenTest(){
        Sharepoint_Integration__c SI = new Sharepoint_Integration__c();
        SI.Name = 'Test Class PS';
        SI.Tenant_Id__c = 'Test class TI';
        SI.Client_Id__c = 'Test Class CS';
        SI.Client_Secret__c = 'Test Class CS';
        SI.Token_Endpoint__c = 'https://www.testclass.com';
        SI.Base_Endpoint__c = 'https://www.testclass.com';
        SI.Scope__c = 'Test';
        SI.Grant_Type__c = 'code';
        SI.List_Id__c = 'Test';
        SI.Site_Id__c = 'Test';
        SI.Parent_Folder_Name__c = 'Test';
        SI.Parent_Id__c = 'Test';
        insert SI;
        
        String token = SharePointAuthorization.getAuthToken();
        System.assertEquals(true,(token!=null));
    }
    
    public static HttpResponse getAuthResponse(){
        HttpResponse res = new HttpResponse();
        res.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6Im5xMkgtRUNuMGhUUE81ZDN2aFJnT19lb09tS20xMXdmdUtMams5Vy"}');
    	res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}