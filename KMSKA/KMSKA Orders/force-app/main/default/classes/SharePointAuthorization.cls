public class SharePointAuthorization {
    public static Sharepoint_Integration__c getAuthInfo(){
        try{
            Sharepoint_Integration__c integrationCredentials = [SELECT Id, Name, Tenant_Id__c, Client_Id__c, Client_Secret__c, Token_Endpoint__c, 
                                                                Base_Endpoint__c, Scope__c, Grant_Type__c, List_Id__c, Site_Id__c,Parent_Id__c, Parent_Folder_Name__c 
                                                                FROM Sharepoint_Integration__c 
                                                                LIMIT 1
                                                               ];
            return integrationCredentials;    
        }catch(exception ex){
            throw new SharePointException('Please configure credentials to Custom setting named "Sharepoint_Integration__c"');
        }
    }
    
    public static String getAuthToken(){
        Sharepoint_Integration__c cred = getAuthInfo();
        
        String authURL = cred.Token_Endpoint__c;
        authURL = authURL.replace('{tenatid}', cred.Tenant_Id__c);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(authUrl);
        
        request.setMethod('POST');    
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String payload = 'client_id='+EncodingUtil.urlEncode(cred.Client_Id__c,'UTF-8')
            +'&client_secret='+EncodingUtil.urlEncode(cred.Client_Secret__c,'UTF-8')
            +'&scope='+EncodingUtil.urlEncode(cred.Scope__c,'UTF-8')
            +'&grant_type='+EncodingUtil.urlEncode(cred.Grant_Type__c,'UTF-8');
        
        request.setBody(payload);
        HttpResponse response;
        
        if(!Test.isRunningTest()){
            response  = http.send(request); 
        }else{
            response = SharePointAuthorizationTest.getAuthResponse();
        }
        
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            Map<String, Object> authResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return (String)authResponse.get('access_token');
        }
        return '';
    }
    
    
}