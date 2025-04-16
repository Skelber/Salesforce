public without sharing class testpubliekCmpController {
    
    @AuraEnabled 
    public static Lead getleadObj(){
        return new Lead();
    }
    
    @AuraEnabled 
    public static form__c getformObj(){
        return new form__c();
    }
    
    @AuraEnabled 
    public static Map<String,Id> SaveRecord(Lead leadRec, Form__c formRec){
        Map<String,Id> Response = new Map<String,Id>();
        
        leadRec.Company = '[NOT PROVIDED]';
        leadRec.LeadSource = 'De Schoonste Honderd';
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(leadRec, dml); 
        
        if (sr.isSuccess()) {   
            Response.put('Lead', leadRec.Id);
            
            formRec.Lead__c  = leadRec.Id;
            Database.SaveResult srForm = Database.insert(formRec, dml); 
            if (srForm.isSuccess()) {   
                Response.put('Form', formRec.Id);
            }
        }
        return Response;
    }
    
    @AuraEnabled 
    public static Map<String, String> getGender(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Lead.Gender__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getCurrentSituation(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = form__c.Current_Situation__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getStudyArea(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = form__c.Study_area__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getWorkSector(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = form__c.Work_Sector__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getVisitedKMSKA(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = form__c.Visitied_KMSKA__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getVisitMusea(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = form__c.Visits_musea_last_year__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getReasonNoVisit(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = form__c.Reason_no_visits__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getContextVisit(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = form__c.Context_Visits__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getInterest(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = form__c.interests__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getReasonVisits(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = form__c.Reason_Visits__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getReasonToVisits(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = form__c.Reasons_To_Visit__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getCampaignSource(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = form__c.Campaign_Source__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
}