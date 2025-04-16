public without sharing class testpubliekmotivatieCmpController {
    @AuraEnabled 
    public static form__c getform(String LId){
        Id DevRecordTypeId = Schema.SObjectType.form__c.getRecordTypeInfosByName().get('De Schoonste Honderd - Motivatie').getRecordTypeId();
        
        List<form__c> formLst = [SELECT Id, Motivation__c FROM form__c WHERE Lead__c =: LId AND RecordTypeId =: DevRecordTypeId];
        if(formLst.size()>0){
            return formLst[0];
        }else{
        	return new form__c();    
        }
    }
    
    @AuraEnabled 
    public static Lead getLead(String LId){
        List<Lead> LeadLst = [SELECT Id, FirstName,LastName FROM Lead WHERE Id=: LId];
        return LeadLst[0];
    }
    
    @AuraEnabled 
    public static Map<String,Id> SaveRecord(form__c formRec, String LId){
        Id DevRecordTypeId = Schema.SObjectType.form__c.getRecordTypeInfosByName().get('De Schoonste Honderd - Motivatie').getRecordTypeId();
        
        System.debug('formRec :: ' + formRec);
        Map<String,Id> Response = new Map<String,Id>();
        
        formRec.RecordTypeId = DevRecordTypeId;
        formRec.Lead__c = LId;
        Insert formRec;
        
        Response.put('Form', formRec.Id);
        return Response;
    }
}