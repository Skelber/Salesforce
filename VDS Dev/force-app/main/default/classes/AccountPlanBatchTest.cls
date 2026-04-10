@IsTest
public with sharing class AccountPlanBatchTest {
   
    @IsTest
    public static void validateAccountPlanBatch(){
        Account a = new Account();
            a.Name = 'TestAccount';
            a.BillingStreet = 'Veldkant 33';
            a.BillingCity = 'Kontich';
            a.BillingPostalCode = '2550';
            a.BillingCountry = 'Belgium';
            // PMCBricks_BE__c
            insert a;

            PMC__c pmc = new PMC__c();
            pmc.Name = 'Facade BE';
            pmc.Type__c = 'Bricks BE';
            pmc.Account__c = a.Id;
            pmc.Themes__c = 'Sound reduction;Pirrouet';
            insert pmc;

            AccountPlan ap = new AccountPlan();
            ap.Name = 'Test PMC';
            ap.PMC_Account_Data__c = pmc.Id;
            ap.AccountId = a.Id;
            ap.PMC_Type__c = 'Bricks BE';
            insert ap;

            RecordType vdsProjectRT = [
                            SELECT Id
                            FROM RecordType
                            WHERE SObjectType = 'Opportunity'
                              AND DeveloperName = 'VDS_Project'
                            LIMIT 1
                        ];

            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.RecordTypeId = vdsProjectRT.Id;
            opp.AccountId = a.Id;
            opp.StageName = 'Design';
            opp.CloseDate = Date.today() + 7;
            opp.Follow_Up_Date__c = Date.today();
            opp.PMC__c = 'Bricks BE';
            opp.Project_Type__c = 'Renovation';
            opp.Project_Domain__c =  'Private project';
            opp.Product_Group__c = 'E-Board;Pirrouet;Prefab - Signa';
            opp.Project_Address__Street__s = 'Veldkant 33';
            opp.Project_Address__PostalCode__s = '2550';
            opp.Project_Address__City__s = 'Kontich';
            opp.Project_Address__CountryCode__s = 'BE';
            opp.LeadSource = 'Own Research';
            opp.Lead_Source_Details__c = 'Archipoint';
            insert opp;

            Project_Relation__c oppInvolvement = new Project_Relation__c();
            oppInvolvement.VDSProject_Ref__c = opp.Id;
            oppInvolvement.Account_Ref__c = a.Id;
            oppInvolvement.PMC__c = 'Bricks BE';

            insert oppInvolvement;

            Test.startTest();
            Database.executeBatch(new AccountPlanBatch(), 200);
            Test.stopTest();

            ap = [
                SELECT Product_focus_YTD__c,
                       Product_focus_Y_1__c,
                       Project_win_YTD__c,
                       Project_win_Y_1__c,
                       Project_acquisition_win_YTD__c,
                       Project_acquisition_win_Y_1__c
                FROM AccountPlan
                WHERE Id = :ap.Id
            ];
    

            System.assertNotEquals(null, ap.Product_focus_YTD__c, 'YTD Product focus should be filled');
            System.assertEquals(0, ap.Project_acquisition_win_Y_1__c, 'LY acquisition should be 0%');

    }
}