/*
@author         BRIGHTFOX-SKELBER
@Date           4 November 2025
@Description    CRMIMPL-2330: This class will calculate fields for Account Plan, due to the complexity of the calculation, it will be done in a batch. 
*/

public with sharing class AccountPlanBatch implements Database.Batchable<sObject> {

    public Integer currentYear = Date.today().year();
    public Integer lastYear = Date.today().year() - 1;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, AccountId
            FROM AccountPlan
            WHERE AccountId != null
        ]);
    }

    public void execute(Database.BatchableContext bc, List<AccountPlan> scope) {
        Set<Id> accountIds = new Set<Id>();
        for (AccountPlan ap : scope) {
            if (ap.AccountId != null) accountIds.add(ap.AccountId);
        }
        if (accountIds.isEmpty()) return;

        // Two maps for YTD and Y-1
        Map<Id, List<String>> accountToCurrentYearGroups = new Map<Id, List<String>>();
        Map<Id, List<String>> accountToLastYearGroups = new Map<Id, List<String>>();

        // Query all Opportunities from both years in one go
        for (Opportunity opp : [
            SELECT Id, AccountId, Product_Group__c, CreatedDate
            FROM Opportunity
            WHERE AccountId IN :accountIds
              AND CALENDAR_YEAR(CreatedDate) IN :new Set<Integer>{currentYear, lastYear}
              AND Product_Group__c != null
        ]) {
            if (opp.Product_Group__c == null) continue;

            Integer oppYear = opp.CreatedDate.year();
            List<String> parts = opp.Product_Group__c.split(';');
            for (String p : parts) {
                if (String.isBlank(p)) continue;
                String trimmed = p.trim();

                if (oppYear == currentYear) {
                    if (!accountToCurrentYearGroups.containsKey(opp.AccountId)) {
                        accountToCurrentYearGroups.put(opp.AccountId, new List<String>());
                    }
                    accountToCurrentYearGroups.get(opp.AccountId).add(trimmed);
                } else if (oppYear == lastYear) {
                    if (!accountToLastYearGroups.containsKey(opp.AccountId)) {
                        accountToLastYearGroups.put(opp.AccountId, new List<String>());
                    }
                    accountToLastYearGroups.get(opp.AccountId).add(trimmed);
                }
            }
        }

        List<AccountPlan> toUpdate = new List<AccountPlan>();

        for (AccountPlan ap : scope) {
            // Handle current year
            List<String> currentGroups = accountToCurrentYearGroups.get(ap.AccountId);
            ap.Product_focus_YTD__c = processTop3(currentGroups);

            // Handle last year
            List<String> lastYearGroups = accountToLastYearGroups.get(ap.AccountId);
            ap.Product_focus_Y_1__c = processTop3(lastYearGroups);

            toUpdate.add(ap);
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('AccountPlan batch finished (YTD + Last Year)');
    }

    // Helper: returns comma-separated top 3 groups or null
    private String processTop3(List<String> groups) {
        if (groups == null || groups.isEmpty()) return null;

        Map<String, Integer> counts = new Map<String, Integer>();
        for (String g : groups) {
            if (String.isBlank(g)) continue;
            counts.put(g, counts.containsKey(g) ? counts.get(g) + 1 : 1);
        }

        List<GroupCount> gcList = new List<GroupCount>();
        for (String key : counts.keySet()) {
            gcList.add(new GroupCount(key, counts.get(key)));
        }
        gcList.sort();

        List<String> topNames = new List<String>();
        Integer take = Math.min(3, gcList.size());
        for (Integer i = 0; i < take; i++) {
            topNames.add(gcList[i].name);
        }
        return String.join(topNames, ', ');
    }

    // Helper inner class for sorting by count (descending)
    private class GroupCount implements Comparable {
        public String name;
        public Integer count;

        public GroupCount(String name, Integer count) {
            this.name = name;
            this.count = count;
        }

        public Integer compareTo(Object other) {
            GroupCount o = (GroupCount) other;
            if (this.count == o.count) {
                return this.name.compareTo(o.name);
            }
            return o.count - this.count; // descending
        }
    }
}