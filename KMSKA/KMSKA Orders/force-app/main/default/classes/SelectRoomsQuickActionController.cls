public class SelectRoomsQuickActionController {
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
    public static List<Resource__c> getResources(){
        List<Resource__c> resources = [SELECT Id, Name, Type__c, Contact__c, User__c, KMSKA_Asset__c 
                                       FROM Resource__c
                                      WHERE Type__c = 'Zalen'];
        return resources;
    }
    
    @AuraEnabled
    public static List<Assigned_Resource__c> getAssignedResources(){
        List<Assigned_Resource__c> AssignedResources = [SELECT Id, Name, Resource__c, Quantity__c, Description__c, KMSKA_Opportunity__c, 
                                                        Type__c, Start_Activity_Product__c, End_Activity_Product__c,KMSKA_Opportunity__r.Name
                                                        FROM Assigned_Resource__c
                                                        WHERE Start_Activity_Product__c!=null 
                                                        AND End_Activity_Product__c!=null
                                                        AND Resource__r.Type__c = 'Zalen'
                                                       ];
        for(Assigned_Resource__c ar: AssignedResources){
            ar.End_Activity_Product__c = (ar.End_Activity_Product__c).addMinutes(1);
        }
        return AssignedResources;
    }
    
    @AuraEnabled
    public static void saveAssignedResource(Assigned_Resource__c aresource){
        System.debug('aresource : ' + aresource);
        insert aresource;
    }
    
}