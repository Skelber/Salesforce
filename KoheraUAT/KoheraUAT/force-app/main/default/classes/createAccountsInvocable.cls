public class createAccountsInvocable {

    @InvocableMethod(label='Create Account' description='Get all the accounts from Crosspoint based on 1 BTWnummer')
    public static List<AccountResult> createAccount(List<AccountRequest> AccountRequests){
        String res = callout.createAccount(AccountRequests[0].naam, AccountRequests[0].btwnummer, AccountRequests[0].billingstreet,
                                           AccountRequests[0].billingcity ,AccountRequests[0].billingpostalcode, AccountRequests[0].billingstate, 
                                           AccountRequests[0].billingcountry, AccountRequests[0].Register_of_legal_entities, AccountRequests[0].Register_of_legal_entities_department, AccountRequests[0].InvoiceEmail);
        
        AccountResult ar = new AccountResult();
        if(res.length() > 18 && res <> null) {
            ar.error = res;
        } else {
            ar.id = res;
        }
        return new List<AccountResult>{ar};
    }
    
    
    public class AccountRequest{
        
        @InvocableVariable
        public String naam;
        
        @InvocableVariable
        public String btwnummer; 
                
        @InvocableVariable
        public String billingstreet;        
        @InvocableVariable
        public String billingcity;        
        @InvocableVariable
        public String billingpostalcode;        
        @InvocableVariable
        public String billingstate;
        @InvocableVariable
        public String billingcountry;     
        @InvocableVariable
        public String Register_of_legal_entities;
        @InvocableVariable
        public String Register_of_legal_entities_department;
        @InvocableVariable
        public String InvoiceEmail;
        
    }
    
    public class AccountResult{
        
        @InvocableVariable
        public String id;
        
        @InvocableVariable
        public String error;
    }

}