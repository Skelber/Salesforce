public class Callout {
    
    public static String getAccessToken() {        
        Callout__c co = Callout__c.getOrgDefaults();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(co.OAutAuthURL__c);
        req.setMethod(co.method__c);
        req.setHeader('Content-Type', co.contentType__c);
        req.setHeader('Accept', co.accept__c);
        req.setBody('grant_type=password&client_id='+co.clientId__c+'&client_secret='+co.clientSecret__c+'&username='+co.username__c+'&password='+co.password__c);
        
        Http http = new Http();
        HttpResponse response = http.send(req);
        
        System.debug('REST response is :: '+response);
        System.debug(response.getBody());
        
        accessTokenResponse atr = (accessTokenResponse) System.JSON.deserialize(response.getBody(), accessTokenResponse.class);
        return atr.access_token;
    }
    
    public static AccountResult getAccounts(String btwnummer) {     
        Callout__c co = Callout__c.getOrgDefaults();                            
        HttpRequest req = new HttpRequest();
        req.setEndpoint(co.baseURL__c + '/services/data/v59.0/query/?q='
                        + 'SELECT+Id,Name,BillingAddress,VAT__c,ShippingAddress,Email_for_invoices__c,FullAddress__c,CSPSResponsibleEmail__c,Register_of_legal_entities__c,Register_of_legal_entities_department__c+FROM+Account+WHERE+VAT__c=\'' + btwnummer + '\'');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + getAccessToken());
        Http http = new Http();
        HttpResponse response = http.send(req);
        
        System.debug('REST response is :: '+response);
        System.debug(response.getBody());
        
        return (AccountResult) JSON.deserialize(response.getBody().replace('VAT__c', 'VAT').replace('Email_for_invoices__c', 'InvoiceEmail').replace('FullAddress__c', 'FullAddress').replace('Register_of_legal_entities_department__c', 'Register_of_legal_entities_department').replace('Register_of_legal_entities__c', 'Register_of_legal_entities').replace('CSPSResponsibleEmail__c', 'ResponsibleMail'), AccountResult.class);
    }
    
    public static String createAccount(String naam, String btwnummer, String billingstreet, String billingcity, String billingpostalcode, String billingstate, String billingcountry, String Register_of_legal_entities, String Register_of_legal_entities_department, String InvoiceEmail) {            
        
        Callout_CreateAccount__c co = Callout_CreateAccount__c.getOrgDefaults();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(co.Endpoint__c);
        req.setMethod(co.method__c);
        req.setHeader('Content-Type', co.contentType__c);
        req.setHeader('Accept', co.accept__c);
        req.setHeader('Authorization', 'Bearer ' + getAccessToken());
        System.debug('{"Name" : "' + naam + '","VAT__c" : "' + btwnummer + '","BillingStreet" : "' + billingstreet + '","BillingCity" : "' + billingcity 
                    + '","BillingPostalCode" : "' + billingpostalcode + '","BillingState" : "' + billingstate + '","BillingCountry" : "' + billingcountry 
                    + '","Register_of_legal_entities__c" : "' + Register_of_legal_entities + '","Register_of_legal_entities_department__c" : "' + Register_of_legal_entities_department +'","Email_for_invoices__c" : "' + InvoiceEmail +'"}');
        req.setBody('{"Name" : "' + naam + '","VAT__c" : "' + btwnummer + '","BillingStreet" : "' + billingstreet + '","BillingCity" : "' + billingcity 
                    + '","BillingPostalCode" : "' + billingpostalcode + '","BillingState" : "' + billingstate + '","BillingCountry" : "' + billingcountry 
                    + '","Register_of_legal_entities__c" : "' + Register_of_legal_entities + '","Register_of_legal_entities_department__c" : "' + Register_of_legal_entities_department +'","Email_for_invoices__c" : "' + InvoiceEmail +'"}');
        
        Http http = new Http();
        HttpResponse response = http.send(req);
        
        if(response.getstatusCode() < 300) {
            System.debug('REST response is :: '+response);
            System.debug(response.getBody());
            
            createResult cr = (createResult) JSON.deserialize(response.getBody(), createResult.class);
            System.debug(cr.success + ':' + cr.id);
            
            return (cr.success ? cr.id : null);
        } else {
            return response.getBody();
        }
    }
    
    public static String createAccount(String naam, String btwnummer) {            
        
        Callout_CreateAccount__c co = Callout_CreateAccount__c.getOrgDefaults();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(co.Endpoint__c);
        req.setMethod(co.method__c);
        req.setHeader('Content-Type', co.contentType__c);
        req.setHeader('Accept', co.accept__c);
        req.setHeader('Authorization', 'Bearer ' + getAccessToken());
        req.setBody('{"Name" : "' + naam + '","VAT__c" : "' + btwnummer + '"}');
        
        Http http = new Http();
        HttpResponse response = http.send(req);
        
        if(response.getstatusCode() < 300) {
            System.debug('REST response is :: '+response);
            System.debug(response.getBody());
            
            createResult cr = (createResult) JSON.deserialize(response.getBody(), createResult.class);
            System.debug(cr.success + ':' + cr.id);
            
            return (cr.success ? cr.id : null);
        } else {
            return response.getBody();
        }
    }
    
    public static List<Order> sendOrderFunction(List<Id> orderIds, String status, String token) {
        OrderList oList = new OrderList();
        oList.records = new List<orderJson>();
        for(Order o: [SELECT Id, Account_Crosspoint_Id__c, EffectiveDate, Status, Name, OrderNumber, Description, EndDate, End_Customer__r.Crosspoint_Id__c, Division__r.Crosspoint_Id__c, Type, Payment_Terms__c, Owner.FirstName, Owner.LastName, Pricebook2.Crosspoint_Id__c, Signed_TS_Required__c, PoNumber, Account.Email_for_invoices__c
                      FROM Order 
                      WHERE Id in :orderIds]){
                          Attribute a = new Attribute();
                          a.type1 = 'Order';
                          a.ReferenceId = o.Id;
                          
                          OrderJson Ord = new orderJson();
                          Ord.AccountId = o.Account_Crosspoint_Id__c;
                          Ord.End_Customer = o.End_Customer__r.Crosspoint_Id__c;
                          Ord.Division = o.Division__r.Crosspoint_Id__c;
                          Ord.EffectiveDate = o.EffectiveDate.year() + '-' + O.EffectiveDate.month() + '-' + o.EffectiveDate.day();
                          Ord.PODate = o.EffectiveDate.year() + '-' + O.EffectiveDate.month() + '-' + o.EffectiveDate.day();
                          Ord.EndDate = o.EndDate <> null ? o.EndDate.year() + '-' + O.EndDate.month() + '-' + o.EndDate.day(): null;
                          //Ord.Status = status <> null && o.Status <> 'Draft' ? status : o.Status;
                          Ord.Status = 'Draft';
                          Ord.Name = o.OrderNumber;
                          Ord.External_id = o.Id;
                          Ord.Description = o.Description;
                          Ord.Type = o.Type;
                          Ord.PaymentTerms = o.Payment_terms__c;
                          Ord.PriceBook2Id = o.Pricebook2.Crosspoint_Id__c;
                          Ord.OwnerName = o.Owner.FirstName + ' ' + o.Owner.lastName;
                          Ord.TS = o.Signed_TS_Required__c;
                          Ord.PoNumber = o.PoNumber;
                          Ord.InvoiceEmail = o.Account.Email_for_invoices__c;
                          Ord.attributes = a;
                          oList.records.add(Ord);
                      }
        
        Callout_SendOrder__c co = Callout_SendOrder__c.getOrgDefaults();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(co.Endpoint__c);
        req.setMethod(co.method__c);
        req.setHeader('Content-Type', co.contentType__c);
        req.setHeader('Accept', co.accept__c);
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setBody(Json.serialize(oList).replace('type1', 'type').replace('OwnerName', 'Involved_Sales_Manager__c').replace('End_Customer', 'End_Customer__c').replace('Division', 'Division__c').replace('External_id', 'External_id__c').replace('PaymentTerms', 'Payment_Terms__c').replace('TS', 'Signed_TS_Required__c').replace('InvoiceEmail', 'Invoice_Email__c'));
        system.debug(req.getBody());
        Http http = new Http();
        HttpResponse response = http.send(req);
        
        System.debug('REST response is :: '+response);
        System.debug(response.getBody());
        List<Order> toUpdate = new List<Order>();
        
        if(response.getstatusCode() < 300) {
            
            List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for(Integer i = 0; i < fieldList.size(); i++) {                                
                Map<String,Object> data = (Map<String,Object>) fieldList[i];
                if ((Boolean) data.get('success')) {
                    Order o = new Order(
                        id = orderIds[i],
                        Crosspoint_Id__c = (String) data.get('id'),
                        Integration_Status__c = 'Sended',
                        Integration_Error__c = null
                    );
                    toUpdate.add(o);
                } else {
                    Order o = new Order(
                        id = orderIds[i],
                        Integration_Status__c = 'Error',
                        Integration_Error__c = string.join((List<Object>)data.get('errors'), ',')
                    );
                    toUpdate.add(o);
                }
            }
            
        } else {            
            List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for(Integer i = 0; i < fieldList.size(); i++) {
                Map<String,Object> data = (Map<String,Object>) fieldList[i];
                Order o = new Order(
                    id = orderIds[i],
                    Integration_Status__c = 'Error',
                    Integration_Error__c = response.getBody()
                );
                toUpdate.add(o);
            }
            System.debug(response.getBody());
        }
        return toUpdate;
    }
    
    @future (callout=true)
    public static void sendOrder(List<Id> orderIds) { 
        String token = getAccessToken();
        List<Order> toupdate = sendOrderFunction(orderIds, null, token);
        update toUpdate;
    }
    
    public static List<OrderItem> sendOrderItemFunction(List<OrderItem> orderItems, String token, Map<Id, Id> idMap) { 
        
        List<OrderItem> readyList = new List<OrderItem>();
        List<OrderItem> readyListUpdate = new List<OrderItem>();
        for(OrderItem o : orderItems) {
            if(o.Crosspoint_Id__c == '' || o.Crosspoint_Id__c == null) {
                readyList.add(o);
            } else {
                readyListUpdate.add(o);
            }
        }    
        
        List<OrderItem> toUpdate = new List<OrderItem>();
        
        if(readyList.size() > 0) {
            OrderItemList oiList = new OrderItemList();
            oiList.records = new List<OrderItemJson>();
            for(OrderItem oi: readyList){
                Attribute a = new Attribute();
                a.type1 = 'OrderItem';
                a.ReferenceId = oi.Crosspoint_Id__c;   
                
                OrderItemJson oij = new OrderItemJson();
                oij.orderId = idMap <> null ? idMap.get(oi.OrderId) : oi.order.Crosspoint_Id__c;
                oij.Product2Id = oi.Product2.CrosspointId__c;
                oij.quantity = oi.quantity;
                oij.PricebookEntryId = oi.PricebookEntry.Crosspoint_Id__c;
                oij.UnitPrice = oi.UnitPrice;
                oij.ExtProdName = oi.Product2.Name;
                oij.Description = oi.Description;
                oij.ServiceDate = oi.ServiceDate.year() + '-' + oi.ServiceDate.month() + '-' + oi.ServiceDate.day();
                oij.EndDate = oi.EndDate <> null ? oi.EndDate.year() + '-' + oi.EndDate.month() + '-' + oi.EndDate.day() : null;
                oij.IcCompany = oi.IC_Company__r.Crosspoint_Id__c;
                oij.ExternalCompany = oi.External_company__c;
                oij.PurchasePrice = oi.Purchase_Price__c;
                oij.EndSalesPrice = oi.End_sales_price__c;
                oij.OrderUnit = oi.Unit__c;
                oij.attributes = a;
                oiList.records.add(oij);
            }
            
            Callout_SendOrderItem__c co = Callout_SendOrderItem__c.getOrgDefaults();
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(co.Endpoint__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', co.contentType__c);
            req.setHeader('Accept', co.accept__c);
            req.setHeader('Authorization', 'Bearer ' + token);
            //req.setBody('{"records":[{"attributes" : {"type" : "Order", "referenceId" : "test1"}, "AccountId":"0012600001qnie6AAA","EffectiveDate":"2023-12-10", "Status":"Draft", "Name": "Test integration", "External_id__c": "test1"},{"attributes" : {"type" : "Order", "referenceId" : "test2"}, "AccountId":"0012600001qnie6AAA","EffectiveDate":"2023-10-10", "Status":"Draft", "Name": "Test integration 3", "External_id__c": "test2"}]}');
            req.setBody(Json.serialize(oiList).replace('type1', 'type').replace('EndSalesPrice', 'End_Sales_Price__c').replace('ExternalCompany','External_company__c' ).replace('ResourceType', 'Resource_Type__c').replace('ExtProdName', 'External_Product_Name__c').replace('IcCompany', 'IC_Company__c').replace('PurchasePrice', 'Purchase_Price__c').replace('OrderUnit', 'Unit__c'));

            system.debug(req.getBody());
            
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.debug(response.getBody());
            
            if(response.getstatusCode() < 300) {
                
                List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(response.getBody());
                for(Integer i = 0; i < fieldList.size(); i++) {
                    Map<String,Object> data = (Map<String,Object>) fieldList[i];
                    List<Object> errors = (List<Object>)data.get('errors');
                    System.debug(errors);
                    if ((Boolean) data.get('success')) {
                        OrderItem o = new OrderItem(
                            id = orderItems[i].Id,
                            Crosspoint_Id__c = (String) data.get('id'),
                            Integration_Status__c = 'Sended',
                            Integration_Error__c = null
                        );
                        toUpdate.add(o);
                    } else {
                        OrderItem o = new OrderItem(
                            id = orderItems[i].Id,
                            Integration_Status__c = 'Error',
                            Integration_Error__c = JSON.serialize(errors).abbreviate(255)
                        );
                        toUpdate.add(o);
                    }
                }
            } else {
                List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(response.getBody());
                for(Integer i = 0; i < fieldList.size(); i++) {
                    Map<String,Object> data = (Map<String,Object>) fieldList[i];
                    OrderItem o = new OrderItem(
                        id = orderItems[i].Id,
                        Integration_Status__c = 'Error',
                        Integration_Error__c = response.getBody()
                    );
                    toUpdate.add(o);
                }
                System.debug(response.getBody());
            }
        }
        
        if(readyListUpdate.size() > 0) {
            OrderItemUpdateList oiList = new OrderItemUpdateList();
            oiList.records = new List<OrderItemUpdateJson>();
            for(OrderItem oi: readyListUpdate){
                Attribute a = new Attribute();
                a.type1 = 'OrderItem';
                a.ReferenceId = oi.Crosspoint_Id__c;   
                
                OrderItemUpdateJson oij = new OrderItemUpdateJson();
                oij.Id = oi.Crosspoint_Id__c;
                oij.quantity = oi.quantity;
                oij.UnitPrice = oi.UnitPrice;
                oij.ExtProdName = oi.Product2.Name;
                oij.Description = oi.Description;
                oij.ResourceType = oi.Resource_Type__c;
                oij.ServiceDate = oi.ServiceDate.year() + '-' + oi.ServiceDate.month() + '-' + oi.ServiceDate.day();
                oij.EndDate = oi.EndDate <> null ? oi.EndDate.year() + '-' + oi.EndDate.month() + '-' + oi.EndDate.day() : null;
                oij.ExternalCompany = oi.External_company__c;
                oij.IcCompany = oi.IC_Company__r.Crosspoint_Id__c;
                oij.PurchasePrice = oi.Purchase_Price__c;
                oij.EndSalesPrice = oi.End_sales_price__c;
                oij.OrderUnit = oi.Unit__c;
                oij.attributes = a;
                oiList.records.add(oij);
            }
            
            Callout_SendOrderItem__c co = Callout_SendOrderItem__c.getOrgDefaults();
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(co.Endpoint__c);
            req.setMethod('PATCH');
            req.setHeader('Content-Type', co.contentType__c);
            req.setHeader('Accept', co.accept__c);
            req.setHeader('Authorization', 'Bearer ' + getAccessToken());
            req.setBody(Json.serialize(oiList).replace('type1', 'type').replace('EndSalesPrice', 'End_Sales_Price__c').replace('ExternalCompany','External_company__c' ).replace('ResourceType', 'Resource_Type__c').replace('ExtProdName', 'External_Product_Name__c').replace('IcCompany', 'IC_Company__c').replace('PurchasePrice', 'Purchase_Price__c').replace('OrderUnit', 'Unit__c'));
            system.debug(req.getBody());
            
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.debug('REST response is :: '+response);
            System.debug(response.getBody());
            
            if(response.getstatusCode() < 300) {
                                
                List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(response.getBody());
                for(Integer i = 0; i < fieldList.size(); i++) {
                    Map<String,Object> data = (Map<String,Object>) fieldList[i];
                    List<Object> errors = (List<Object>)data.get('errors');
                    System.debug(errors);
                    if ((Boolean) data.get('success')) {
                        OrderItem o = new OrderItem(
                            id = orderItems[i].Id,
                            Crosspoint_Id__c = (String) data.get('id'),
                            Integration_Status__c = 'Sended',
                            Integration_Error__c = null
                        );
                        toUpdate.add(o);
                    } else {
                        OrderItem o = new OrderItem(
                            id = orderItems[i].Id,
                            Integration_Status__c = 'Error',
                            Integration_Error__c = JSON.serialize(errors).abbreviate(255)
                        );
                        toUpdate.add(o);
                    }
                }
            } else {                
                List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(response.getBody());
                for(Integer i = 0; i < fieldList.size(); i++) {
                    Map<String,Object> data = (Map<String,Object>) fieldList[i];
                    OrderItem o = new OrderItem(
                        id = orderItems[i].Id,
                        Integration_Status__c = 'Error',
                        Integration_Error__c = response.getBody()
                    );
                    toUpdate.add(o);
                }
                System.debug(response.getBody());
            }
        }
        System.debug(toUpdate);
        return toUpdate;
    }
    
    @future (callout=true)
    public static void sendOrderItem(List<Id> orderItemIds) {
        
        String token = getAccessToken();
        List<OrderItem> orderItems = new List<OrderItem>([Select Id, Crosspoint_Id__c, order.Crosspoint_Id__c, Product2.CrosspointId__c, Product2.Name, Quantity, PricebookEntry.Crosspoint_Id__c, UnitPrice, resource_Type__c, ServiceDate, EndDate, Description, External_company__c, IC_Company__r.Crosspoint_Id__c, Purchase_Price__c, End_sales_price__c, Unit__c 
                                                           FROM OrderItem WHERE Id IN :orderItemIds]);
        List<OrderItem> toUpdate = sendOrderItemFunction(orderItems, token, null);
        update toUpdate;
    }
    
    @future (callout=true)
    public static void sendOrderItemUpdate(List<Id> orderItemIds) {
        
        String token = getAccessToken();
        List<OrderItem> orderItems = new List<OrderItem>([Select Id, Crosspoint_Id__c, order.Crosspoint_Id__c, Product2.CrosspointId__c, Product2.Name, Quantity, PricebookEntry.Crosspoint_Id__c, UnitPrice, resource_Type__c, ServiceDate, EndDate, Description, External_company__c, IC_Company__r.Crosspoint_Id__c, Purchase_Price__c, End_sales_price__c, Unit__c
                                                           FROM OrderItem WHERE Id IN :orderItemIds]);
        List<OrderItem> toUpdate = sendOrderItemFunction(orderItems, token, null);
        update toUpdate;       
    }
    
    @future (callout=true)
    public static void sendOrder2(List<Id> orderIds) { 
        
        //Activated naar Ready in trigger
        
        String token = getAccessToken();
        
        //SendOrder(orderIds) in 'Pending'
        List<Order> toUpdatePending = sendOrderFunction(orderIds, 'Pending', token);
        Map<Id, Id> idMap = new Map<Id, Id>();
        for(Order o : toUpdatePending) {
            idMap.put(o.Id, o.Crosspoint_Id__c);
        }
        
        //Orderproducts        
        List<OrderItem> items = new List<OrderItem>([SELECT Id, Integration_Status__c, Crosspoint_Id__c, order.Crosspoint_Id__c, Product2.CrosspointId__c, Product2.Name, 
                                                     Quantity, PricebookEntry.Crosspoint_Id__c, UnitPrice, OrderId, resource_Type__c, ServiceDate, EndDate,Description, External_company__c, IC_Company__r.Crosspoint_Id__c, Purchase_Price__c, End_sales_price__c, Unit__c
                                                     FROM OrderItem WHERE OrderId IN :orderIds]);
        List<OrderItem> toUpdateOI = sendOrderItemFunction(items, token, idMap);
       
        //SendOrder(orderIds) in 'Activated'
        List<Order> toUpdateActivated = sendOrderFunction(orderIds, 'Approved', token);
         update toUpdateActivated;
        update toUpdateOI;
    }
    
    
    
    
    /* #########################  INNER CLASSES  #######################   */    
    
    public class accessTokenResponse {
        String access_token;
        String instance_url;
        String id;
        String token_type;
        String issued_at;
        String signature;
    }
    
    
    public class OrderList {
        List<OrderJson> records;
    }
    
    public class OrderJson {
        String AccountId;
        String EffectiveDate;
        String EndDate;
        String PODate;
        String Status;
        String Name;
        String External_id;
        String Description;
        String End_Customer;
        String Division;
        String Type;
        String PriceBook2Id;
        String PaymentTerms;
        String OwnerName;
        String TS;
        String PoNumber;
        String InvoiceEmail;
        Attribute attributes;
    }
    
    public class OrderItemList {
        List<OrderItemJson> records;
    }
    
    public class OrderItemJson {
        String OrderId;
        String Product2Id;
        Double UnitPrice;
        Double quantity;
        Double PurchasePrice;
        Double EndSalesPrice;
        String PricebookEntryId;
        String Description;
        String ExtProdName;
        String ResourceType;
        String ServiceDate;
        String ExternalCompany;
        String EndDate;
        String IcCompany;
        String OrderUnit;
        Attribute attributes;
    }
    
    public class OrderItemUpdateList {
        List<OrderItemUpdateJson> records;
    }
    
    public class OrderItemUpdateJson {
        Double UnitPrice;
        Double quantity;
        Double PurchasePrice;
        Double EndSalesPrice;
        String ExtProdName;
        String ResourceType;
        String Description;
        String Id;
        String ServiceDate;
        String ExternalCompany;
        String EndDate;
        String IcCompany;
        String OrderUnit;
        Attribute attributes;
    }
    
    Public class Attribute {
        String type1;
        String referenceId;
    }
    
    public class AccountResult {
        public Integer totalSize;
        public Boolean done;
        public List<Attributes> records;
    }
    
    public class Attributes {
        public String Name;
        public String Id;
        public String VAT;
        public String InvoiceEmail;
        public String FullAddress;
        public String ResponsibleMail;
        public FullAddress BillingAddress;
        public FullAddress ShippingAddress;
        public String Register_of_legal_entities;
        public String Register_of_legal_entities_department;
    }
    
    public class FullAddress {
        public String city;
        public String country;
        public String postalcode;
        public String state;
        public String street;
    }
    
    public class createResult {
        public string id;
        public boolean success;
        public List<Error1> errors;
    }
    public class Error1 {
        
    }
    
    public class OrderListV2 {
        List<OrderJsonV2> order;
    }
    
    public class OrderJsonV2 {
        String AccountId;
        String EffectiveDate;
        String Status;
        String Name;
        //String External_id;
        String Description;
        String End_Customer;
        String Division;
        String Type;
        AttributeV2 attributes;
        OrderItemsV2 OrderItems;
    }
    
    public class OrderItemsV2 {
        List<OrderItemV2> records;
    }
    
    public class OrderItemV2 {
        AttributeV2 attributes;
        String Product2Id;
        Double End_Sales_Price;
        Double UnitPrice;
        Double quantity;
        String ResourceType;
        String ExternalCompany;
        String IcCompany;
        //String External_id;
    }
    
    Public class AttributeV2 {
        String type1;
        //String referenceId;
    }
    
}