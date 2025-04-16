public class OpportunityClass {
    public static void setTimeValue(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            // Check if Start_Time__c is not null before formatting
            String formattedTime = opp.Start_Time__c != null ? opp.Start_Time__c.format('HH:mm') : null;
            
            // Set the formatted time to Start_hour__c field
            opp.Start_hour__c = formattedTime;
        }
    }
}