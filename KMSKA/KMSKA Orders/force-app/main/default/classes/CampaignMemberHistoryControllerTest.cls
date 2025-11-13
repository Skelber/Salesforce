@IsTest
private class CampaignMemberHistoryControllerTest {

    // Utility test data creation
    private static Contact createContact() {
        Contact c = new Contact(LastName = 'Test Contact');
        insert c;
        return c;
    }

    private static Campaign createCampaign() {
        Campaign camp = new Campaign(Name = 'Test Campaign', IsActive = true);
        insert camp;
        return camp;
    }

    private static CampaignMember createCampaignMember(Id contactId, Id campaignId) {
        CampaignMember cm = new CampaignMember(ContactId = contactId, CampaignId = campaignId, Status = 'Verzonden');
        insert cm;
        return cm;
    }

    private static Campaign_Member_History__c createHistory(Id contactId, Id campaignId) {
        Campaign_Member_History__c h = new Campaign_Member_History__c(
            Contact__c = contactId,
            Campaign__c = campaignId,
            Old_Value__c = 'Old',
            New_Value__c = 'New'
        );
        insert h;
        return h;
    }

    // -------------------
    // TESTS
    // -------------------

    @IsTest
    static void testNullIdReturnsEmptyList() {
        Test.startTest();
        List<Campaign_Member_History__c> results = CampaignMemberHistoryController.getCampaignMemberHistoryByCampaignMember(null);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Should not return null');
        System.assertEquals(0, results.size(), 'Null Id should return empty list');
    }

    @IsTest
    static void testMissingContactReturnsEmptyList() {
        // Create a CampaignMember with only a Lead (no Contact)
        Campaign camp = createCampaign();
        Lead l = new Lead(LastName = 'Lead Test', Company = 'TestCo');
        insert l;

        CampaignMember cm = new CampaignMember(LeadId = l.Id, CampaignId = camp.Id, Status = 'Verzonden');
        insert cm;

        Test.startTest();
        List<Campaign_Member_History__c> results = CampaignMemberHistoryController.getCampaignMemberHistoryByCampaignMember(cm.Id);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'CampaignMember without Contact should return empty list');
    }

    @IsTest
    static void testReturnsMatchingHistoryRecords() {
        Contact c = createContact();
        Campaign camp = createCampaign();
        CampaignMember cm = createCampaignMember(c.Id, camp.Id);

        // Insert matching history records
        Campaign_Member_History__c h1 = createHistory(c.Id, camp.Id);
        Campaign_Member_History__c h2 = createHistory(c.Id, camp.Id);

        // Insert a non-matching record (different campaign)
        Campaign otherCamp = createCampaign();
        Campaign_Member_History__c hOther = createHistory(c.Id, otherCamp.Id);

        Test.startTest();
        List<Campaign_Member_History__c> results = CampaignMemberHistoryController.getCampaignMemberHistoryByCampaignMember(cm.Id);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Should return only history for matching contact & campaign');
        System.assert(!results.contains(hOther), 'Should not include unrelated history records');

        // Verify ordering by CreatedDate DESC
        if (results.size() == 2) {
            System.assert(results[0].CreatedDate >= results[1].CreatedDate, 'Results should be ordered by CreatedDate DESC');
        }
    }

    @IsTest
    static void testInvalidIdThrowsQueryException() {
        Boolean threw = false;

        try {
            Test.startTest();
            CampaignMemberHistoryController.getCampaignMemberHistoryByCampaignMember('003000000000000AAA'); // Random Contact Id format
            Test.stopTest();
        } catch (QueryException e) {
            threw = true;
        }

        System.assert(threw, 'Expected QueryException for invalid CampaignMember Id');
    }
}