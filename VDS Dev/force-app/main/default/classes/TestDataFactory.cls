@IsTest
public class TestDataFactory {

    public static Account createAccount() {
        Account acc = new Account(
            Name = 'TestAccount',
            BillingStreet = 'Veldkant 33',
            BillingCity = 'Kontich',
            BillingPostalCode = '2550',
            BillingCountry = 'Belgium'
        );

        insert acc;
        return acc;
    }
}