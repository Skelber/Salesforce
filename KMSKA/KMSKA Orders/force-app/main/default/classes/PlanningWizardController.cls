public class PlanningWizardController {
    @AuraEnabled
    public static Date getToday(){
        return Date.today();
    }
    
    @AuraEnabled
    public static Planning__c getPlanningRecord(Id recordId){
        Planning__c plan = [SELECT Id, Name, End__c, Start__c, KMSKA_Activity__c, Description__c, Main_Stage__c,
                            Room__c,Room__r.Name
                            FROM Planning__c
                            WHERE Id =:recordId
                           ];
        return plan;
    }
    
    @AuraEnabled
    public static Map<Date, List<Plannings>> getPlannings(Id oppId){
        Map<Date, List<Plannings>> planningMap = new Map<Date, List<Plannings>>();
        
        List<Planning__c> plannings = [SELECT Id, Name, End__c, Start__c, KMSKA_Activity__c, Description__c, Main_Stage__c,
                                       Room__c,Room__r.Name
                                       FROM Planning__c
                                       WHERE KMSKA_Activity__c =:oppId
                                       ORDER By Start__c];
        
        for(Planning__c plan: plannings){
            Boolean firstItem = false;
            
            if(!planningMap.containsKey((plan.Start__c).Date()))
            {
                planningMap.put((plan.Start__c).Date(), new List<Plannings>());
                firstItem = true;
            }
            
            Plannings p = new Plannings();
            p.recordId = plan.Id;
            p.startDate = (plan.Start__c).Date();
            
            if(plan.Start__c!=null){
                String h = String.valueof(plan.Start__c.hour());
                String m = String.valueof(plan.Start__c.minute());
                if(h.length()==1)h = '0'+h;
                if(m.length()==1)m = '0'+m;
                
                p.startTime = h+':'+m;
            }
            
            
            
            if(plan.End__c!=null){
                p.endDate = (plan.End__c).Date();
                
                String h = String.valueof(plan.End__c.hour());
                String m = String.valueof(plan.End__c.minute());
                if(h.length()==1)h = '0'+h;
                if(m.length()==1)m = '0'+m;
                
                p.endTime = h+':'+m;
            }
            
            p.description = plan.Description__c;
            p.RoomId = plan.Room__c;
            p.Room = plan.Room__r.Name;
            p.mainStage = plan.Main_Stage__c;
            
            if(plan.Start__c!=null && plan.End__c!=null 
               && (plan.Start__c).Date()!=(plan.End__c).Date())
            {
                String d = String.valueof(plan.End__c.day());
                String m = String.valueof(plan.End__c.month());
                if(d.length()==1)d= '0'+d;
                if(m.length()==1)m = '0'+m;
                
                p.endTime = p.endTime+' (' + d+'/'+ m +')';
            }
            
            p.firstItem = firstItem;
            
            planningMap.get((plan.Start__c).Date()).add(p);
        }
        return planningMap;
    }
    
    @AuraEnabled
    public static Map<String,object>  getOpportunityRecord(String recordId){
        Map<String,object> response = new Map<String,Object>();
        
        List<Opportunity> oppLst = [SELECT Id, Name, Description, StageName, Amount, Type, Start_Time__c, End_Time__c 
                                    FROM Opportunity 
                                    WHERE Id =: recordId
                                   ];
        Opportunity opp = oppLst[0];
        opp.End_Time__c = (opp.End_Time__c).addMinutes(1);
        
        response.put('opp',opp);
        return response;
    }
    
    @AuraEnabled
    public static List<Room__c> getResources(String searchTerm){
        if(searchTerm==null || searchTerm==''){
            List<Room__c> resources = [SELECT Id, Name FROM Room__c];
            return resources;
        }else{
            searchTerm = '%'+searchTerm+'%';
            List<Room__c> resources = [SELECT Id, Name FROM Room__c WHERE Name LIKE :searchTerm];
            return resources;
        }
    }
    
    @AuraEnabled
    public static List<Planning__c> getAssignedResources(Planning__c planning){
        List<Planning__c> plannings = [SELECT Id, Name, End__c, Start__c, Type__c,Description__c, Main_Stage__c, 
                                       Room__c,KMSKA_Activity__c,KMSKA_Activity__r.Name,KMSKA_Activity__r.StageName 
                                       FROM Planning__c
                                       WHERE Room__c!=null 
                                       AND  ( 
                                           (Start__c >=: planning.Start__c AND Start__c <=: planning.End__c) 
                                           OR (End__c >: planning.Start__c AND End__c<=: planning.End__c)
                                       )
                                      ];
        for(Planning__c p: plannings){
            p.End__c = (p.End__c).addMinutes(1);
        }
        
        return plannings;
    }
    
    @AuraEnabled
    public static Map<String,Object> savePlanning(Id OppId, Planning__c planning){
        Savepoint sp = Database.setSavepoint();
        
        Map<String,Object> response = new Map<String,Object>();
        
        try{
            if(planning.Id!=null){
                update planning;
            }else{
                insert planning;  
            }
            
            response.put('isSuccess',true);
        }catch(DMLException dex){
            Database.rollback(sp);
            response.put('isSuccess',false);
            response.put('message',dex.getDmlMessage(0));
        }
        catch(Exception ex){
            Database.rollback(sp);
            System.debug(ex.getTypeName());
            system.debug(ex.getMessage());
            response.put('isSuccess',false);
            response.put('message',ex.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static void deletePlanningRecord(Planning__c Planning){
        List<Required_Resource__c> requiredResources = [SELECT Id 
                                                        FROM Required_Resource__c 
                                                        WHERE Planning__c =: Planning.Id
                                                       ];
        If(requiredResources.size()>0)Delete requiredResources;
        Delete Planning;
    }
    
    public class Plannings{
        @AuraEnabled public Id          recordId {get;set;}
        @AuraEnabled public Boolean     firstItem {get;set;}
        @AuraEnabled public Date        startDate {get;set;}
        @AuraEnabled public Date        endDate {get;set;}
        @AuraEnabled public String      startTime {get;set;}
        @AuraEnabled public String      endTime {get;set;}
        @AuraEnabled public String      description {get;set;}
        @AuraEnabled public String      Room {get;set;}
        @AuraEnabled public Id          RoomId {get;set;}
        @AuraEnabled public Boolean     mainStage {get;set;}
    }
}