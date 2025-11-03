@IsTest
private class ProjectBasicCloseBatch_Test {

    @IsTest
    static void allQuotesAreDeniedTest(){
        //testData
        Account account = TestDataFactory.createAccount();
        String basicProjectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VDS_Basic_Project').getRecordTypeId();
        Opportunity project = TestDataFactory.createProject(account.Id, basicProjectRecordTypeId);
        
        for (Integer i = 0; i < 3; i++) {
            Quote quote = TestDataFactory.createQuote(project.Id);
        }

        List<Quote> quotes = [SELECT Id, Status FROM Quote WHERE OpportunityId = :project.Id];
        for (Quote quote : quotes) {
            quote.Status = 'Denied';
        }
        update quotes;
        Test.startTest();
        //Call Batch
        ProjectBasicCloseBatch batch = new ProjectBasicCloseBatch(true);
        Database.executeBatch(batch);
        Test.stopTest();
        List<Opportunity> projectToTest = [SELECT Id, Status__c, Amount_Denied_Quotes__c, StageName FROM Opportunity Where Id = :project.Id];
        System.debug(projectToTest[0].Amount_Denied_Quotes__c);
        Assert.areEqual('50', projectToTest.get(0).Status__c, 'The status should be 50.');
        Assert.areEqual('Closed Lost', projectToTest.get(0).StageName, 'The Stagename should be \'Closed Lost\'');
    }

    @IsTest
    static void notAllQuotesAreDeniedTest(){
        //testData
        Integer amountOfQuotes = 3;
        Account account = TestDataFactory.createAccount();
        String basicProjectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VDS_Basic_Project').getRecordTypeId();
        Opportunity project = TestDataFactory.createProject(account.Id, basicProjectRecordTypeId);
        
        for (Integer i = 0; i < amountOfQuotes; i++) {
            Quote quote = TestDataFactory.createQuote(project.Id);
        }

        List<Quote> quotes = [SELECT Id, Status FROM Quote WHERE OpportunityId = :project.Id];
        Integer countOfQuotesDenied = 2;
        for (Integer i = 0; i < countOfQuotesDenied; i++) {
            quotes[i].Status = 'Denied';
        }
        update quotes;
        Test.startTest();
        //Call Batch
        ProjectBasicCloseBatch batch = new ProjectBasicCloseBatch(true);
        Database.executeBatch(batch);
        Test.stopTest();
        List<Opportunity> projectToTest = [SELECT Id, Status__c, Amount_Denied_Quotes__c, StageName FROM Opportunity Where Id = :project.Id];
        System.debug(projectToTest[0].Amount_Denied_Quotes__c);
        Assert.areEqual('10', projectToTest.get(0).Status__c);
        Assert.areEqual(project.StageName, projectToTest.get(0).StageName);
    }
}