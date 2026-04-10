/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class KlantendossierControllerTest {

    @isTest
    static void testGenerateKlantendossier() {
        Account acc = new Account(
            Name = 'Test'
        );

        Test.startTest();
        PageReference pageRef = Page.Klantendossier;
        Map<String,String> params = pageRef.getParameters();
        params.put('id', String.valueOf(acc.Id));
        params.put('includeQuotes', 'true');
        params.put('includeInvolvements', 'true');
        params.put('includeStages', 'Order');
        params.put('includeTypes', 'Master');
        Test.setCurrentPage(pageRef);

        KlantendossierController ctrl = new KlantendossierController(new ApexPages.StandardController(acc));

        Test.stopTest();
    }
}