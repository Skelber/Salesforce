public with sharing class AccountPlanBatchLauncher {
    @AuraEnabled
    public static void runBatch() {
        Database.executeBatch(new AccountPlanBatch(), 200);
    }
}