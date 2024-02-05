global class Mock_Generator implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint().contains('services/oauth2/token')) {            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"SESSION_ID_REMOVED","instance_url":"https://csps2--steven.sandbox.my.salesforce.com","id":"https://test.salesforce.com/id/00D260000009L2BEAU/0057Q000006mqf5QAA","token_type":"Bearer","issued_at":"1701962691381","signature":"bSTdNMUJE3ONwo1+8iMPY6FLKpGPefv5H/ETV0j/fBw="}');
            res.setStatusCode(200);
            return res;
        } else if(req.getEndpoint().contains('FROM+Account')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Account","url":"/services/data/v59.0/sobjects/Account/0012600002CEG87AAH"},"Id":"0012600002CEG87AAH","Name":"TestAccount Steven","BillingAddress":null,"VAT__c":"BE987654321","ShippingAddress":null,"Email_for_invoices__c":null,"FullAddress__c":null}]}');
            res.setStatusCode(200);
            return res;
        } else if(req.getEndpoint().contains('sobjects/Account')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":"0012600002Es2KNAAZ","success":true,"errors":[]}');
            res.setStatusCode(200);
            return res;
        } else if(req.getEndpoint().contains('sobjects/Order/External_id__c')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"id":"80126000008PbB9AAK","success":true,"errors":[],"created":false}]');
            res.setStatusCode(200);
            return res;
        } else if(req.getEndpoint().contains('composite/sobjects') && req.getMethod() == 'POST') {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"id":"8022600000Iecv4AAB","success":true,"errors":[]}]');
            res.setStatusCode(200);
            return res;
        } else if(req.getEndpoint().contains('composite/sobjects') && req.getMethod() == 'PATCH') {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"id":"8022600000IectrAAB","success":true,"errors":[]}]');
            res.setStatusCode(200);
            return res;
        } else {
            return null;
        }
    }
    
}