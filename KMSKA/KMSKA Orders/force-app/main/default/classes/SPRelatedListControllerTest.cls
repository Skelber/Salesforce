@isTest
public class SPRelatedListControllerTest {
    @isTest
    public static void testGetAllItem(){
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
        
        Map<String,Object> resMap = SPRelatedListController.getAllItems();
        System.assertEquals(true, !resMap.isEmpty());
    }
}