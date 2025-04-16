global class ReprocessOrderIntegrationLog implements Database.Batchable<sObject> , schedulable  {
    global void execute(SchedulableContext sc)
    {
        ReprocessOrderIntegrationLog b = new ReprocessOrderIntegrationLog();
        database.executebatch(b,2);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date lastDate = Date.newInstance(2023, 8, 1);
        
        return Database.getQueryLocator([SELECT Id, Name, Request__c 
                                         FROM  Integration_Log__c
                                         WHERE Response_Code__c = '400' AND Response_Code_Last__c != '201'
                                         AND CreatedDate >= :lastDate
                                        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Integration_Log__c> ILLst) {
        for(Integration_Log__c IL : ILLst){
            if (!Test.isRunningTest()) OrderAPI.reprocessIntegrationLog(IL);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}