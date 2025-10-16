public with sharing class CalloutUtils {

    public static String getToken(Creanet_Credentials__c cs){
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(cs.url__c + '/api/jwt/');
        req.setMethod('POST');
        req.setBody('{"username":"' + cs.username__c + '","password":"' + cs.password__c + '"}');
        req.setHeader('Accept', 'application/json');
        
        req.setHeader('Referer', 'https://'+url.getOrgDomainUrl().getHost());
        
        system.debug('request: ' + req.getBody());
        system.debug('endpoint: ' + req.getEndpoint());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('response: ' + res.getBody());
        JSONParser parser = JSON.createParser(res.getBody());
        String refreshToken = '';
        String accessToken = '';
        while (parser.nextToken() != null) {
            String thisKey = parser.getText();
            system.debug('TOKEN 1: ' + parser.getText());
            if (thisKey == 'refresh'){
                parser.nextToken();
                refreshToken = parser.getText();
            }
            else if (thisKey == 'access'){
                parser.nextToken();
                accessToken = parser.getText();
            }
        }
        system.debug('refreshToken: ' + refreshToken);
        system.debug('accessToken: ' + accessToken);
        return accessToken;
    }

    public static HTTPResponse makeContactCallout(Creanet_Credentials__c cs, Contact newContact, Map <String, String> languageMap, String accessToken){
        HttpRequest reqContact = new HttpRequest();
        reqContact.setHeader('Content-Type', 'application/json');
        if (newContact.Creanet_Published__c){
            reqContact.setEndpoint(cs.url__c + '/api/third-parties/salesforce/brokers/' + newContact.AccountId + '/users/' + newContact.Id + '/');
            reqContact.setMethod('PUT');
        }
        else{
            reqContact.setEndpoint(cs.url__c + '/api/third-parties/salesforce/brokers/' + newContact.AccountId + '/users/');
            reqContact.setMethod('POST');
        }
        reqContact.setHeader('Accept', 'application/json');
        reqContact.setHeader('Authorization', 'Bearer ' + accessToken);

        String language = '';
        system.debug('newContact.Taal__c: ' + newContact.Taal__c);
        if (languageMap.containsKey(newContact.Taal__c)){
            language = languageMap.get(newContact.Taal__c);
        }
        system.debug('language: ' + language);
        String theBody = '{';
        theBody += '"external_id":"' + newContact.Id + '",';
        theBody += '"is_active":"' + newContact.Creanet_User__c + '",';
        theBody += '"first_name":"' + newContact.FirstName + '",';
        theBody += '"last_name":"' + newContact.LastName + '",';
        if (newContact.Email == '' || newContact.Email == null)
            theBody += '"email":null,';
        else
            theBody += '"email":"' + newContact.Email + '",';
        if (newContact.Creanet_Email__c == '' || newContact.Creanet_Email__c == null)
            theBody += '"creanetEmail":null,';
        else
            theBody += '"creanetEmail":"' + newContact.Creanet_Email__c + '",';
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
        theBody += '"key_account":' + newContact.Key_Account__c + ',';
        if (language == '')
            theBody += '"language": {"id": null}';
        else
            theBody += '"language": {"id": ' + language + '}';
        theBody += '}';

        system.debug('contact callout body: ' + theBody);

        reqContact.setBody(theBody);
        Http httpContact = new Http();
        HTTPResponse resContact = httpContact.send(reqContact);
        return resContact;
    }

    public static Map <String, String> getLanguageMap () {
        List <Creanet_Metadata__mdt> metadataList = [SELECT Id, Type__c, Code__c, Value__c FROM Creanet_Metadata__mdt WHERE Type__c = 'language'];
        system.debug('metadataList: ' + metadataList);
        Map <String, String> languageMap = new Map <String, String>();
        for (Creanet_Metadata__mdt thisRecord : metadataList){
            system.debug('adding to map: ' + thisRecord.Value__c + ' : ' + thisRecord.Code__c);
            languageMap.put(thisRecord.Value__c, thisRecord.Code__c);
        }
        return languageMap;
    }

    public static Map <String, Map <String, String>> getMetadata () {
        List <Creanet_Metadata__mdt> metadataList = [SELECT Id, Type__c, Code__c, Value__c FROM Creanet_Metadata__mdt];
        system.debug('metadataList: ' + metadataList);
        Map <String, Map <String, String>> metadataMap = new Map <String, Map <String, String>>();
        for (Creanet_Metadata__mdt thisRecord : metadataList) {
            Map <String, String> aux = new Map <String, String>();
            if (metadataMap.containsKey(thisRecord.Type__c)) {
                aux = metadataMap.get(thisRecord.Type__c);
            }
            aux.put(thisRecord.Value__c, thisRecord.Code__c);
            system.debug('adding to aux: ' + thisRecord.Value__c + ' : ' + thisRecord.Code__c);
            metadataMap.put(thisRecord.Type__c, aux);
        }
        return metadataMap;
    }
}