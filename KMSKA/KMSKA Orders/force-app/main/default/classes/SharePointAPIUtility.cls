public class SharePointAPIUtility {
    
    public static string getAuthToken(){
        String token = SharePointAuthorization.getAuthToken();
        if(token!=''){
            return token;
        }else{
            throw new SharePointException('Error while getting Auth Token.');
        }
    }
    
    public static SharePointAllItemWrapper getAllItems(String baseEndpoint, String siteId, String listId){
        String endpoint = baseEndpoint+'/sites/'+siteId+'/lists/'+listId+'/items?expand=fields';
        String bearerToken = getAuthToken();
        
        HttpResponse response = spCallout(endpoint,bearerToken);
        
        if (response.getStatusCode() != 200) {
            throw new SharePointException('API Error : ' + response.getBody());
        } else {
            SharePointAllItemWrapper responseData = handleResponse(response.getBody(),bearerToken);
            return responseData;
        }
    }
    
    public static SharePointAllItemWrapper handleResponse(String responseBody, String bearerToken){
        SharePointAllItemWrapper responseData = SharePointAllItemWrapper.parse(responseBody);
        String nextLink = getNextLink(responseBody);
        
        while(nextLink!=null){
            HttpResponse res = spCallout(nextLink,bearerToken);
            nextLink = getNextLink(res.getBody());
            SharePointAllItemWrapper resData = SharePointAllItemWrapper.parse(res.getBody());
            responseData.value.addAll(resData.value);
        }
        return responseData;
    }
    
    public static String getNextLink(String responseBody){
        Map<String, Object> m =  (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String nextLink = (m.containsKey('@odata.nextLink'))?(String)m.get('@odata.nextLink'):null;
        return nextLink;
    }
    
    public static HttpResponse spCallout(String endPoint, String bearerToken){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        
        request.setMethod('GET');    
        request.setHeader('Authorization', 'Bearer '+bearerToken);
        request.setHeader('Accept', '*/*');
        
        HttpResponse response;
        
        if(!Test.isRunningTest()){
            response  = http.send(request); 
        }else{
            response = SharePointAPIUtilityTest.getItems();
        }
        return response;
    }
    
    public static Map<String, Object> getDownloadURL(String baseEndpoint, String siteId, String listId, String itemId){
        String endpoint = baseEndpoint+'/sites/'+siteId+'/lists/'+listId+'/items/'+itemId+'/driveItem';
        String bearerToken = getAuthToken();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        
        request.setMethod('GET');    
        request.setHeader('Authorization', 'Bearer '+bearerToken);
        request.setHeader('Accept', '*/*');
        
        HttpResponse response;
        if(!Test.isRunningTest()){
            response  = http.send(request); 
        }else{
            response = SharePointAPIUtilityTest.getResponse();
        }
        
        if (response.getStatusCode() != 200) {
            throw new SharePointException('API Error : ' + response.getBody());
        } else {
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return responseData;
        }
    }
    
    public static Map<String, Object> getPreviewURL(String baseEndpoint, String siteId, String driveItemId){
        String endpoint = baseEndpoint+'/sites/'+siteId+'/drive/items/'+driveItemId+'/preview';
        String bearerToken = getAuthToken();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        
        request.setMethod('POST');    
        request.setHeader('Authorization', 'Bearer '+bearerToken);
        request.setHeader('Accept', '*/*');
        request.setHeader('Content-Length', '0');
        
        HttpResponse response;
        if(!Test.isRunningTest()){
            response  = http.send(request); 
        }else{
            response = SharePointAPIUtilityTest.getResponse();
        }
        
        if (response.getStatusCode() != 200) {
            throw new SharePointException('API Error : ' + response.getBody());
        } else {
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return responseData;
        }
    }
}