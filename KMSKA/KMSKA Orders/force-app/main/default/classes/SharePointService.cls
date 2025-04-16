public class SharePointService {
    
    @AuraEnabled
    public static Map<String,Object> getAllItems(){
        Map<String,Object> response = new Map<String,Object>();
        Sharepoint_Integration__c SI = SharePointAuthorization.getAuthInfo();
        
        List<SharePointItems> Fileitems = new List<SharePointItems>();
        List<SharePointItems> Folderitems = new List<SharePointItems>();
        
        Map<String,SharePointItems> allFolders = new Map<String,SharePointItems>();
        //Parent Folder
        SharePointItems Pitem = new SharePointItems();
        Pitem.id = SI.Parent_Id__c;
        Pitem.eTag = SI.Parent_Id__c;
        Pitem.name = SI.Parent_Folder_Name__c;
        allFolders.put(Pitem.eTag, Pitem);
        
        SharePointAllItemWrapper SPW = SharePointAPIUtility.getAllItems(SI.Base_Endpoint__c, SI.Site_Id__c, SI.List_Id__c);
        for(SharePointAllItemWrapper.cls_value value : SPW.value){
            SharePointItems item = new SharePointItems();
            item.id = value.id;
            item.eTag = ((value.eTag).substringBeforeLast(',')).remove('"');
            item.webUrl = value.webUrl;
            item.name = value.fields.LinkFilename;
            item.pId = value.parentReference.id;
            item.pSId = value.parentReference.siteId;
            
            if(value.contentType.name.toLowercase()=='Map'){
                item.contentType = 'folder';
                Folderitems.add(item);
                allFolders.put(item.eTag, item);
            }else{
                item.contentType = 'file';
                item.icon = getIcon(item.name);
                Fileitems.add(item);
            }
        }
        response.put('folders', Folderitems);
        response.put('files', Fileitems);
        response.put('allFolders', allFolders);
        response.put('parentFolder', Pitem);
        
        return response;
    }
    
    public static String getIcon(String name){
        if(name.endsWith('.pdf')){
            return 'doctype:pdf';
        }else if(name.endsWith('.docx') || name.endsWith('.doc')){
            return 'doctype:word';
        }else if(name.endsWith('.mp4')){
            return 'doctype:mp4';
        }else if(name.endsWith('.jpg') || name.endsWith('.jpeg')){
            return 'doctype:image';
        }
        return 'doctype:attachment';
    }
    
    public class SharePointItems{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String eTag {get;set;}
        @AuraEnabled public String webUrl {get;set;}
        @AuraEnabled public String pId {get;set;}
        @AuraEnabled public String pSId {get;set;}
        @AuraEnabled public String contentType {get;set;}
        @AuraEnabled public String icon {get;set;}
        @AuraEnabled public List<SharePointItems> child {get;set;}
    }
}