public with sharing class CampaignMemberHistoryController {
    @AuraEnabled(cacheable=true)
    public static List<Campaign_Member_History__c> getCampaignMemberHistoryByCampaignMember(Id campaignMemberId) {
        if (campaignMemberId == null) {
            return new List<Campaign_Member_History__c>();
        }

        // Get ContactId and CampaignId from the CampaignMember
        CampaignMember cm = [
            SELECT Id, ContactId, CampaignId
            FROM CampaignMember
            WHERE Id = :campaignMemberId
            LIMIT 1
        ];

        // If either field is null, return empty list
        if (cm == null || cm.ContactId == null || cm.CampaignId == null) {
            return new List<Campaign_Member_History__c>();
        }

        // Query the history records based on the derived ids
        List<Campaign_Member_History__c> results = [
            SELECT Id, Name, Contact__c, Campaign__c, CreatedDate, Modified_By__c, Old_Value__c, New_Value__c
            FROM Campaign_Member_History__c
            WHERE Contact__c = :cm.ContactId
              AND Campaign__c = :cm.CampaignId
            ORDER BY CreatedDate DESC
        ];

        return results;
    }
}
