trigger ContactCallout on Contact (after insert, after update) {
    
    if (ContactCalloutClass.stopTrigger) return;
    
    Set <Id> contactIds = new Set <Id>();
    Set <Id> bureauIds = new Set <Id>();
    for (Contact newContact : trigger.new){
    	system.debug('account record type: ' + newContact.Account_Record_Type_Name__c);
    	system.debug('account creanet published: ' + newContact.Account_Creanet_Published__c);
    	if (newContact.Account_Record_Type_Name__c == 'Makelaar' && newContact.Account_Creanet_Published__c && newContact.Creanet_User_current_Historical__c){
            if (String.isNotBlank(newContact.Bureau__c)) {
                bureauIds.add(newContact.Id);
            } else {
                contactIds.add(newContact.Id);
            }
    	}
    }
    
    system.debug('contactIds: ' + contactIds);
    if (!contactIds.isEmpty()){
    	ContactCalloutClass.makeCallout(contactIds);
    }

    system.debug('bureauIds: ' + bureauIds);
    if (!bureauIds.isEmpty()){
        BureauCalloutClass.makeCallout(bureauIds);
    }
    
}