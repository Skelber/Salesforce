@isTest(SeeAllData=true)
public class Callout_Testing {
        
    static testMethod void getAccessToken() {        
        Test.setMock(HttpCalloutMock.class, new Mock_Generator());
        Test.startTest();
        Callout.getAccessToken();
        Test.stopTest();
    }
    
    static testMethod void accountsInvocable() {
        Account acc = new Account(
        	Name = 'Test Acc',
            VAT__c = 'BE1234567890'
        );
        insert acc;
        
        Test.setMock(HttpCalloutMock.class, new Mock_Generator());
        Test.startTest();
        getAccountsInvocable.getAccounts(new List<String>{'BE1234567890'});
        Test.stopTest();
    }
    
    static testMethod void accountsInvocable2() {
        Account acc = new Account(
        	Name = 'Test Acc',
            VAT__c = 'BE1234567890'
        );
        insert acc;
        
        Test.setMock(HttpCalloutMock.class, new Mock_Generator());
        Test.startTest();
        List<createAccountsInvocable.AccountRequest> AccountRequests = new List<createAccountsInvocable.AccountRequest>();
        createAccountsInvocable.AccountRequest ar = new createAccountsInvocable.AccountRequest();
        ar.naam = 'Test';
        ar.btwnummer = 'Test';
        ar.billingstreet = 'Test';
        ar.billingcity = 'Test';
        ar.billingpostalcode = 'Test';
        ar.billingstate = 'Test';
        ar.billingcountry = 'Test';
        AccountRequests.add(ar);
        
        createAccountsInvocable.createAccount(AccountRequests);
        Test.stopTest();
    }
    
    static testMethod void createAccount() {            
        Test.setMock(HttpCalloutMock.class, new Mock_Generator());
        Test.startTest();
        Callout.createAccount('naam', 'BE1234567890');
        Test.stopTest();
    }
    
    static testMethod void sendOrder() {            
        Test.setMock(HttpCalloutMock.class, new Mock_Generator());
        Test.startTest();
        
        Account acc = new Account(
        	Name = 'Test Acc',
            VAT__c = 'BE1234567890'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
        	Name = 'Test opp',
            StageName = 'Quote', 
            CloseDate = System.today()
        );
		insert opp;        
            
        try{
        Order o1 = new Order(
            AccountId = acc.Id,
            OpportunityId = opp.Id,
            Status = 'Draft',
            EffectiveDate = System.today(),
            Type = 'T&M',
            Integration_Status__c = 'Ready'
        );
        insert o1;
        } catch (Exception e) {}
        
        Test.stopTest();
    }
    
    static testMethod void sendOrderItem() {            
        Test.setMock(HttpCalloutMock.class, new Mock_Generator());
        Test.startTest();
        
        Account acc = new Account(
        	Name = 'Test Acc',
            VAT__c = 'BE1234567890'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
        	Name = 'Test opp',
            StageName = 'Quote', 
            CloseDate = System.today()
        );
		insert opp;        
            
        PricebookEntry pb2 = [select Id, Name, IsActive, Product2Id, PriceBook2Id from PricebookEntry where IsActive=True LIMIT 1];
        
        Order o1 = new Order(
            AccountId = acc.Id,
            OpportunityId = opp.Id,
            Status = 'Draft',
            EffectiveDate = System.today(),
            Type = 'T&M',
            PriceBook2Id = pb2.PriceBook2Id
        );
        insert o1;
        
        
        OrderItem item = new OrderItem(
        	PricebookEntryId = pb2.Id,
            Product2Id = pb2.Product2Id,
            OrderId = o1.Id,
            UnitPrice = 1000,
            Quantity = 1,
            Integration_Status__c = 'Ready'
        );
        insert item;
        
        item.Crosspoint_Id__c = 'ccc';
        item.Unitprice = 2000;
        update item;
        
        Test.stopTest();
    }
    
    static testMethod void sendOrderItemUpdate() {            
        Test.setMock(HttpCalloutMock.class, new Mock_Generator());
        Test.startTest();
        Callout.createAccount('naam', 'BE1234567890', 'test', 'test', 'test', 'test', 'test');
        Test.stopTest();
    }
    
    static testMethod void sendOrder2() {            
        Test.setMock(HttpCalloutMock.class, new Mock_Generator());
        
        Account acc = new Account(
        	Name = 'Test Acc',
            VAT__c = 'BE1234567890'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
        	Name = 'Test opp',
            StageName = 'Quote', 
            CloseDate = System.today()
        );
		insert opp;        
            
        Order o1 = new Order(
            AccountId = acc.Id,
            OpportunityId = opp.Id,
            Status = 'Draft',
            EffectiveDate = System.today(),
            Type = 'T&M',
            Integration_Status__c = 'Ready'
        );
        insert o1;
        
        Test.startTest();
        Callout.sendOrder(new List<Id>{o1.Id});
        Test.stopTest();
    }
    
    static testMethod void sendOrderItem2() {            
        Test.setMock(HttpCalloutMock.class, new Mock_Generator());
        
        PricebookEntry pb2 = [select Id, Name, IsActive, Product2Id, PriceBook2Id from PricebookEntry where IsActive=True LIMIT 1];
        
        Account acc = new Account(
        	Name = 'Test Acc',
            VAT__c = 'BE1234567890'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
        	Name = 'Test opp',
            StageName = 'Quote', 
            CloseDate = System.today()
        );
		insert opp;        
            
        Order o1 = new Order(
            AccountId = acc.Id,
            OpportunityId = opp.Id,
            Status = 'Draft',
            EffectiveDate = System.today(),
            Type = 'T&M',
            Integration_Status__c = 'Ready',
            PriceBook2Id = pb2.PriceBook2Id
        );
        insert o1;
        
        OrderItem item = new OrderItem(
        	PricebookEntryId = pb2.Id,
            Product2Id = pb2.Product2Id,
            OrderId = o1.Id,
            UnitPrice = 1000,
            Quantity = 1,
            Integration_Status__c = 'Ready'
        );
        insert item;
        
        Test.startTest();
        Callout.sendOrderItem(new List<Id>{item.Id});
        Callout.sendOrderItemUpdate(new List<Id>{item.Id});
        Test.stopTest();
    }
    
    
}