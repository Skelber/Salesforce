public with sharing class BrokerCalloutClass {

    public static Boolean stopTrigger = false;
    
    @future(callout=true)
    public static void makeCallout(Set <Id> accountIds){
        List <Account> accountList = [SELECT Id, Name, Ondernemingsnummer__c, BillingStreet, BillingPostalCode, BillingCity,
                                    Status_FSMA__c, Statuut__c, Juridische_vorm__c, OwnerId, Rekeningnummer__c,
                                    Emailadres_Commissies__c, ParentId, Is_Active__c, Creanet_Published__c, Account_Manager_Creanet_Id__c,
                                    Phone, Algemeen_Emailadres__c
        FROM Account WHERE Id IN :accountIds];
        system.debug('accountList: ' + accountList);
        if (!accountList.isEmpty()) {
            Creanet_Credentials__c cs = Creanet_Credentials__c.getInstance();
            String accessToken = CalloutUtils.getToken(cs);
            if (String.isNotBlank(accessToken)) {
                Map <String, Map <String, String>> metadataMap = CalloutUtils.getMetadata();
                system.debug('metadataMap: ' + metadataMap);
                for (Account newAccount : accountList) {
                    system.debug('calling update for: ' + newAccount.Id);
                    HttpRequest reqAccount = new HttpRequest();
                    reqAccount.setHeader('Content-Type', 'application/json');
                    if (newAccount.Creanet_Published__c) {
                        reqAccount.setEndpoint(cs.url__c + '/api/third-parties/salesforce/brokers/' + newAccount.Id + '/');
                        reqAccount.setMethod('PUT');
                    } else {
                        reqAccount.setEndpoint(cs.url__c + '/api/third-parties/salesforce/brokers/');
                        reqAccount.setMethod('POST');
                    }
                    reqAccount.setHeader('Accept', 'application/json');
                    reqAccount.setHeader('Authorization', 'Bearer ' + accessToken);
                    System.debug('reqAccount ' + reqAccount.getHeader('Authorization'));

                    Map <String, String> fsma_status_map = metadataMap.get('fsma_status');
                    Map <String, String> broker_type_map = metadataMap.get('broker_type');
                    Map <String, String> company_type_map = metadataMap.get('company_type');
                    String fsma_status = '';
                    String broker_type = '';
                    String company_type = '';
                    system.debug('fsma_status_map: ' + fsma_status_map);
                    system.debug('newAccount.Status_FSMA__c: ' + newAccount.Status_FSMA__c);
                    if (fsma_status_map.containsKey(newAccount.Status_FSMA__c)) {
                        fsma_status = fsma_status_map.get(newAccount.Status_FSMA__c);
                    }
                    system.debug('broker_type_map: ' + broker_type_map);
                    system.debug('newAccount.Statuut__c: ' + newAccount.Statuut__c);
                    if (broker_type_map.containsKey(newAccount.Statuut__c)) {
                        broker_type = broker_type_map.get(newAccount.Statuut__c);
                    }
                    system.debug('company_type_map: ' + company_type_map);
                    system.debug('newAccount.Juridische_vorm__c: ' + newAccount.Juridische_vorm__c);
                    if (company_type_map.containsKey(newAccount.Juridische_vorm__c)) {
                        company_type = company_type_map.get(newAccount.Juridische_vorm__c);
                    }
                    system.debug('fsma_status: ' + fsma_status);
                    system.debug('broker_type: ' + broker_type);
                    system.debug('company_type: ' + company_type);
                    String theBody = '{';
                    theBody += '"name":"' + newAccount.Name + '",';
                    if (newAccount.Algemeen_Emailadres__c == '' || newAccount.Algemeen_Emailadres__c == null)
                        theBody += '"email":null,';
                    else
                        theBody += '"email":"' + newAccount.Algemeen_Emailadres__c + '",';
                    if (newAccount.Phone == '' || newAccount.Phone == null)
                        theBody += '"phone_number":null,';
                    else
                        theBody += '"phone_number":"' + newAccount.Phone + '",';
                    theBody += '"vat_number":"' + newAccount.Ondernemingsnummer__c + '",';
                    theBody += '"address": {';
                    theBody += '"street":"' + newAccount.BillingStreet + '",';
                    theBody += '"house_number":"",';
                    theBody += '"box":"",';
                    theBody += '"zip_code":"' + newAccount.BillingPostalCode + '",';
                    theBody += '"city":"' + newAccount.BillingCity + '",';
                    theBody += '"country": {"id": 2}},';
                    theBody += '"external_id":"' + newAccount.Id + '",';
                    if (fsma_status == '')
                        theBody += '"fsma_status": {"definition": null},';
                    else
                        theBody += '"fsma_status": {"definition": "' + fsma_status + '"},';
                    if (broker_type == '')
                        theBody += '"broker_type": {"definition": null},';
                    else
                        theBody += '"broker_type": {"definition": "' + broker_type + '"},';
                    if (company_type == '')
                        theBody += '"company_type": {"definition": null},';
                    else
                        theBody += '"company_type": {"definition": "' + company_type + '"},';
                    theBody += '"account_manager": {"id":"' + newAccount.Account_Manager_Creanet_Id__c + '"},';
                    //theBody += '"account_manager": {"id":"158"},';
                    theBody += '"bank_account":"' + newAccount.Rekeningnummer__c + '",';
                    if (newAccount.Emailadres_Commissies__c == '' || newAccount.Emailadres_Commissies__c == null)
                        theBody += '"commission_email":null,'; else
                            theBody += '"commission_email":"' + newAccount.Emailadres_Commissies__c + '",';
                    if (newAccount.ParentId == null)
                        theBody += '"parent_external_id":null,'; else
                            theBody += '"parent_external_id":"' + newAccount.ParentId + '",';
                    theBody += '"is_active":' + newAccount.Is_Active__c + '}';
                    system.debug('account callout body: ' + theBody);

                    reqAccount.setBody(theBody);
                    Http httpAccount = new Http();
                    HTTPResponse resAccount = httpAccount.send(reqAccount);
                    String theMessage = resAccount.getBody();
                    system.debug('account callout response: ' + resAccount.getBody());
                    if (theMessage != null) {
                        if (theMessage.length() > 32000) {
                            theMessage = theMessage.substring(0, 32000);
                        }
                    }

                    String statusCode = String.valueOf(resAccount.getStatusCode());
                    system.debug('account callout statusCode: ' + statusCode);
                    if (statusCode != null) {
                        if (statusCode.length() > 3) {
                            statusCode = statusCode.substring(0, 3);
                        }
                    }
                    newAccount.Creanet_Last_Call__c = system.now();
                    newAccount.Creanet_Status_Code__c = statusCode;
                    if (statusCode == '200' || statusCode == '201') {
                        newAccount.Creanet_Status_Message__c = '';
                        newAccount.Creanet_Published__c = true;
                    } else {
                        newAccount.Creanet_Status_Message__c = theMessage;
                    }
                }
                BrokerCalloutClass.stopTrigger = true;
                update accountList;
            }
        }
    }
    
    @future(callout=true)
    public static void makeDeactivationCallout(Set <Id> accountIds, Boolean activating){
        List <Account> accountList = [SELECT Id, Is_Active__c
                                    FROM Account WHERE Id IN :accountIds OR ParentId IN :accountIds];
        system.debug('accountList: ' + accountList);
        if (!accountList.isEmpty()){
            Creanet_Credentials__c cs = Creanet_Credentials__c.getInstance();
            String accessToken = CalloutUtils.getToken(cs);
            if (String.isNotBlank(accessToken)) {
                for (Account newAccount : accountList) {
                    if (activating) {
                        system.debug('calling activation for: ' + newAccount.Id);
                    } else {
                        system.debug('calling deactivation for: ' + newAccount.Id);
                    }
                    HttpRequest reqAccount = new HttpRequest();
                    reqAccount.setHeader('Content-Type', 'application/json');
                    reqAccount.setEndpoint(cs.url__c + '/api/third-parties/salesforce/brokers/' + newAccount.Id + '/activate/');
                    reqAccount.setMethod('POST');
                    reqAccount.setHeader('Accept', 'application/json');
                    reqAccount.setHeader('Authorization', 'Bearer ' + accessToken);

                    String theBody = '{';
                    theBody += '"is_active":"' + activating + '"}';
                    system.debug('theBody: ' + theBody);

                    reqAccount.setBody(theBody);
                    Http httpAccount = new Http();
                    HTTPResponse resAccount = httpAccount.send(reqAccount);
                    String theMessage = resAccount.getBody();
                    system.debug('theMessage: ' + resAccount.getBody());
                    if (theMessage != null) {
                        if (theMessage.length() > 32000) {
                            theMessage = theMessage.substring(0, 32000);
                        }
                    }

                    String statusCode = String.valueOf(resAccount.getStatusCode());
                    if (statusCode != null) {
                        if (statusCode.length() > 3) {
                            statusCode = statusCode.substring(0, 3);
                        }
                    }
                    newAccount.Creanet_Last_Call__c = system.now();
                    newAccount.Creanet_Status_Code__c = statusCode;
                    if (statusCode == '200' || statusCode == '201') {
                        newAccount.Creanet_Status_Message__c = '';
                        newAccount.Creanet_Published__c = true;
                        if (activating) {
                            newAccount.Status__c = 'Actief';
                        } else {
                            newAccount.Status__c = 'Niet-actief';
                        }
                    } else {
                        newAccount.Creanet_Status_Message__c = theMessage;
                    }
                }
                BrokerCalloutClass.stopTrigger = true;
                update accountList;
            }
        }
    }

}