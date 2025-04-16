global class EventbriteTickets implements Database.Batchable<sObject>, Database.stateful{
    
    global String query;
    global List<Id> OrderLineItemsIds;
    global List<Id> CampaignIds;
    global map<String,String> RelatedCon;    
    global EventbriteTickets(List<Id> OLIIds,List<Id> CamIds){
        this.OrderLineItemsIds = OLIIds;
        this.CampaignIds = CamIds;
        
        query = 'SELECT Id, Name,EventbriteSync__FirstName__c,EventbriteSync__LastName__c,EventbriteSync__Email__c,EventbriteSync__Gender__c,EventbriteSync__MobilePhone__c,EventbriteSync__Campaign__c,EventbriteSync__HomePhone__c,EventbriteSync__EventbriteId__c, EventbriteSync__EventId__c,EventbriteSync__Status__c FROM EventbriteSync__OrderLineItem__c ';
        query += 'WHERE ID IN :OrderLineItemsIds';
        RelatedCon = new map<String,String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope){
        
        list<String> ConLName = new list<String>();
        list<String> ConEmail = new list<String>();
        
        for(sObject s:scope){
            EventbriteSync__OrderLineItem__c OLI = (EventbriteSync__OrderLineItem__c)s;
            if(!ConLName.contains(OLI.EventbriteSync__LastName__c)){
                ConLName.add(OLI.EventbriteSync__LastName__c);
            }
            if(!ConEmail.contains(OLI.EventbriteSync__Email__c)){
                ConEmail.add(OLI.EventbriteSync__Email__c);
            }
        }
        list<Contact> ExCon = [SELECT Id, LastName , Email , Eventbrite_Id__c FROM Contact WHERE LastName IN:ConLName AND Email IN:ConEmail ];
        map<String, Contact> ExistingCon = new map<String,Contact>();
        for(Contact Con : ExCon){
            String LnameEmail = Con.LastName+'_'+Con.Email;
            if(!ExistingCon.containsKey(LnameEmail)){
                ExistingCon.put(LnameEmail,Con); 
            }
        }
        
        map<String,String> ProcessedOLI = new map<String,String>();
        
        list<Contact> lstCon = new list<Contact>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<CampaignMember> lstcampMem = new List<CampaignMember>();
        for(sObject s:scope){
            EventbriteSync__OrderLineItem__c OLI = (EventbriteSync__OrderLineItem__c)s;
            
            if(!ProcessedOLI.ContainsKey(OLI.EventbriteSync__LastName__c+'_'+OLI.EventbriteSync__Email__c)){
                ProcessedOLI.put(OLI.EventbriteSync__LastName__c+'_'+OLI.EventbriteSync__Email__c,OLI.EventbriteSync__EventbriteId__c);
            }
            
            if(ExistingCon.containsKey(OLI.EventbriteSync__LastName__c+'_'+OLI.EventbriteSync__Email__c)){
                RelatedCon.put(OLI.EventbriteSync__EventbriteId__c,ExistingCon.get(OLI.EventbriteSync__LastName__c+'_'+OLI.EventbriteSync__Email__c).Eventbrite_Id__c);
            }else if(ProcessedOLI.ContainsKey(OLI.EventbriteSync__LastName__c+'_'+OLI.EventbriteSync__Email__c)
                    && ProcessedOLI.get(OLI.EventbriteSync__LastName__c+'_'+OLI.EventbriteSync__Email__c)!= OLI.EventbriteSync__EventbriteId__c
                    ){
                RelatedCon.put(OLI.EventbriteSync__EventbriteId__c,ProcessedOLI.get(OLI.EventbriteSync__LastName__c+'_'+OLI.EventbriteSync__Email__c));
            }else{
                Contact con = new Contact();
                con.Eventbrite_Id__c = OLI.EventbriteSync__EventbriteId__c;
                con.FirstName = OLI.EventbriteSync__FirstName__c;
                con.LastName = OLI.EventbriteSync__LastName__c;
                con.Email = OLI.EventbriteSync__Email__c;
                con.Status__c = OLI.EventbriteSync__Status__c;
                con.Campaign__c = OLI.EventbriteSync__Campaign__c;
                con.Contact_Type__c = 'Contact'; //Required Field.
                
                lstCon.add(con);
                RelatedCon.put(OLI.EventbriteSync__EventbriteId__c,OLI.EventbriteSync__EventbriteId__c);
            }
        }
        
        if(lstCon.size()>0){
            upsert lstCon Eventbrite_Id__c;
        }
        
        list<Contact> UpdatedCon = [SELECT Id,AccountId,Campaign__c,Eventbrite_Id__c,Name,Status__c FROM Contact WHERE  Eventbrite_Id__c IN : RelatedCon.keySet()];
        
        map<String,Contact> ExtCont= new map<String,Contact>();
        
        for(Contact con : UpdatedCon){
            ExtCont.put(con.Eventbrite_Id__c,con);
        }
        
        map<Id,Campaign> campaignLst = new map<Id,Campaign>([SELECT Id , Name FROM Campaign WHERE ID IN :CampaignIds]);
        
        Id OppTicketTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        for(sObject s:scope){
            EventbriteSync__OrderLineItem__c OLI = (EventbriteSync__OrderLineItem__c)s;
            
            Opportunity opp = new Opportunity();
            opp.CampaignId = OLI.EventbriteSync__Campaign__c;
            opp.Eventbrite_Id__c = OLI.EventbriteSync__EventbriteId__c;
            opp.Name = 'Ticket of '+ (campaignLst.get(OLI.EventbriteSync__Campaign__c)).Name;
            opp.StageName = 'Closed Won';
            opp.npsp__Primary_Contact__c = (ExtCont.get(RelatedCon.get(OLI.EventbriteSync__EventbriteId__c))).Id;
            opp.AccountId = (ExtCont.get(RelatedCon.get(OLI.EventbriteSync__EventbriteId__c))).AccountId;
            opp.RecordTypeId = OppTicketTypeId;
            opp.CloseDate = date.today(); //Required FIeld
            
            lstOpp.add(opp);   
        }
        if(lstOpp.size()>0){
            upsert lstOpp Eventbrite_Id__c;
        }
        
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}