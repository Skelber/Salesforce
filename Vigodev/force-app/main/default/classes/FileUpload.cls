public class FileUpload {
    
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
        
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        
        if (cv == null || cdl == null) { 
            return null; 
        }
        
        return cdl.Id;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename) {
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        
        try {
            insert cv;
        } catch (DMLException e) {
            System.debug(e);
            return null;
        }
        
        return cv;
    }
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        
        if (contentVersionId == null || recordId == null) { 
            return null; 
        }
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        
        try {
            insert cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
        
        return cdl;
    }
    
}