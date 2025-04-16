@isTest(SeeAllData=true)
public class OrderAPITest {
    @isTest
    public static void testOrderAPIErrroCase(){
        String ReqBody = '{}';
        RestRequest request = new RestRequest();
        request.requestUri =  URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Order';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(ReqBody);
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        OrderAPI.InsertOrders();
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    @isTest
    public static void testOrderAPISuccessCase(){
        RestRequest request = new RestRequest();
        request.requestUri =  URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Order?target=methodname';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(getTestRequest());
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        OrderAPI.InsertOrders();
    }
    
    
    public static String getTestRequest(){
        Account acc = new Account();
        acc.Name ='Test Account';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test 1st';
        opp.GT_Unique_ID__c = '123TestClass';
        opp.GT_Order_Date_Time__c = Date.today();
        opp.Start_Time__c = DateTime.now();
        opp.Rec_Type__c = 'membership';
        
        Contact con = new Contact();
        con.FirstName = 'Test Record';
        con.LastName = 'Test Record';
        con.Email = 'test@con.com';
        
        Order_Line__c ol = new Order_Line__c();
        ol.Price__c = 123;
        ol.Sub_Type__c = 'Normaal';
        ol.Membership_Start_Date__c = Date.today();
        ol.Membership_End_Date__c = Date.today().addYears(1);
        
        KMSKA_Product__c KP = new KMSKA_Product__c();
        KP.Name = 'Test Pro';
        KP.GT_ID__c = 'GT-KP01';
        KP.Duration_in_min__c = 30;
        insert KP; 
        
        IOrders.Order_cls orderCls = new IOrders.Order_cls();
        orderCls.Contact = con;
        orderCls.Order = opp;
        orderCls.Organisation = acc;
        orderCls.OrderLines = new List<Order_Line__c>();
        orderCls.OrderLines.add(ol);
        orderCls.Activity = KP;
        
        Account acc1 = new Account();
        acc1.Name ='Test Account123';
        insert acc1;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test Record';
        con1.LastName = 'Test Record';
        con1.Email = 'test1@con.com';
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test 2nd';
        opp1.GT_Unique_ID__c = '1234TestClass';
        opp1.GT_Order_Date_Time__c = Date.today();
        opp1.Start_Time__c = DateTime.now();
        opp1.Rec_Type__c = 'order';
        
        Order_Line__c ol1 = new Order_Line__c();
        ol1.Type__c = 'Ticket';
        ol1.Price__c = 123;
        ol1.Quantity__c = 2;
        ol1.Sub_Type__c = 'Normaal';
        ol1.Membership_Start_Date__c = Date.today();
        ol1.Membership_End_Date__c = Date.today().addYears(1);
        
        IOrders.Order_cls orderCls1 = new IOrders.Order_cls();
        orderCls1.Contact = con1;
        orderCls1.Order = opp1;
        orderCls1.Organisation = acc1;
        orderCls1.OrderLines = new List<Order_Line__c>();
        orderCls1.OrderLines.add(ol1);
        orderCls1.Activity = KP;
        
        Account acc2 = new Account();
        acc2.Name ='Test Account124235345';
        insert acc2;
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test Record 123';
        con2.LastName = 'Test Record 123';
        con2.Email = 'test123@con.com';
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test 3rd';
        opp2.GT_Unique_ID__c = '1234567TestClass';
        opp2.GT_Order_Date_Time__c = Date.today();
        opp2.Start_Time__c = DateTime.now();
        opp2.Rec_Type__c = 'kmska activity';
        
        Order_Line__c ol2 = new Order_Line__c();
        ol2.Type__c = 'Ticket 123';
        ol2.Price__c = 1232;
        ol2.Quantity__c = 3;
        ol2.Sub_Type__c = 'Normaal';
        ol2.Membership_Start_Date__c = Date.today();
        ol2.Membership_End_Date__c = Date.today().addYears(1);
        
        IOrders.Order_cls orderCls2 = new IOrders.Order_cls();
        orderCls2.Contact = con2;
        orderCls2.Order = opp2;
        orderCls2.Organisation = acc2;
        orderCls2.OrderLines = new List<Order_Line__c>();
        orderCls2.OrderLines.add(ol2);
        orderCls2.Activity = KP;
        
        
        IOrders order = new IOrders();
        order.Orders = new List<IOrders.Order_cls>();
        order.Orders.add(orderCls);
        order.Orders.add(orderCls1);
        order.Orders.add(orderCls2);
        
        return JSON.serialize(order);
    }
    
    @isTest
    public static void testOrderAPISuccessCase2(){
        RestRequest request = new RestRequest();
        request.requestUri =  URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Order';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(getTestRequest2());
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        OrderAPI.InsertOrders();
    }
    
    public static String getTestRequest2(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test 1st';
        opp.GT_Unique_ID__c = '123TestClass2';
        opp.GT_Order_Date_Time__c = Date.today();
        opp.Rec_Type__c = 'donation';
        
        Contact con = new Contact();
        con.FirstName = 'Test Record';
        con.LastName = 'Test Record';
        con.Email = 'test@con.com';
        
        Order_Line__c ol = new Order_Line__c();
        ol.Price__c = 123;
        ol.Sub_Type__c  = 'Normaal';
        ol.Membership_Start_Date__c = Date.today();
        ol.Membership_End_Date__c = Date.today().addYears(1);
        
        KMSKA_Product__c KP = new KMSKA_Product__c();
        KP.Name = 'Test Pro';
        KP.GT_ID__c = 'GT-KP01';
        KP.Duration_in_min__c = 30;
        insert KP; 
        
        
        IOrders.Order_cls orderCls = new IOrders.Order_cls();
        orderCls.Contact = con;
        orderCls.Order = opp;
        orderCls.OrderLines = new List<Order_Line__c>();
        orderCls.OrderLines.add(ol);
        orderCls.Activity = KP;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test 2nd';
        opp1.GT_Unique_ID__c = '123TestClass2333';
        opp1.GT_Order_Date_Time__c = Date.today();
        opp1.Rec_Type__c = 'membership';
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test Record33';
        con1.LastName = 'Test Record33';
        con1.Email = 'test@con.com';
        
        Order_Line__c ol1 = new Order_Line__c();
        ol1.Price__c = 123;
        ol1.Sub_Type__c  = 'Normaal';
        ol1.Membership_Start_Date__c = Date.today();
        ol1.Membership_End_Date__c = Date.today().addYears(1);
        
        IOrders.Order_cls orderCls1 = new IOrders.Order_cls();
        orderCls1.Contact = con1;
        orderCls1.Order = opp1;
        orderCls1.OrderLines = new List<Order_Line__c>();
        orderCls1.OrderLines.add(ol1);
        orderCls1.Activity = KP;
        
        IOrders order = new IOrders();
        order.Orders = new List<IOrders.Order_cls>();
        order.Orders.add(orderCls);
        order.Orders.add(orderCls1);
        
        return JSON.serialize(order);
    }
    
    @isTest
    public static void testOrderAPISuccessCase3(){
        RestRequest request = new RestRequest();
        request.requestUri =  URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Order';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(getTestRequest3());
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        OrderAPI.InsertOrders();
    }
    
    public static String getTestRequest3(){
        Account actI = new Account();
        actI.Name = 'Test';
        actI.VAT__c = '123';
        insert actI; 
        
        Contact conI = new Contact();
        conI.FirstName = 'Test Record';
        conI.LastName = 'Test Record';
        conI.Email = 'test@con.com';
        insert conI;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test 1st';
        opp.GT_Unique_ID__c = '123TestClass2';
        opp.GT_Order_Date_Time__c = Date.today();
        opp.Rec_Type__c = 'donation';
        
        Contact con = new Contact();
        con.FirstName = 'Test Record';
        con.LastName = 'Test Record';
        con.Email = 'test@con.com';
        
        Order_Line__c ol = new Order_Line__c();
        ol.Price__c = 123;
        ol.Sub_Type__c  = 'Normaal';
        ol.Membership_Start_Date__c = Date.today();
        ol.Membership_End_Date__c = Date.today().addYears(1);
        
        KMSKA_Product__c KP = new KMSKA_Product__c();
        KP.Name = 'Test Pro';
        KP.GT_ID__c = 'GT-KP01';
        KP.Duration_in_min__c = 30;
        insert KP; 
        
        
        IOrders.Order_cls orderCls = new IOrders.Order_cls();
        orderCls.Contact = con;
        orderCls.Order = opp;
        orderCls.OrderLines = new List<Order_Line__c>();
        orderCls.OrderLines.add(ol);
        orderCls.Activity = KP;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test Record';
        con1.LastName = 'Test Record';
        con1.Email = 'test1@con.com';
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test 2nd';
        opp1.GT_Unique_ID__c = '1234TestClass2';
        opp1.GT_Order_Date_Time__c = Date.today();
        opp1.Rec_Type__c = 'order';
        
        Order_Line__c ol1 = new Order_Line__c();
        ol1.Type__c = 'Ticket';
        ol1.Bruto_Price__c = 123;
        ol1.Quantity__c = 2;
        ol1.Sub_Type__c  = 'Normaal';
        ol1.Membership_Start_Date__c = Date.today();
        ol1.Membership_End_Date__c = Date.today().addYears(1);
        
        Order_Line__c ol2 = new Order_Line__c();
        ol2.Type__c = 'Product';
        ol2.Bruto_Price__c = 123;
        ol2.Quantity__c = 2;
        ol2.Sub_Type__c  = 'Normaal';
        ol2.Membership_Start_Date__c = Date.today();
        ol2.Membership_End_Date__c = Date.today().addYears(1);
        
        IOrders.Order_cls orderCls1 = new IOrders.Order_cls();
        orderCls1.Contact = con1;
        orderCls1.Order = opp1;
        orderCls1.OrderLines = new List<Order_Line__c>();
        orderCls1.OrderLines.add(ol1);
        orderCls1.OrderLines.add(ol2);
        orderCls1.Activity = KP;
        
        IOrders order = new IOrders();
        order.Orders = new List<IOrders.Order_cls>();
        order.Orders.add(orderCls);
        order.Orders.add(orderCls1);
        
        return JSON.serialize(order);
    }
    
    @isTest
    public static void testOrderAPISuccessCase4(){
        RestRequest request = new RestRequest();
        request.requestUri =  URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Order';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(getTestRequest4());
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        OrderAPI.InsertOrders();
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Order_Line__c oll = new Order_Line__c();
        oll.Type__c = 'Product';
        oll.Bruto_Price__c = 123;
        oll.Quantity__c = 2;
        oll.Order__c = opp.Id;
        oll.Sub_Type__c  = 'Normaal';
        
        try{
            insert oll;
            oll.Sub_Type__c  = 'Ticket';
            update oll;
        }catch (Exception ex){
            
        }
        
        
    }
    
    public static String getTestRequest4(){
        Account actI = new Account();
        actI.Name = 'Test';
        actI.VAT__c = '123';
        insert actI; 
        
        Contact conI = new Contact();
        conI.FirstName = 'Test Record';
        conI.LastName = 'Test Record';
        conI.Email = 'test@con.com';
        insert conI;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test 1st';
        opp.GT_Unique_ID__c = '123TestClass2';
        opp.GT_Order_Date_Time__c = Date.today();
        opp.Rec_Type__c = 'kmska activity';
        
        
        Contact con = new Contact();
        con.FirstName = 'Test Record';
        con.LastName = 'Test Record';
        con.Email = 'test@con.com';
        
        Order_Line__c ol = new Order_Line__c();
        ol.Price__c = 123;
        ol.Sub_Type__c  = 'Ticket';
        ol.Membership_Start_Date__c = Date.today();
        ol.Membership_End_Date__c = Date.today().addYears(1);
        
        Order_Line__c dol = new Order_Line__c();
        dol.Price__c = 123;
        dol.Type__c = 'Donation';
        dol.Membership_Start_Date__c = Date.today();
        dol.Membership_End_Date__c = Date.today().addYears(1);
        
        
        KMSKA_Product__c KP = new KMSKA_Product__c();
        KP.Name = 'Test Pro';
        KP.GT_ID__c = 'GT-KP01';
        KP.Duration_in_min__c = 30;
        Datetime now = Datetime.now();
        KP.Start_Time__c = now;
        KP.End_Time__c = now.addMinutes(30);
        insert KP; 
        
        
        IOrders.Order_cls orderCls = new IOrders.Order_cls();
        orderCls.Contact = con;
        orderCls.Order = opp;
        orderCls.OrderLines = new List<Order_Line__c>();
        orderCls.OrderLines.add(ol);
        orderCls.OrderLines.add(dol);
        orderCls.Activity = KP;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test Record';
        con1.LastName = 'Test Record';
        con1.Email = 'test1@con.com';
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test 2nd';
        opp1.GT_Unique_ID__c = '1234TestClass2';
        opp1.GT_Order_Date_Time__c = Date.today();
        opp1.Rec_Type__c = 'order';
        
        Order_Line__c ol1 = new Order_Line__c();
        ol1.Type__c = 'Ticket';
        ol1.Bruto_Price__c = 123;
        ol1.Quantity__c = 2;
        ol1.Sub_Type__c  = 'Normaal';
        ol1.Membership_Start_Date__c = Date.today();
        ol1.Membership_End_Date__c = Date.today().addYears(1);
        
        Order_Line__c ol2 = new Order_Line__c();
        ol2.Type__c = 'Product';
        ol2.Bruto_Price__c = 123;
        ol2.Quantity__c = 2;
        ol2.Sub_Type__c  = 'Normaal';
        ol2.Membership_Start_Date__c = Date.today();
        ol2.Membership_End_Date__c = Date.today().addYears(1);
        
        IOrders.Order_cls orderCls1 = new IOrders.Order_cls();
        orderCls1.Contact = con1;
        orderCls1.Order = opp1;
        orderCls1.OrderLines = new List<Order_Line__c>();
        orderCls1.OrderLines.add(ol1);
        orderCls1.OrderLines.add(ol2);
        orderCls1.Activity = KP;
        
        IOrders order = new IOrders();
        order.Orders = new List<IOrders.Order_cls>();
        order.Orders.add(orderCls);
        order.Orders.add(orderCls1);
        
        Map<String,String> params = new Map<String,String>();
        params.put('Test', 'Test');
        params.put('Test1', 'Test1');
        params.put('Test2', 'Test2');
        
        String res = OrderAPI.getQueryString(params);
        
        return JSON.serialize(order);
    }
    
    @isTest
    public static void testOrderAPISuccessCase5(){
        RestRequest request = new RestRequest();
        request.requestUri =  URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Order';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(getTestRequest5());
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        OrderAPI.InsertOrders();
    }
    
    public static String getTestRequest5(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test 1st';
        opp.GT_Unique_ID__c = '123TestClass5';
        opp.GT_Order_Date_Time__c = Date.today().addDays(2);
        opp.Rec_Type__c = 'kmska activity';
        
        Order_Line__c ol = new Order_Line__c();
        ol.Price__c = 123;
        ol.Sub_Type__c = 'Ticket';
        ol.Membership_Start_Date__c = Date.today();
        ol.Membership_End_Date__c = Date.today().addYears(1);
        
        Order_Line__c dol = new Order_Line__c();
        dol.Price__c = 123;
        dol.Type__c = 'Donation';
        dol.Membership_Start_Date__c = Date.today();
        dol.Membership_End_Date__c = Date.today().addYears(1);
        
        IOrders.Order_cls orderCls = new IOrders.Order_cls();
        orderCls.Order = opp;
        orderCls.OrderLines = new List<Order_Line__c>();
        orderCls.OrderLines.add(ol);
        orderCls.OrderLines.add(dol);
        
        IOrders order = new IOrders();
        order.Orders = new List<IOrders.Order_cls>();
        order.Orders.add(orderCls);
        
        return JSON.serialize(order);
    }
    
    @isTest
    public static void testOrderAPISuccessCase6(){
        RestRequest request = new RestRequest();
        request.requestUri =  URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Order';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(getTestRequest6());
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        OrderAPI.InsertOrders();
    }
    
    public static String getTestRequest6(){ 
        String req = '{"Orders":[{"Order":{"GT_Unique_ID__c":"GT-13353","Rec_Type__c":"KMSKA Activity","StageName":"Geaccepteerd","GT_Order_Date_Time__c":"2022-11-08T16:08:39.000Z","Start_Time__c":"2022-11-09T10:00:00.000Z","LeadSource":"Website","Amount":100,"description":"","Taal__c":"Nederlands","url":"hbo-wo","Doelgroep__c":""}}]}';
        return req;
    }
    
    @isTest
    public static void testDirectOrderCase2(){
        RestRequest request = new RestRequest();
        request.requestUri =  URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Order';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"Orders":[{"Order":{"GT_Unique_ID__c":"Unique-Testclass-20231128","Rec_Type__c":"Order","Name":"Order Number Unique-Testclass-20231128","Stage":"Geaccepteerd","Discount__c":0,"Discount_Name__c":null,"GT_Order_Date_Time__c":"2020-10-28T15:50:12.000Z","GT_Event_Date__c":"2020-10-28","LeadSource":"Kiosk","Amount":0},"Contact":{"FirstName":"","LastName":"","Email":"","Phone":null,"MailingStreet":null,"MailingPostalCode":null,"MailingCity":null,"MailingCountry":null,"Digital_Newsletter__c":false},"OrderLines":[{"Type__c":"Ticket","Sub_Type__c":"Expo Krasse Koppen","Bruto_Price__c":0,"Quantity__c":1},{"Type__c":"Ticket","Sub_Type__c":"Museumpas","Bruto_Price__c":0,"Quantity__c":1}]}]}');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        OrderAPI.InsertOrders();
    }
}