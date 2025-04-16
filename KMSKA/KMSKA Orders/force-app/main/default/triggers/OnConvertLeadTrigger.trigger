trigger OnConvertLeadTrigger on Lead (after insert,after update) {
	Map<Id,Id> ContactIds = new Map<Id,Id>();
    
    for(Lead L : Trigger.new){
        if(L.isConverted && Trigger.oldMap.get(L.Id).isConverted ==false){
    		ContactIds.put(L.Id, L.ConvertedContactId);        
        }
    }
    
    if(ContactIds.size()>0){
        List<form__c> formstoUp = new List<form__c>();
        List<form__c> forms = [SELECT Id, Lead__c FROM form__c WHERE Lead__c IN: ContactIds.keySet()];
        for(form__c form : forms){
            form.Contact__c = ContactIds.get(form.Lead__c);
            formstoUp.add(form);
        }
        if(formstoUp.size()>0)Update formstoUp;
    }
}