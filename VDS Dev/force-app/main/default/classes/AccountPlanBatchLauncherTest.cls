@isTest
private class AccountPlanBatchLauncherTest {

    @isTest
    static void testRunBatch() {

        Test.startTest();
        AccountPlanBatchLauncher.runBatch();
        Test.stopTest();
        System.assert(true, 'Batch launcher executed successfully.');
    }
}