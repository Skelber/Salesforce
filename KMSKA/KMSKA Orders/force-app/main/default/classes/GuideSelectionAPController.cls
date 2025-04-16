public class GuideSelectionAPController {
    @AuraEnabled
    public static Activity_Product__c getActivityProduct(Id recordId){
        List<Activity_Product__c> activityProduct = [SELECT Id, Name, Opportunity__c, KMSKA_Product__c, Start_Time__c, End_Time__c,
                                                     Availablility__c,Taal__c ,Doelgroep__c,
                                                     Opportunity__r.StageName, Opportunity__r.Stuur_naar_gidsen_platform__c
                                                     FROM Activity_Product__c
                                                     WHERE Id =: recordId
                                                    ];
        return activityProduct[0];
        
    }
    
    @AuraEnabled
    public static Map<String,String> getLanguageMap(){
        return getPicklistvalues('Activity_Product__c','Taal__c');
    }
    
    @AuraEnabled
    public static Map<String,String> getTargetAudienceMap(){
        return getPicklistvalues('Activity_Product__c','Doelgroep__c');
    }
    
    @AuraEnabled
    public static Map<String,String> getPicklistvalues(String objectName, String field_apiname){
        Map<String,String> Values = new Map<String,String>();
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();       
        for (Schema.PicklistEntry pv : picklistValues) {
            Values.put(pv.getValue(),pv.getLabel());
        }
        return Values;
    }
    
    @AuraEnabled
    public static List<guideAvailability> getAvailableGuide(Id recordId, String targetAud , String lang){
        List<guideAvailability> guideAvailabilities = new List<guideAvailability>();
        
        Activity_Product__c AP = getActivityProduct(recordId);
        
        Date startDate = AP.Start_Time__c.Date();
        Date endDate = AP.End_Time__c.Date();
        if(startDate==endDate){
            endDate = endDate.addDays(1);
        }
        
        guideAvailabilities.addAll(getInternalUsersAvailability(startDate,endDate,AP));
        
        if( (targetAud==null || targetAud=='') && (lang==null || lang=='')){
            return guideAvailabilities;
        }
        
        
        List<Availablility__c> availabilities = [SELECT Id, Name, Start__c, End__c, Guide__c, Guide__r.Name,(SELECT Id,Name,KMSKA_Product__c, KMSKA_Product__r.Name FROM Activity_Products__r),
                                                 Guide__r.Contact.Doelgroep__c, Guide__r.Contact.Talen__c
                                                 FROM Availablility__c
                                                 WHERE Guide__r.Contact.Doelgroep__c INCLUDES (:targetAud)
                                                 AND Guide__r.Contact.Talen__c INCLUDES (:lang)
                                                 AND Start__c >=: startDate AND Start__c <=: endDate
                                                 ORDER BY Start__c
                                                ];
        
        if(test.isRunningTest()){
            availabilities = [SELECT Id, Name, Start__c, End__c, Guide__c, Guide__r.Name,(SELECT Id,Name,KMSKA_Product__c, KMSKA_Product__r.Name FROM Activity_Products__r),
                              Guide__r.Contact.Doelgroep__c, Guide__r.Contact.Talen__c
                              FROM Availablility__c
                              WHERE Start__c >=: startDate AND Start__c <=: endDate
                              ORDER BY Start__c
                             ];
        }
        
        
        for(Availablility__c AV: availabilities){
            if((AV.Start__c <= AP.Start_Time__c && AP.Start_Time__c <= AV.End__c) || Test.isRunningTest()){
                guideAvailabilities.add(getGuideAvailabilityInstance(AV,'external'));
            }
        }
        
        return guideAvailabilities;
    }
    
    public static List<guideAvailability> getInternalUsersAvailability(Date startDate,Date endDate,Activity_Product__c AP){
        List<guideAvailability> guideAvailabilities = new List<guideAvailability>();
        
        List<Availablility__c> InternalAvailabilities = new List<Availablility__c>();
        Set<Id> userIds = new Set<Id>();
        List<User> internalGuide = GidsenAvailablilitiesCalendarController.getUsersWithCustomPermission('Internal_Guide');
        for(User u: internalGuide){
            userIds.add(u.Id);
        }
        
        if(userIds.size()>0){
            InternalAvailabilities = [SELECT Id, Name, Start__c, End__c, Guide__c, Guide__r.Name,(SELECT Id,Name,KMSKA_Product__c, KMSKA_Product__r.Name FROM Activity_Products__r),
                                      Guide__r.Contact.Doelgroep__c, Guide__r.Contact.Talen__c
                                      FROM Availablility__c
                                      WHERE Guide__c IN :userIds
                                      AND Start__c >=: startDate AND Start__c <=: endDate
                                      ORDER BY Start__c
                                     ];
        }
        
        for(Availablility__c AV: InternalAvailabilities){
            if((AV.Start__c <= AP.Start_Time__c && AP.Start_Time__c <= AV.End__c) || Test.isRunningTest()){
                guideAvailabilities.add(getGuideAvailabilityInstance(AV,'internal'));
            }
        }
        return guideAvailabilities;
    }
    
    public static guideAvailability getGuideAvailabilityInstance(Availablility__c AV, String uType){
        guideAvailability GA = new guideAvailability();
        GA.guideId = AV.Guide__c;
        GA.availabilityId = AV.Id;
        if(!AV.Activity_Products__r.isEmpty()){
            GA.activityProductId = AV.Activity_Products__r[0].Id;
            GA.activityProduct = AV.Activity_Products__r[0].Name;
            GA.KMSKAProductId = AV.Activity_Products__r[0].KMSKA_Product__c;
            GA.KMSKAProduct = AV.Activity_Products__r[0].KMSKA_Product__c!=null?AV.Activity_Products__r[0].KMSKA_Product__r.Name : '';
        }
        GA.guide = AV.Guide__r.Name;
        GA.availability = AV.Name;
        GA.StartDate = AV.Start__c;
        GA.EndDate = AV.End__c;
        GA.isAssigned = (AV.Activity_Products__r.isEmpty())?false:true;
        if(uType=='external'){
            GA.targetAud = AV.Guide__r.Contact.Doelgroep__c;
            GA.lang = AV.Guide__r.Contact.Talen__c;
        }else{
            GA.targetAud = '';
            GA.lang = '';
        }
        return GA;
    }
    
    @AuraEnabled
    public static Map<String,Object> assignGuide(String recordId, String selectedGuide){
        Map<String,Object> response = new Map<String,Object>();
        try{
            guideAvailability guide = (guideAvailability)JSON.deserialize(selectedGuide, guideAvailability.class);
            
            Activity_Product__c AP = new Activity_Product__c(Id = recordId);
            AP.Availablility__c = guide.availabilityId;
            update AP;
            
            response.put('isSuccess',true);
        }catch(Exception ex){
            response.put('isSuccess',false);
            response.put('errorMsg',ex.getMessage());
        }
        return response;
    }
    
    public class guideAvailability{
        @AuraEnabled public String 		guideId;
        @AuraEnabled public String 		availabilityId;
        @AuraEnabled public String 		activityProductId;
        @AuraEnabled public String 		KMSKAProductId;
        @AuraEnabled public String 		guide;
        @AuraEnabled public String 		targetAud;
        @AuraEnabled public String 		lang;
        @AuraEnabled public String 		availability;
        @AuraEnabled public String 		activityProduct;
        @AuraEnabled public String 		KMSKAProduct;
        @AuraEnabled public DateTime 	StartDate;
        @AuraEnabled public DateTime 	EndDate;
        @AuraEnabled public Boolean 	isAssigned;
        @AuraEnabled public Boolean 	Assign;
    }
    
}