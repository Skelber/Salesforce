public with sharing class ContactCalloutClass {
    
    public static Boolean stopTrigger = false;
    
    @future(callout=true)
    public static void makeCallout(Set <Id> contactIds){
    	List <Contact> contactList = [SELECT Id, FirstName, LastName, MailingStreet, MailingPostalCode, MailingCity,
    								AccountId, Creanet_User__c, Creanet_Published__c, Email, Phone, Taal__c,
    								Key_Account__c, Creanet_Email__c
    								FROM Contact WHERE Id IN :contactIds];
		if (!contactList.isEmpty()){
			Creanet_Credentials__c cs = Creanet_Credentials__c.getInstance();
			String accessToken = CalloutUtils.getToken(cs);
			if (String.isNotBlank(accessToken)) {
				Map <String, String> languageMap = CalloutUtils.getLanguageMap();
				system.debug('languageMap: ' + languageMap);

				for (Contact newContact : contactList) {
					HTTPResponse resContact = CalloutUtils.makeContactCallout(cs, newContact, languageMap, accessToken);
					String theMessage = resContact.getBody();
					system.debug('contact callout response: ' + resContact.getBody());
					if (theMessage != null) {
						if (theMessage.length() > 32000) {
							theMessage = theMessage.substring(0, 32000);
						}
					}

					String statusCode = String.valueOf(resContact.getStatusCode());
					system.debug('contact callout statusCode: ' + statusCode);
					if (statusCode != null) {
						if (statusCode.length() > 3) {
							statusCode = statusCode.substring(0, 3);
						}
					}
					newContact.Creanet_Last_Call__c = system.now();
					newContact.Creanet_Status_Code__c = statusCode;
					if (statusCode == '200' || statusCode == '201') {
						newContact.Creanet_Status_Message__c = '';
						newContact.Creanet_Published__c = true;
					} else {
						newContact.Creanet_Status_Message__c = theMessage;
					}
				}
				ContactCalloutClass.stopTrigger = true;
				update contactList;
			}
    	}
    }
    
}