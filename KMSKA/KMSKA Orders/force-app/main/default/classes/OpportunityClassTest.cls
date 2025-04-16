@isTest (SeeAllData = true)

private class OpportunityClassTest {

    @isTest 
   static void testSetTimeValue() {

        Account testAccount = new Account(name = 'testAccount');
        insert testAccount; 

        Contact primContact = new Contact(LastName = 'TestContact', AccountId = testAccount.Id, Contact_Type__c = 'contact');
        insert primContact;

        Id OppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KMSKA Activities').getRecordTypeId();
        
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Geaccepteerd',
            RecordTypeId = OppRecordTypeId,
            CloseDate = Date.newInstance(2024, 2, 15),
            Participants__c = 10,
            npsp__Primary_Contact__c = primContact.Id,
            Start_Time__c = DateTime.newInstance(2024, 2, 14, 10, 30, 0),
            End_Time__c = DateTime.newInstance(2024, 2, 15, 12, 30, 0)
        );


        insert testOpportunity;

        Opportunity insertedOpportunity = [SELECT Id, Start_hour__c FROM Opportunity WHERE Id = :testOpportunity.Id];

        System.assertEquals('10:30', insertedOpportunity.Start_hour__c, 'Start_hour__c should be set to "10:30"');

        testOpportunity.Start_Time__c = DateTime.newInstance(2024, 2, 14, 15, 45, 0);

        update testOpportunity;

        Opportunity updatedOpportunity = [SELECT Id, Start_hour__c FROM Opportunity WHERE Id = :testOpportunity.Id];

        System.assertEquals('15:45', updatedOpportunity.Start_hour__c, 'Start_hour__c should be updated to "15:45"');
    }
}