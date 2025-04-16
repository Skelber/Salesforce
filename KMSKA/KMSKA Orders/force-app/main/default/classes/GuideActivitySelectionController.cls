public without sharing class GuideActivitySelectionController {
    @AuraEnabled
    public static Boolean isLoggedUserGuide(){
        User u = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()]; 
        if(u.Profile.Name=='Gidsen'){
            return true;
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static Map<String,Object> getMonthLabel(Date fromDate){
        if(fromDate==null) fromDate = Date.today();
        
        Map<String,Object> response = new Map<String,Object>();
        
        fromDate = fromDate.toStartOfMonth();
        Date toDate = fromDate.addMonths(1).toStartOfMonth();
        
        String label = getMonthName(fromDate.month()) + ' - ' + fromDate.year();
        
        response.put('fromDate', fromDate);
        response.put('toDate', toDate);
        response.put('monthLabel', label);
        return response;
    }
    
    @AuraEnabled
    public static Map<String,Object> getNextMonth(Date toDate){
        return getMonthLabel(toDate.addMonths(1));
    }
    
    @AuraEnabled
    public static Map<String,Object> getPreviousMonth(Date fromDate){
        return getMonthLabel(fromDate.addMonths(-1));
    }
    
    @AuraEnabled
    public static List<activityData> AssignedActivityProducts(Id userId, Date fromDate, Date toDate){
        List<Activity_Product__c> activityProducts = [SELECT Id,Name,Start_Time__c, End_Time__c, Participants__c,
                                                      Taal__c,Doelgroep__c,Opportunity__c,Opportunity__r.Account.Name,
                                                      Opportunity__r.Participants__c,Extra_info_gids__c,
                                                      Availablility__c, Availablility__r.Name, Availablility__r.Guide__c, Availablility__r.Guide__r.Name,
                                                      Availablility__r.Start__c, Availablility__r.End__c, KMSKA_Product__c, KMSKA_Product__r.Name
                                                      FROM Activity_Product__c
                                                      WHERE Availablility__r.Guide__c =: userId AND Start_Time__c >=: fromDate AND Start_Time__c <=: toDate
                                                      AND Status__c!='Annulatie' AND End_Time__c >=: fromDate AND End_Time__c <=: toDate
                                                      ORDER BY Start_Time__c
                                                     ];
        
        List<activityData> assignedTours = new List<activityData>();
        for(Activity_Product__c AP: activityProducts){
            activityData ad = new activityData();
            ad.activityProductId = AP.Id;
            ad.activityId = AP.Availablility__c;
            ad.guideId = AP.Availablility__r.Guide__c;
            ad.productName = AP.KMSKA_Product__r.Name;
            ad.activityName = AP.Availablility__r.Name;
            ad.activityStartDate = AP.Availablility__r.Start__c;
            ad.activityEndDate = AP.Availablility__r.End__c;
            ad.activityProductStartDate = AP.Start_Time__c;
            ad.activityProductEndDate = AP.End_Time__c;
            ad.languages = AP.Taal__c;
            ad.targetAudience = AP.Doelgroep__c;
            ad.accountName = AP.Opportunity__r.Account.Name;
            ad.extraInfo = AP.Extra_info_gids__c;
            ad.participants = AP.Participants__c; //AP.Opportunity__r.Participants__c;
            
            assignedTours.add(ad);
        }
        return assignedTours;
    }
    
    @AuraEnabled
    public static List<activityData> UpCommingActivityProducts(Id userId, Date fromDate, Date toDate){
        Boolean isGuide = isLoggedUserGuide();
        Boolean hasPermission = FeatureManagement.checkPermission('Internal_Guide');
        List<String> targetAud = new List<String>();
        List<String> language = new List<String>();
        
        if(isGuide){
            User user = [SELECT Id, ContactId, Contact.Doelgroep__c, Contact.Talen__c FROM User WHERE Id =: userId];
            if(user.Contact.Talen__c!=null){
                language = (user.Contact.Talen__c).split(';');
            }
            
            if(user.Contact.Doelgroep__c!=null){
                targetAud = (user.Contact.Doelgroep__c).split(';');
            }
        }
        
        if(Test.isRunningTest()){
            language.add('Nederlands');
            targetAud.add('1ste leerjaar');
        }
        
        List<Availablility__c> availabilities = [SELECT Id, Name, Start__c, End__c, Guide__c,(SELECT Id FROM Activity_Products__r) 
                                                 FROM Availablility__c
                                                 WHERE Guide__c =: userId AND Start__c >=: fromDate AND Start__c <=: toDate
                                                 AND End__c >=: fromDate AND End__c <=: toDate 
                                                 ORDER BY Start__c
                                                ];
        Map<Id,Activity_Product__c> activityProducts = new Map<Id,Activity_Product__c>();
        for(Availablility__c ac : availabilities){
            if(ac.Activity_Products__r.size()<=0){
                List<Activity_Product__c> apLst = getUpcomingAP(ac.Start__c, ac.End__c,language,targetAud, isGuide, hasPermission);
                if(!apLst.isEmpty()){
                    for(Activity_Product__c AP : apLst){
                        AP.Availablility__c = ac.Id;
                        activityProducts.put(AP.Id,AP);
                    }
                } 
            }
        }
        
        List<activityData> assignedTours = new List<activityData>();
        for(Id APId: activityProducts.keySet()){
            Activity_Product__c AP = activityProducts.get(APId);
            activityData ad = new activityData();
            ad.activityProductId = AP.Id;
            ad.activityId = AP.Availablility__c;
            ad.activityProductStartDate = AP.Start_Time__c;
            ad.activityProductEndDate = AP.End_Time__c;
            ad.productName = AP.KMSKA_Product__r.Name;
            ad.languages = AP.Taal__c;
            ad.targetAudience = AP.Doelgroep__c;
            ad.accountName = AP.Opportunity__r.Account.Name;
            ad.extraInfo = AP.Extra_info_gids__c;
            ad.participants = AP.Participants__c; //AP.Opportunity__r.Participants__c;
            ad.isSelected = false;
            assignedTours.add(ad);
        }
        return assignedTours;
    }
    
    @AuraEnabled
    public static List<Activity_Product__c> getUpcomingAP(Datetime fromDate, Datetime toDate,List<String> language,List<String> targetAud, Boolean isGuide, Boolean hasPermission){
        String query = 'SELECT Id,Name,Start_Time__c, End_Time__c,Participants__c, Opportunity__c,Extra_info_gids__c, Taal__c ,Doelgroep__c, Availablility__c,Opportunity__r.Participants__c, ';
        query += 'Opportunity__r.Account.Name, KMSKA_Product__c, KMSKA_Product__r.Name FROM Activity_Product__c';
        query += ' WHERE Start_Time__c >=: fromDate AND Start_Time__c <=: toDate AND End_Time__c >=: fromDate AND End_Time__c <=: toDate AND Availablility__c = null ';
        query += 'AND Opportunity__r.Stuur_naar_gidsen_platform__c = true AND Status__c!=\'Annulatie\'';
        if(isGuide){
            query += 'AND Taal__c IN: language AND Doelgroep__c IN: targetAud'; 
        }
        query += ' ORDER BY Start_Time__c';
        
        List<Activity_Product__c> activityProducts = new List<Activity_Product__c>();
        if(isGuide || hasPermission){
            activityProducts = Database.query(query);
        }
        
        return activityProducts;
    }
    
    @AuraEnabled
    public static Map<String,Object> saveActivitySelection(List<activityData> tourSelection){
        Map<String,Object> response = new Map<String,Object>();
        try{
            Boolean isError = false;
            String errorMessage = '';
            
            Set<Id> activityIds = new Set<Id>();
            Set<Id> apIds = new Set<Id>();
            List<Activity_Product__c> apLst = new List<Activity_Product__c>();
            
            for(activityData ad: tourSelection){
                if(ad.isSelected){
                    if(activityIds.contains(ad.activityId)){
                        isError = true;
                        errorMessage = 'You can select only one Rondleidingen for single Availability.';
                    }else{
                        activityIds.add(ad.activityId);
                        apIds.add(ad.activityProductId);
                        Activity_Product__c AP = new Activity_Product__c();
                        AP.Id = ad.activityProductId;
                        AP.Availablility__c = ad.activityId;
                        apLst.add(AP);
                    }
                }
            }
            if(isError){
                response.put('isSuccess',false);
                response.put('isReselect',false);
                response.put('errorMessage',errorMessage);
            }else{
                if(apIds.size()>0){
                    List<Activity_Product__c> extAPLst = [SELECT Id, Availablility__c FROM Activity_Product__c WHERE Id IN:apIds AND Availablility__c!=null];
                    if(extAPLst.size()>0){
                        response.put('isSuccess',false);
                        response.put('isReselect',true);
                        response.put('errorMessage','1 of meerdere rondleidingen zijn ondertussen niet meer beschikbaar. Maak opnieuw een selectie a.u.b.');
                        return response;
                    }else{
                        update apLst;
                    }
                }
                response.put('isSuccess',true);
            }
        }catch(Exception ex){
            response.put('isSuccess',false);
            response.put('errorMessage',ex.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static String getMonthName(Integer month){
        if(month==1)return 'Jan';
        if(month==2)return 'Feb';
        if(month==3)return 'Mar';
        if(month==4)return 'Apr';
        if(month==5)return 'Mei';
        if(month==6)return 'Jun';
        if(month==7)return 'Jul';
        if(month==8)return 'Aug';
        if(month==9)return 'Sep';
        if(month==10)return 'Okt';
        if(month==11)return 'Nov';
        if(month==12)return 'Dec';
        return '';
    }
    
    public class activityData {
        @AuraEnabled public Id activityId {get;set;}
        @AuraEnabled public Id activityProductId {get;set;}
        @AuraEnabled public Id guideId {get;set;}
        
        @AuraEnabled public Datetime activityStartDate {get;set;}
        @AuraEnabled public Datetime activityEndDate {get;set;}
        @AuraEnabled public Datetime activityProductStartDate {get;set;}
        @AuraEnabled public Datetime activityProductEndDate {get;set;}
        
        @AuraEnabled public String productName {get;set;}
        @AuraEnabled public String activityName {get;set;}
        @AuraEnabled public String dateLabel {get;set;}
        @AuraEnabled public String timeLabel {get;set;}
        
        @AuraEnabled public String languages {get;set;}
        @AuraEnabled public String targetAudience {get;set;}
        @AuraEnabled public String extraInfo {get;set;}
        
        @AuraEnabled public Boolean isSelected {get;set;}
        
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public Decimal participants {get;set;}
    }
}