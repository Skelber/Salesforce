trigger BrokerCallout on Account (after insert, after update) {
    
    if (BrokerCalloutClass.stopTrigger) return;

	BrokerCalloutClass.stopTrigger = true;
    
    Set <Id> accountIds = new Set <Id>();
    Set <Id> deactivateAccountIds = new Set <Id>();
    Set <Id> activateAccountIds = new Set <Id>();
    for (Account newAccount : trigger.new){
    	system.debug('account record type: ' + newAccount.Record_Type_Name__c);
    	if (newAccount.Record_Type_Name__c == 'Makelaar'){
    		accountIds.add(newAccount.Id);
    	}

		if (trigger.isUpdate){
			Account oldAccount = trigger.oldMap.get(newAccount.Id);
			system.debug('account is active: ' + newAccount.Is_Active__c);
			system.debug('old account is active: ' + oldAccount.Is_Active__c);
			if (!newAccount.Is_Active__c && oldAccount.Is_Active__c){
	    		deactivateAccountIds.add(newAccount.Id);
	    	}
	    	else if (newAccount.Is_Active__c && !oldAccount.Is_Active__c){
	    		activateAccountIds.add(newAccount.Id);
	    	}
		}

    }
    
    system.debug('accountIds: ' + accountIds);
    if (!accountIds.isEmpty()){
    	BrokerCalloutClass.makeCallout(accountIds);
    }
    
    system.debug('deactivateAccountIds: ' + deactivateAccountIds);
    if (!deactivateAccountIds.isEmpty()){
    	BrokerCalloutClass.makeDeactivationCallout(deactivateAccountIds, false);
    }
    
    system.debug('activateAccountIds: ' + activateAccountIds);
    if (!activateAccountIds.isEmpty()){
    	BrokerCalloutClass.makeDeactivationCallout(activateAccountIds, true);
    }
    
}