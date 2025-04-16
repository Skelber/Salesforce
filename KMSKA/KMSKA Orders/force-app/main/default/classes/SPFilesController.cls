public class SPFilesController {
	
    @AuraEnabled
    public static String previewFile(String itemId){
        Sharepoint_Integration__c SI = SharePointAuthorization.getAuthInfo();
        
        Map<String, Object> driveInfo = SharePointAPIUtility.getDownloadURL(SI.Base_Endpoint__c, SI.Site_Id__c, SI.List_Id__c,itemId);
        Map<String, Object> previewInfo = SharePointAPIUtility.getPreviewURL(SI.Base_Endpoint__c, SI.Site_Id__c,(String)driveInfo.get('id'));
        return (String)previewInfo.get('getUrl');
    }
    
    @AuraEnabled
    public static String downloadFile(String itemId){
        Sharepoint_Integration__c SI = SharePointAuthorization.getAuthInfo();
        
        Map<String, Object> driveInfo = SharePointAPIUtility.getDownloadURL(SI.Base_Endpoint__c, SI.Site_Id__c, SI.List_Id__c,itemId);
        return (String)driveInfo.get('@microsoft.graph.downloadUrl');
    }
}