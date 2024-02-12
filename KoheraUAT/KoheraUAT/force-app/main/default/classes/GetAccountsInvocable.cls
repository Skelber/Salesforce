public class GetAccountsInvocable {
    
    @InvocableMethod(label='Get Accounts' description='Get all the accounts from Crosspoint based on 1 BTWnummer')
    public static List<AccountResult> getAccounts(List<String> btwnummers){
        Callout.AccountResult ARList = callout.getAccounts(btwnummers[0]);
        List<Account> accList = new List<Account>();
        if(ARList <> null && ARList.totalSize > 0) {
            for(Callout.Attributes rec : ARList.records) {
                Account acc = new Account( 
                    name = rec.Name,
                    Crosspoint_id__c = rec.Id,
                    Vat__c = rec.VAT,
                    FullAddress__c = rec.FullAddress,
                    Email_for_invoices__c = rec.InvoiceEmail,
                    CSPSResponsibleEmail__c = rec.ResponsibleMail,
                    Register_of_legal_entities__c = rec.Register_of_legal_entities,
                    Register_of_legal_entities_department__c = rec.Register_of_legal_entities_department,
                    
                    BillingCity 		= ((rec <> null && rec.BillingAddress <> null) ? rec.BillingAddress.city : null),
                    BillingCountry 		= ((rec <> null && rec.BillingAddress <> null) ? rec.BillingAddress.country : null),
                    BillingPostalCode 	= ((rec <> null && rec.BillingAddress <> null) ? rec.BillingAddress.postalcode : null),
                    BillingState 		= ((rec <> null && rec.BillingAddress <> null) ? rec.BillingAddress.state : null),
                    BillingStreet 		= ((rec <> null && rec.BillingAddress <> null) ? rec.BillingAddress.street : null),
                    
                    ShippingCity 		= ((rec <> null && rec.ShippingAddress <> null) ? rec.ShippingAddress.city : null),
                    ShippingCountry 	= ((rec <> null && rec.ShippingAddress <> null) ? rec.ShippingAddress.country : null),
                    ShippingPostalCode 	= ((rec <> null && rec.ShippingAddress <> null) ? rec.ShippingAddress.postalcode : null),
                    ShippingState 		= ((rec <> null && rec.ShippingAddress <> null) ? rec.ShippingAddress.state : null),
                    ShippingStreet 		= ((rec <> null && rec.ShippingAddress <> null) ? rec.ShippingAddress.street : null)
                );
                accList.add(acc);
            }
            
        }
        System.debug('accList: ' + accList);
        AccountResult res = new AccountResult();
        res.accounts = accList;
        res.aantal = accList.size();
        res.ResponsibleMail = accList[0].CSPSResponsibleEmail__c;
        res.FirstAccountName = accList[0].name;
        System.debug('Result: ' + new List<AccountResult>{res});
        return new List<AccountResult>{res};
    }
    
    
    public class AccountRequest{
        
        @InvocableVariable
        public List<String> btwnummners;
        
    }
    
    public class AccountResult{
        
        @InvocableVariable
        public List<Account> accounts;
        
        @InvocableVariable
        public Integer aantal;

        @InvocableVariable
        public string ResponsibleMail;
        
        @InvocableVariable
        public string FirstAccountName;
        
    }

}