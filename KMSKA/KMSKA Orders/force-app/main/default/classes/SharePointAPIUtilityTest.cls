@isTest
public class SharePointAPIUtilityTest {
    
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
        
        String token = SharePointAPIUtility.getAuthToken();
        System.assertEquals(true,(token!=null));
    }
    
    @isTest
    public static void getAllItemsTest(){
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
        
        SharePointAllItemWrapper sw = SharePointAPIUtility.getAllItems(SI.Base_Endpoint__c,SI.Site_Id__c,SI.List_Id__c);
        System.assertEquals(true,sw!=null);
    }
    
    @isTest
    public static void getDownloadURLTest(){
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
        
        Map<String, Object> Dmap = SharePointAPIUtility.getDownloadURL(SI.Base_Endpoint__c,SI.Site_Id__c,SI.List_Id__c,'1');
        System.assertEquals(true,Dmap!=null);
    }
    
    @isTest
    public static void getPreviewURLTest(){
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
        
        Map<String, Object> Dmap = SharePointAPIUtility.getPreviewURL(SI.Base_Endpoint__c,SI.Site_Id__c,'1');
        System.assertEquals(true,Dmap!=null);
    }
    
    public static HttpResponse getItems(){
        HttpResponse res = new HttpResponse();
        res.setBody('{"value":[{"eTag":"11","id":"4","webUrl":"https://test.sharepoint.com","parentReference":{"id":"1","siteId":"1"},"contentType":{"id":"1","name":"Map"},"fields":{"id":"2","ContentType":"Document","LinkFilenameNoMenu":"Plattegrond_niveau_4_tafelblad.jpg","LinkFilename":"Plattegrond_niveau_4_tafelblad.jpg"}},{"eTag":"12","id":"13","webUrl":"https://test.sharepoint.com","parentReference":{"id":"11","siteId":"1"},"contentType":{"id":"2","name":"Document"},"fields":{"id":"2","ContentType":"Document","LinkFilenameNoMenu":"Plattegrond_niveau_4_tafelblad.jpg","LinkFilename":"Plattegrond_niveau_4_tafelblad.jpg"}}]}');
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
    
    public static HttpResponse getResponse(){
        HttpResponse res = new HttpResponse();
        res.setBody('{"getUrl":"https://www.test.com","@microsoft.graph.downloadUrl":"https://www.test.com"}');
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}