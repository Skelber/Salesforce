public class SPRelatedListController {
    
    @AuraEnabled
    public static Map<String,Object> getAllItems(){
        return  SharePointService.getAllItems();
    }
}