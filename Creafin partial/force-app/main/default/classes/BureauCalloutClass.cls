public with sharing class BureauCalloutClass {

    public static Boolean stopTrigger = false;
    @future(callout=true)
    public static void makeCallout(Set <Id> contactIds){
        List <Contact> contactList = [SELECT Id, Name, FirstName, LastName, MailingStreet, MailingPostalCode, MailingCity,
                AccountId, Creanet_User__c, Creanet_Published__c, Email, Phone, Taal__c, Creanet_Bureau_Published__c,
                Key_Account__c, Bureau__c, Account.Statuut__c, Creanet_Email__c, Account_Manager_Creanet_Id__c
                FROM Contact WHERE Id IN :contactIds];
        if (!contactList.isEmpty()){
            Creanet_Credentials__c cs = Creanet_Credentials__c.getInstance();
            String accessToken = CalloutUtils.getToken(cs);
            System.debug('Accesstoken ' + accessToken);
            if (String.isNotBlank(accessToken)) {
                for (Contact newContact : contactList) {
                    system.debug('calling broker in BureauCalloutClass for: ' + newContact.Id);
                    HttpRequest reqAccount = new HttpRequest();
                    reqAccount.setHeader('Content-Type', 'application/json');
                    if (newContact.Creanet_Bureau_Published__c){
                        reqAccount.setEndpoint(cs.url__c + '/api/third-parties/salesforce/brokers/' + newContact.Id + '/');
                        reqAccount.setMethod('PUT');
                    }
                    else{
                        reqAccount.setEndpoint(cs.url__c + '/api/third-parties/salesforce/brokers/');
                        reqAccount.setMethod('POST');
                    }
                    reqAccount.setHeader('Accept', 'application/json');
                    reqAccount.setHeader('Authorization', 'Bearer ' + accessToken);

                    Map <String, Map <String, String>> metadataMap = CalloutUtils.getMetadata();
                    system.debug('metadataMap: ' + metadataMap);
                    Map <String, String> broker_type_map = metadataMap.get('broker_type');
                    String broker_type = '';
                    system.debug('broker_type_map: ' + broker_type_map);
                    system.debug('newAccount.Statuut__c: ' + newContact.Account.Statuut__c);
                    if (broker_type_map.containsKey(newContact.Account.Statuut__c)) {
                        broker_type = broker_type_map.get(newContact.Account.Statuut__c);
                    }
                    system.debug('broker_type: ' + broker_type);

                    String theBody = '{';
                    theBody += '"name":"' + newContact.Bureau__c     + '",';
                    if (newContact.Email == '' || newContact.Email == null)
                        theBody += '"email":null,';
                    else
                        theBody += '"email":"' + newContact.Email + '",';
                    if (newContact.Phone == '' || newContact.Phone == null)
                        theBody += '"phone_number":null,';
                    else
                        theBody += '"phone_number":"' + newContact.Phone + '",';
                    theBody += '"address": {';
                    theBody += '"street":"' + newContact.MailingStreet + '",';
                    theBody += '"house_number":"",';
                    theBody += '"box":"",';
                    theBody += '"zip_code":"' + newContact.MailingPostalCode + '",';
                    theBody += '"city":"' + newContact.MailingCity + '",';
                    theBody += '"country": {"id": 2}},';
                    if (broker_type == '')
                        theBody += '"broker_type": {"id": null},';
                    else
                        theBody += '"broker_type": {"id": ' + broker_type + '},';
                    theBody += '"account_manager": {"id":"' + newContact.Account_Manager_Creanet_Id__c + '"},';
                    theBody += '"external_id":"' + newContact.Id + '",';
                    theBody += '"parent_external_id":"' + newContact.AccountId + '"}';
                    system.debug('bureau callout body: ' + theBody);

                    reqAccount.setBody(theBody);
                    Http httpAccount = new Http();
                    HTTPResponse resAccount = httpAccount.send(reqAccount);
                    String theMessage = resAccount.getBody();
                    system.debug('bureau callout response: ' + resAccount.getBody());
                    if (theMessage != null){
                        if (theMessage.length() > 32000){
                            theMessage = theMessage.substring(0,32000);
                        }
                    }

                    String statusCode =  String.valueOf(resAccount.getStatusCode());
                    system.debug('bureau callout statusCode: ' + statusCode);
                    if (statusCode != null){
                        if (statusCode.length() > 3){
                            statusCode = statusCode.substring(0,3);
                        }
                    }
                    newContact.Creanet_Last_Call__c = system.now();
                    newContact.Creanet_Status_Code__c = statusCode;
                    if (statusCode == '200' || statusCode == '201'){
                        newContact.Creanet_Bureau_Published__c = true;
                        List<String> response = BureauCalloutClass.makeContactCallout(newContact, cs, accessToken);
                        if (response[1] == '') {
                            newContact.Creanet_Status_Message__c = '';
                            newContact.Creanet_Published__c = true;
                        } else {
                            newContact.Creanet_Status_Message__c = response[1];
                        }
                        newContact.Creanet_Status_Code__c = response[0];
                    }
                    else{
                        newContact.Creanet_Status_Message__c = theMessage;
                    }
                }
                ContactCalloutClass.stopTrigger = true;
                update contactList;
            }
        }
    }

    public static List<String> makeContactCallout(Contact newContact, Creanet_Credentials__c cs, String accessToken){
        List<String> response = new List<String>();
        Map <String, String> languageMap = CalloutUtils.getLanguageMap();
        system.debug('languageMap: ' + languageMap);
        HTTPResponse res = CalloutUtils.makeContactCallout(cs, newContact, languageMap, accessToken);
        String statusCode =  String.valueOf(res.getStatusCode());
        system.debug('bureau contact callout statusCode: ' + statusCode);
        if (statusCode != null){
            if (statusCode.length() > 3){
                statusCode = statusCode.substring(0,3);
            }
        }
        if (statusCode == '200' || statusCode == '201'){
            response.add(statusCode);
            response.add('');
            return response;
        } else {
            String theMessage = res.getBody();
            system.debug('theMessage: ' + res.getBody());
            system.debug('bureau contact callout response: ' + theMessage);
            if (theMessage != null){
                if (theMessage.length() > 32000){
                    theMessage = theMessage.substring(0,32000);
                }
            }
            response.add(statusCode);
            response.add(theMessage);
            return response;
        }
    }
}