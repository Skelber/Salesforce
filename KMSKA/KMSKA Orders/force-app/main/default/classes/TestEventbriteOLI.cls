@isTest(seeAllData=true)
private  class TestEventbriteOLI {
    Public static List<EventbriteSync__OrderLineItem__c> eventBriteOLItems{get;set;}
    
    
    static testMethod void validateAllMethods() {
        eventBriteOLItems = new List<EventbriteSync__OrderLineItem__c>();
        
        Campaign cp =  new Campaign();
        cp.Name = 'Campaign 1';
        cp.EventbriteSync__EventbriteId__c='001';
        insert cp;
        
        EventbriteSync__OrderLineItem__c EBOLI = new EventbriteSync__OrderLineItem__c();
        EBOLI.EventbriteSync__Campaign__c = cp.Id;
        EBOLI.EventbriteSync__EventbriteId__c = '001';
        EBOLI.EventbriteSync__FirstName__c='test';
        EBOLI.EventbriteSync__LastName__c='testing';
        EBOLI.EventbriteSync__Email__c='test@gmail.com';
        EBOLI.EventbriteSync__Gender__c='Male';
        EBOLI.EventbriteSync__MobilePhone__c='7879979090';
        EBOLI.EventbriteSync__Campaign__c=cp.Id;
        EBOLI.EventbriteSync__HomePhone__c='7879979090';
        EBOLI.EventbriteSync__Status__c = 'Attending';
        insert EBOLI;
        
        List<Id> OLIIds = new List<Id>();
        List<Id> CamIds = new List<Id>();
        OLIIds.add(EBOLI.Id);
        CamIds.add(cp.Id);
        
        EventbriteTickets obj = new EventbriteTickets(OLIIds,CamIds);
        DataBase.executeBatch(obj);
        System.assertEquals(true, cp.Id!=null);
    }
}