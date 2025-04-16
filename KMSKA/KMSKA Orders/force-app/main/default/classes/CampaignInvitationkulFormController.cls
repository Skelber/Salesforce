public without sharing class CampaignInvitationkulFormController {
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getData(String contId){
        Map<String,Object> response = new Map<String,Object>();
        List<Contact> contLst = [SELECT Id, Name, FirstName, LastName, MailingStreet, MailingPostalCode, MailingCity, Email, Birthdate__c, Gender__c 
                                 FROM Contact 
                                 WHERE Id =: contId
                                ];
        if(contLst.size()>0){
            List<form__c> formLst = [SELECT Id, Name, RecordTypeId FROM form__c WHERE Contact__c =: contId AND RecordType.Name='KUL - Eye-tracking'];
            if(formLst.size()>0){
                response.put('isSuccess',false);
                response.put('message','Wij hebben je antwoorden al goed ontvangen.');
            }else{
                Contact con = contLst[0];
                conInfo ci = new conInfo();
                ci.conId = con.Id;
                ci.voornaam = (con.FirstName!=null && con.FirstName!='') ? con.FirstName : '';
                ci.isVoornaam = (con.FirstName!=null && con.FirstName!='') ? true : false;
                
                ci.naam = (con.LastName!=null && con.LastName!='') ? con.LastName : '';
                ci.isNaam = (con.LastName!=null && con.LastName!='') ? true : false;
                
                ci.email = (con.Email!=null && con.Email!='') ? con.Email : '';
                ci.isEmail = (con.Email!=null && con.Email!='') ? true : false;
                
                ci.adres = (con.MailingStreet!=null && con.MailingStreet!='') ? con.MailingStreet : '';
                ci.postcode = (con.MailingPostalCode!=null && con.MailingPostalCode!='') ? con.MailingPostalCode : '';
                ci.gemeente = (con.MailingCity!=null && con.MailingCity!='') ? con.MailingCity : '';
                ci.geboortedatum = (con.Birthdate__c!=null) ? con.Birthdate__c : null;
                ci.gender = (con.Gender__c!=null && con.Gender__c!='') ? con.Gender__c : '';
                
                ci.isGender = false;
                ci.isGeboortedatum = false;
                ci.isAdres = false;
                ci.isPostcode = false;
                ci.isGemeente = false;
                
                response.put('contact',ci);
                response.put('formInfo',getFormInfo());
                response.put('isSuccess',true);
            }
        }else{
            response.put('isSuccess',false);
            response.put('message','Foutieve link');
        }
        return response;
    }
    
    public static formRes getFormInfo(){
        formRes fr = new formRes();
        fr.highestDegree = '';
        fr.currentSituation = '';
        fr.visitMusea = '';
        fr.interest = new List<String>();
        fr.reasonVisit = '';
        fr.otherSituationCurrent = '';
        fr.reasonNoVisit = new List<String>();
        fr.otherReasonNoVisit = '';
        fr.contextVisit = new List<String>();
        fr.otherContextVisit = '';
        
        /*
fr.studyArea = new List<String>();
fr.otherStudyArea = '';
fr.whatdoYouStudy = '';
fr.workSector = new List<String>();
fr.otherWorkSector = '';
fr.profession = '';
*/
        
        return fr;
    }
    
    @AuraEnabled
    public static Map<String,Object> saveResponse(conInfo conInfo , formRes formInfo){
        Map<String,Object> response = new Map<String,Object>();
        try{
            Contact con = new Contact();
            con.Id = conInfo.conId;
            if(!conInfo.isVoornaam) con.FirstName = conInfo.voornaam;
            if(!conInfo.isNaam) con.LastName = conInfo.naam;
            if(!conInfo.isAdres) con.MailingStreet = conInfo.adres;
            if(!conInfo.isPostcode) con.MailingPostalCode = conInfo.postcode;
            if(!conInfo.isGemeente) con.MailingCity = conInfo.gemeente;
            if(!conInfo.isEmail) con.Email = conInfo.email;
            if(!conInfo.isGeboortedatum) con.Birthdate__c = conInfo.geboortedatum;
            if(!conInfo.isGender) con.Gender__c = conInfo.gender;
            update con;
            
            Form__c form = new Form__c();
            form.Contact__c = con.Id;
            form.RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByName().get('KUL - Eye-tracking').getRecordTypeId();
            form.Highest_Degree__c = formInfo.highestDegree;
            form.Current_Situation__c = formInfo.currentSituation;
            form.Visits_musea_last_year__c = formInfo.visitMusea;
            form.interests__c = (formInfo.interest!=null && formInfo.interest.size()>0) ? String.join(formInfo.interest, ';') : '';
            form.Reason_no_visits__c = (formInfo.reasonNoVisit!=null && formInfo.reasonNoVisit.size()>0) ? String.join(formInfo.reasonNoVisit, ';') : '';
            form.Context_Visits__c = (formInfo.contextVisit!=null && formInfo.contextVisit.size()>0) ? String.join(formInfo.contextVisit, ';') : '';
            
            form.Reason_Visits__c = formInfo.reasonVisit;
            form.Current_Situation_Other__c = formInfo.otherSituationCurrent;
            form.Reason_no_visits_Other__c = formInfo.otherReasonNoVisit;
            form.Context_Visits_Other__c = formInfo.otherContextVisit;
            insert form;
            
            response.put('isSuccess',true);
        }catch(Exception ex){
            response.put('isSuccess',false);
            response.put('message',ex.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static Map<String,Object> getAllPicklistMap(){
        Map<String,Object> response = new Map<String,Object>();
        response.put('getGender', getPicklistMap('Contact','Gender__c'));
        response.put('getHighestDegree', getPicklistMap('form__c','Highest_Degree__c'));
        response.put('getCurrentSituation', getPicklistMap('form__c','Current_Situation__c'));
        response.put('getVisitMusea', getPicklistMap('form__c','Visits_musea_last_year__c'));
        response.put('getInterest', getPicklistMap('form__c','interests__c'));
        response.put('getReasonVisits', getPicklistMap('form__c','Reason_Visits__c'));
        response.put('getStudyArea', getPicklistMap('form__c','Study_area__c'));
        response.put('getWorkSector', getPicklistMap('form__c','Work_Sector__c'));
        response.put('getReasonNoVisit', getPicklistMap('form__c','Reason_no_visits__c'));
        response.put('getContextVisit', getPicklistMap('form__c','Context_Visits__c'));
        
        return response;
    }
    
    public static Map<String,String> getPicklistMap(String objectName, String fieldName){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    public class formRes{
        @AuraEnabled public String highestDegree {get;set;}
        @AuraEnabled public String currentSituation {get;set;}
        @AuraEnabled public String visitMusea {get;set;}
        @AuraEnabled public List<String> interest {get;set;}
        @AuraEnabled public String reasonVisit {get;set;}
        @AuraEnabled public String otherSituationCurrent {get;set;}
        @AuraEnabled public List<String> reasonNoVisit {get;set;}
        @AuraEnabled public String otherReasonNoVisit {get;set;}
        @AuraEnabled public List<String> contextVisit {get;set;}
        @AuraEnabled public String otherContextVisit {get;set;}
        
        /*
@AuraEnabled public List<String> studyArea {get;set;}
@AuraEnabled public String otherStudyArea {get;set;}
@AuraEnabled public String whatdoYouStudy {get;set;}
@AuraEnabled public List<String> workSector {get;set;}
@AuraEnabled public String otherWorkSector {get;set;}
@AuraEnabled public String profession {get;set;}
*/
    }
    
    public class conInfo{
        @AuraEnabled public Id conId {get;set;}
        @AuraEnabled public String voornaam {get;set;}
        @AuraEnabled public Boolean isVoornaam {get;set;}
        @AuraEnabled public String naam {get;set;}
        @AuraEnabled public Boolean isNaam {get;set;}
        @AuraEnabled public String adres {get;set;}
        @AuraEnabled public Boolean isAdres {get;set;}
        @AuraEnabled public String postcode {get;set;}
        @AuraEnabled public Boolean isPostcode {get;set;}
        @AuraEnabled public String gemeente {get;set;}
        @AuraEnabled public Boolean isGemeente {get;set;}
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public Boolean isEmail {get;set;}
        @AuraEnabled public Date geboortedatum {get;set;}
        @AuraEnabled public Boolean isGeboortedatum {get;set;}
        @AuraEnabled public String gender {get;set;}
        @AuraEnabled public Boolean isGender {get;set;}
    }
}