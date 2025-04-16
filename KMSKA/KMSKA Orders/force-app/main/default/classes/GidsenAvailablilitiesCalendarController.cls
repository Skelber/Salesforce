public class GidsenAvailablilitiesCalendarController {
    
    @AuraEnabled
    public static Boolean isLoggedUserGuide(){
        User u = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()]; 
        if(u.Profile.Name=='Gidsen'){
            return true;
        }else{
            Boolean hasPermission = FeatureManagement.checkPermission('Internal_Guide');
            return hasPermission;
        }
    }
    
    @AuraEnabled
    public static Map<String,String> getRecordTypes(){
        Map<String, String> response = new Map<String, String>();
        
        List<RecordType> recTypes = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Availablility__c'];
        for(RecordType r: recTypes){
            if(r.Name=='Recurring')
                response.put('recurring',r.Id);
            if(r.Name=='Single')
                response.put('single',r.Id);
        }
        return response;
    }
    
    @AuraEnabled
    public static date getRecurringDate(Datetime startDateTime){
        return startDateTime.date();
    }
    
    
    @AuraEnabled
    public static Map<String,String> getAllGuides(){
        Map<String, String> options = new Map<String, String>();
        List<User> guides = [SELECT Id, Name FROM User WHERE Profile.Name='Gidsen' AND IsActive=true];
        for(User u: guides){
            options.put(u.Id, u.Name);
        }
        
        List<User> internalGuide = getUsersWithCustomPermission('Internal_Guide');
        for(User u: internalGuide){
            options.put(u.Id, u.Name);
        }
        
        return options;
    }
    
    public static List<User> getUsersWithCustomPermission(String name)
    {
        Set<Id> permissionSetIds = new Set<Id>();
        for (SetupEntityAccess access : [ SELECT ParentId  FROM SetupEntityAccess  WHERE SetupEntityId IN ( SELECT Id  FROM CustomPermission WHERE DeveloperName = :name)])
        {
            permissionSetIds.add(access.ParentId);
        }
        
        if(permissionSetIds.isEmpty()){
            return new List<User>();
        }else{
            return [SELECT Id, Name 
                    FROM User 
                    WHERE Id IN ( SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN :permissionSetIds)
                    AND IsActive=true
                   ];
        }
    }
    
    @AuraEnabled
    public static Map<String,String> getLanguageMap(){
        return getPicklistvalues('Opportunity','Taal__c');
    }
    
    @AuraEnabled
    public static Map<String,String> getTargetAudienceMap(){
        return getPicklistvalues('Opportunity','Doelgroep__c');
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
    public static List<calendarData> getActivityProduct(String selGuide){
        List<calendarData> dataLst = new List<calendarData>();
        List<Activity_Product__c> APLst = new List<Activity_Product__c>();
        
        if(selGuide.length()==15 || selGuide.length() ==18){
            APLst = [SELECT Id, Name, Opportunity__c, Opportunity__r.Name,Opportunity__r.Extra_info_gids__c, KMSKA_Product__c, Start_Time__c, End_Time__c, 
                     Availablility__c, Availablility__r.Guide__c, Availablility__r.Guide__r.Name, Status__c
                     FROM Activity_Product__c
                     WHERE Availablility__r.Guide__c =: selGuide AND Status__c!='Annulatie' AND Availablility__r.Guide__r.IsActive = true
                    ];
        }else{
            APLst = [SELECT Id, Name, Opportunity__c, Opportunity__r.Name, Opportunity__r.Extra_info_gids__c, KMSKA_Product__c, Start_Time__c, End_Time__c, 
                     Availablility__c, Availablility__r.Guide__c, Availablility__r.Guide__r.Name, Status__c
                     FROM Activity_Product__c
                     WHERE Status__c!='Annulatie' AND Availablility__c!=null AND Availablility__r.Guide__r.IsActive = true
                    ];
        }
        
        for(Activity_Product__c ap: APLst){
            calendarData data 	= new calendarData();
            data.recordId 		= ap.Id;
            data.title 			= ap.Opportunity__r.Name + (ap.Status__c!=null? '('+ ap.Status__c +')':'');
            data.startDatetime 	= ap.Start_Time__c;
            data.endDatetime 	= ap.End_Time__c;
            data.name 			= ap.Name;
            data.parent 		= ap.Opportunity__r.Name;
            data.ebgColor 		= System.Label.Default_AP_Calendar_color;
            data.guideName		= ap.Availablility__r.Guide__r.Name;
            data.extraInfo		= ap.Opportunity__r.Extra_info_gids__c!=null?ap.Opportunity__r.Extra_info_gids__c:'';
            data.recType 		= 'AP';
            dataLst.add(data);
        }
        return dataLst;
    }
    
    @AuraEnabled
    public static Map<String,Object> getData(String selGuide, String taal, String doelgroep){
        Map<String,Object> response = new Map<String,Object>();
        
        List<calendarData> dataLst = new List<calendarData>();
        
        List<Availablility__c> availLst = getAvailabilities(selGuide,taal,doelgroep);
        if(selGuide=='all'){
            availLst.addAll(getInternalUsersAvailability());
        }
        for(Availablility__c avl: availLst){
            if(avl.Activity_Products__r.size()<=0){
                calendarData data 	= new calendarData();
                data.recordId 		= avl.Id;
                data.title 			= avl.Guide__r.Name;
                data.startDatetime 	= avl.Start__c;
                data.endDatetime 	= avl.End__c;
                data.name 			= avl.Name;
                data.parent 		= avl.Guide__r.Name;
                data.ebgColor 		= System.Label.Default_Activity_Calendar_Color;
                data.guideName		= avl.Guide__r.Name;
                data.extraInfo		= '';
                data.recType 		= 'AV';
                dataLst.add(data);
            }
        }
        
        response.put('dataLst',dataLst);
        response.put('apDataLst',getActivityProduct(selGuide));
        
        return response;
    }
    
    @AuraEnabled
    public static Availablility__c getAvailability(String recId){
        return [SELECT Id, Name, End__c, Start__c, Guide__c ,Guide__r.Name,
                RecordTypeId, RecordType.Name, Start_Recurring__c, End_Recurring__c,Parent__c
                FROM Availablility__c
                WHERE Id =: recId];
    }
    
    @AuraEnabled
    public static Map<String,Object> updateAvailability(Availablility__c availability){
        Id recurring;
        List<RecordType> recTypes = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Availablility__c'];
        for(RecordType R: recTypes){ if(R.Name=='Recurring') recurring=R.Id;}
        
        Map<String,Object> response = new Map<String,Object>();
        try{
            availability.ownerId = availability.Guide__c;
            if(availability.RecordTypeId==recurring){
                availability.Start_Recurring__c = (availability.Start__c).Date();
            }
            
            Map<String,Object> validations = validateRecord(availability);
            Boolean isValid  = (Boolean)validations.get('isValid');
            if(isValid){
                update availability;
                response.put('isSuccess',true);
            }else{
                response.put('isSuccess',false);
                response.put('message',(String)validations.get('message'));
            }
        }
        catch(DMLException dex){
            response.put('isSuccess',false);
            response.put('message',dex.getDmlMessage(0));
        }
        catch(Exception ex){
            System.debug(ex.getTypeName());
            system.debug(ex.getMessage());
            response.put('isSuccess',false);
            response.put('message',ex.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static Map<String,Object> deleteAvailability(Availablility__c availability){
        Map<String,Object> response = new Map<String,Object>();
        try{
            Delete availability;
            response.put('isSuccess',true);
        }catch(Exception ex){
            system.debug(ex.getMessage());
            response.put('isSuccess',false);
            if(ex.getMessage().contains('Onze excuses, het is niet mogelijk om uw beschikbaarheid te annuleren aangezien er reeds één of meerdere activiteiten aan u zijn gelinkt tijdens deze beschikbaarheid. Gelieve KMSKA te contacteren.')){
                response.put('message','Onze excuses, het is niet mogelijk om uw beschikbaarheid te annuleren aangezien er reeds één of meerdere activiteiten aan u zijn gelinkt tijdens deze beschikbaarheid. Gelieve KMSKA te contacteren.');
            }else{
                response.put('message',ex.getMessage());    
            }
        }
        return response;
    }
    
    @AuraEnabled
    public static Map<String,Object> deleteRecurringAvailability(Availablility__c availability,String actionType){
        Map<String,Object> response = new Map<String,Object>();
        try{
            if(actionType=='all'){
                List<Availablility__c> childRecords = new List<Availablility__c>();
                if(availability.Parent__c){
                    childRecords = [SELECT Id FROM Availablility__c WHERE Parent_Availablility__c =: availability.Id];
                }else{
                    availability = [SELECT Id, Parent_Availablility__c FROM Availablility__c WHERE Id =: availability.Id];
                    childRecords = [SELECT Id FROM Availablility__c WHERE Parent_Availablility__c =: availability.Parent_Availablility__c];
                    
                    //Fetch Parent.
                    availability = [SELECT Id FROM Availablility__c WHERE Id =: availability.Parent_Availablility__c];
                }
                
                Delete childRecords;
                Delete availability;
            }else{
                Delete availability;
            }
            response.put('isSuccess',true);
        }catch(Exception ex){
            system.debug(ex.getMessage());
            response.put('isSuccess',false);
            response.put('message',ex.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static List<Availablility__c> getAvailabilities(String uId, String taal, String doelgroep){
        List<Availablility__c> availabilities = new List<Availablility__c>();
        
        String query = 'SELECT Id, Name, End__c, Start__c, Guide__c, Guide__r.Name, Guide__r.Contact.Talen__c,Guide__r.Contact.Doelgroep__c,(SELECT Id FROM Activity_Products__r) FROM Availablility__c';
        String WhereCluase = ' WHERE ';
        
        if(uId.toLowerCase()=='all'){
            WhereCluase +=' Guide__r.Profile.Name=\'Gidsen\'';
        } else if(uId.length()==15 || uId.length() ==18){
            WhereCluase +=' Guide__c =: uId';
        } 
        
        if(taal!=null && taal!=''){
            WhereCluase += ' AND Guide__r.Contact.Talen__c INCLUDES (:taal)';
        }
        
        if(doelgroep!=null && doelgroep!=''){
            WhereCluase += ' AND Guide__r.Contact.Doelgroep__c INCLUDES (:doelgroep) ';
        }
        
        if(WhereCluase!=' WHERE '){
            query = query + WhereCluase;
        }
        
        System.debug('query : ' + query);
        
        availabilities = Database.query(query);
        
        return availabilities;
    }
    
    public static List<Availablility__c> getInternalUsersAvailability(){
        List<Availablility__c> availabilities = new List<Availablility__c>();
        Set<Id> userIds = new Set<Id>();
        List<User> internalGuide = getUsersWithCustomPermission('Internal_Guide');
        for(User u: internalGuide){
            userIds.add(u.Id);
        }
        String query = 'SELECT Id, Name, End__c, Start__c, Guide__c, Guide__r.Name,(SELECT Id FROM Activity_Products__r) FROM Availablility__c WHERE  Guide__c IN :userIds';
        availabilities = Database.query(query);
        return availabilities;
    }
    
    @AuraEnabled
    public static Map<String,Object> saveAvailability(Availablility__c availability){
        Id recurring;
        List<RecordType> recTypes = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Availablility__c'];
        for(RecordType R: recTypes){ if(R.Name=='Recurring') recurring=R.Id;}
        
        Map<String,Object> response = new Map<String,Object>();
        try{
            if(availability.RecordTypeId==recurring){
                availability.Start_Recurring__c = (availability.Start__c).Date();
                availability.Parent__c = true;
            }
            System.debug(availability.Start__c);
            System.debug(availability.Start_Recurring__c);
            
            Map<String,Object> validations = validateRecord(availability);
            Boolean isValid  = (Boolean)validations.get('isValid');
            if(isValid){
                availability.ownerId = availability.Guide__c;
                insert availability;
                
                if(availability.RecordTypeId==recurring){
                    createChildRecord(availability);
                }
                
                response.put('isSuccess',true);
            }else{
                response.put('isSuccess',false);
                response.put('message',(String)validations.get('message'));
            }
        }
        catch(DMLException dex){
            response.put('isSuccess',false);
            response.put('message',dex.getDmlMessage(0));
        }
        catch(Exception ex){
            System.debug(ex.getTypeName());
            system.debug(ex.getMessage());
            response.put('isSuccess',false);
            response.put('message',ex.getMessage());
        }
        return response;
    }
    
    public static void createChildRecord(Availablility__c parentavailability){
        List<Availablility__c> childRecords = new List<Availablility__c>();
        Datetime nextDate = (parentavailability.Start__c).addDays(7);
        Datetime nextEndDate = (parentavailability.End__c).addDays(7);
        
        while (nextDate.Date() <= parentavailability.End_Recurring__c) {
            Availablility__c cAvail = new Availablility__c();
            cAvail.Start__c = nextDate;
            cAvail.End__c = nextEndDate;
            cAvail.Start_Recurring__c = parentavailability.Start_Recurring__c;
            cAvail.End_Recurring__c = parentavailability.End_Recurring__c;
            cAvail.Parent__c = false;
            cAvail.Parent_Availablility__c = parentavailability.Id;
            cAvail.RecordTypeId = parentavailability.RecordTypeId;
            cAvail.Guide__c = parentavailability.Guide__c;
            cAvail.OwnerId = parentavailability.OwnerId;
            
            childRecords.add(cAvail);
            
            nextDate = nextDate.addDays(7);
            nextEndDate = nextEndDate.addDays(7);
            System.debug(nextDate);
        }
        
        if(childRecords.size()>0)insert childRecords;
    }
    
    public static Map<String,Object> validateRecord(Availablility__c availability){
        Id recurring;
        List<RecordType> recTypes = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Availablility__c'];
        for(RecordType R: recTypes){ if(R.Name=='Recurring') recurring=R.Id;}
        
        Map<String,Object> response = new Map<String,Object>();
        
        Boolean isValid = true;
        String message = '';
        
        if(availability.recordTypeId == recurring){
            if((availability.Start__c).Date() != (availability.End__c).Date() ){
                isValid = false;
                message = 'Voor herhalingen moeten van en tot dezelfde datum bevatten.';
            }
            
            if(!(checkValidilty(availability.Start_Recurring__c, availability.End_Recurring__c))){
                Date max = (availability.Start_Recurring__c.addYears(1));
                String maxDate = max.day()+'-'+max.month()+'-'+max.year();
                isValid = false; 
                message = 'je kunt maximum tot 1 jaar herhalen ('+ maxDate +')';
            }
        }
        
        response.put('isValid',isValid);
        response.put('message',message);
        return response;
    }
    
    public static Boolean checkValidilty(Date startDate, Date endDate){
        Integer numberDaysDue = startDate.daysBetween(endDate);
        if(numberDaysDue>365){
            return false;
        }else{
            return true;
        }
    }
    
    public class calendarData {
        @AuraEnabled public Id 			recordId 		{get;set;}
        @AuraEnabled public String 		title 			{get;set;}
        @AuraEnabled public DateTime 	startDatetime 	{get;set;}
        @AuraEnabled public DateTime 	endDatetime 	{get;set;}
        @AuraEnabled public String 		name 			{get;set;}
        @AuraEnabled public String 		parent 			{get;set;}
        @AuraEnabled public String 		ebgColor  		{get;set;}
        @AuraEnabled public String 		guideName  		{get;set;}
        @AuraEnabled public String 		recType  		{get;set;}
        @AuraEnabled public String		extraInfo		{get;set;}
    }
}