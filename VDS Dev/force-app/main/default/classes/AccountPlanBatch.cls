/*
@author         BRIGHTFOX-SKELBER
@Date           4 November 2025
@Description    CRMIMPL-2330: AccountPlan batch class calculating:
                - Top 3 Product Groups (YTD & Y-1) based on involvements
                - Project Win % (YTD & Y-1) via Project_Relation__c.Winning_Partner__c
                - Project Acquisition Win % (YTD & Y-1) via Orders (Quote requester)
*/

public with sharing class AccountPlanBatch implements Database.Batchable<sObject> {

    public Integer currentYear = Date.today().year();
    public Integer lastYear = Date.today().year() - 1;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, AccountId, PMC_Type__c
            FROM AccountPlan
            WHERE AccountId != null
        ]);
    }

    public void execute(Database.BatchableContext bc, List<AccountPlan> scope) {
        if (scope.isEmpty()) return;

        // -----------------------------
        // Map AccountPlan Id -> AccountId
        // -----------------------------
        Map<Id, AccountPlan> accountPlanMap = new Map<Id, AccountPlan>();
        Set<Id> accountIds = new Set<Id>();
        for (AccountPlan ap : scope) {
            if (ap.AccountId != null) {
                accountIds.add(ap.AccountId);
                accountPlanMap.put(ap.Id, ap);
            }
        }
        if (accountIds.isEmpty()) return;

        // -----------------------------
        // Product Groups (YTD + Last Year)
        // -----------------------------
        Map<Id, List<String>> accountToCurrentYearGroups = mapAccountToProductGroups(scope, currentYear);
        Map<Id, List<String>> accountToLastYearGroups = mapAccountToProductGroups(scope, lastYear);

        // -----------------------------
        // Project Win % and Acquisition Win %
        // -----------------------------
        Map<Id, Integer> totalProjectsCurrent = new Map<Id, Integer>();
        Map<Id, Integer> wonProjectsCurrent = new Map<Id, Integer>();
        Map<Id, Integer> totalProjectsLast = new Map<Id, Integer>();
        Map<Id, Integer> wonProjectsLast = new Map<Id, Integer>();

        Map<Id, Integer> totalAcquisitionCurrent = new Map<Id, Integer>();
        Map<Id, Integer> wonAcquisitionCurrent = new Map<Id, Integer>();
        Map<Id, Integer> totalAcquisitionLast = new Map<Id, Integer>();
        Map<Id, Integer> wonAcquisitionLast = new Map<Id, Integer>();

        // --- Query all VDS_Project opportunities for accounts ---
        List<Opportunity> vdsOpps = [
            SELECT Id, AccountId, CloseDate
            FROM Opportunity
            WHERE RecordType.DeveloperName = 'VDS_Project'
              AND AccountId IN :accountIds
              AND CALENDAR_YEAR(CloseDate) IN :new Set<Integer>{currentYear, lastYear}
        ];

        Map<Id, Opportunity> oppIdToOpp = new Map<Id, Opportunity>();
        Set<Id> allOppIds = new Set<Id>();
        for (Opportunity o : vdsOpps) {
            oppIdToOpp.put(o.Id, o);
            allOppIds.add(o.Id);
        }

        // --- Query Orders linked to these opportunities (for Acquisition) ---
        Map<Id, Set<Id>> accountToAcquiredOpps = new Map<Id, Set<Id>>();
        if (!allOppIds.isEmpty()) {
            for (Order ord : [
                SELECT Id, OpportunityId, AccountId
                FROM Order
                WHERE OpportunityId IN :allOppIds
                  AND AccountId != null
            ]) {
                if (!accountToAcquiredOpps.containsKey(ord.AccountId)) {
                    accountToAcquiredOpps.put(ord.AccountId, new Set<Id>());
                }
                accountToAcquiredOpps.get(ord.AccountId).add(ord.OpportunityId);
            }
        }

        // --- Query involvements and include Winning_Partner__c ---
        List<Project_Relation__c> prList = [
            SELECT Account_Ref__c, VDSProject_Ref__c, Winning_Partner__c
            FROM Project_Relation__c
            WHERE Account_Ref__c IN :accountIds
              AND VDSProject_Ref__c IN :allOppIds
        ];

        // --- Dedup trackers per account per year ---
        Map<Id, Set<Id>> seenOppsCurrent = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> seenOppsLast = new Map<Id, Set<Id>>();

        Map<Id, Set<Id>> seenWinsCurrent = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> seenWinsLast = new Map<Id, Set<Id>>();

        Map<Id, Set<Id>> seenAcqWinsCurrent = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> seenAcqWinsLast = new Map<Id, Set<Id>>();

        // --- Process involvements (dedup per account/opp) ---
        for (Project_Relation__c pr : prList) {
            Opportunity o = oppIdToOpp.get(pr.VDSProject_Ref__c);
            if (o == null) {
                continue;
            }

            Id accId = pr.Account_Ref__c;
            Integer year = o.CloseDate.year();

            // choose maps based on year
            Map<Id, Integer> totalMap = (year == currentYear) ? totalProjectsCurrent : totalProjectsLast;
            Map<Id, Integer> wonMap = (year == currentYear) ? wonProjectsCurrent : wonProjectsLast;
            Map<Id, Integer> totalAcqMap = (year == currentYear) ? totalAcquisitionCurrent : totalAcquisitionLast;
            Map<Id, Integer> wonAcqMap = (year == currentYear) ? wonAcquisitionCurrent : wonAcquisitionLast;

            Map<Id, Set<Id>> seenOppsMap = (year == currentYear) ? seenOppsCurrent : seenOppsLast;
            Map<Id, Set<Id>> seenWinsMap = (year == currentYear) ? seenWinsCurrent : seenWinsLast;
            Map<Id, Set<Id>> seenAcqWinsMap = (year == currentYear) ? seenAcqWinsCurrent : seenAcqWinsLast;

            // ensure sets exist
            if (!seenOppsMap.containsKey(accId)) {
                seenOppsMap.put(accId, new Set<Id>());
            }
            if (!seenWinsMap.containsKey(accId)) {
                seenWinsMap.put(accId, new Set<Id>());
            }
            if (!seenAcqWinsMap.containsKey(accId)) {
                seenAcqWinsMap.put(accId, new Set<Id>());
            }

            Id oppId = o.Id;

            // If this opportunity hasn't been counted yet for totals -> count once
            if (!seenOppsMap.get(accId).contains(oppId)) {
                seenOppsMap.get(accId).add(oppId);

                totalMap.put(accId, totalMap.containsKey(accId) ? totalMap.get(accId) + 1 : 1);
                totalAcqMap.put(accId, totalAcqMap.containsKey(accId) ? totalAcqMap.get(accId) + 1 : 1);
            }

            // Project Win: use Winning_Partner__c on Project_Relation__c (count once per acc/opp)
            if (pr.Winning_Partner__c == true && !seenWinsMap.get(accId).contains(oppId)) {
                seenWinsMap.get(accId).add(oppId);
                wonMap.put(accId, wonMap.containsKey(accId) ? wonMap.get(accId) + 1 : 1);
            }

            // Project Acquisition Win: check if this account has an Order on this opp (accountToAcquiredOpps)
            if (accountToAcquiredOpps.containsKey(accId) && accountToAcquiredOpps.get(accId).contains(oppId)) {
                if (!seenAcqWinsMap.get(accId).contains(oppId)) {
                    seenAcqWinsMap.get(accId).add(oppId);
                    wonAcqMap.put(accId, wonAcqMap.containsKey(accId) ? wonAcqMap.get(accId) + 1 : 1);
                }
            }
        }

        // -----------------------------
        // Update AccountPlan Records
        // -----------------------------
        List<AccountPlan> toUpdate = new List<AccountPlan>();
        for (AccountPlan ap : scope) {
            ap.Product_focus_YTD__c = processTop3(accountToCurrentYearGroups.get(ap.AccountId));
            ap.Product_focus_Y_1__c = processTop3(accountToLastYearGroups.get(ap.AccountId));

            ap.Project_win_YTD__c = calcPercentage(wonProjectsCurrent.get(ap.AccountId), totalProjectsCurrent.get(ap.AccountId));
            ap.Project_win_Y_1__c = calcPercentage(wonProjectsLast.get(ap.AccountId), totalProjectsLast.get(ap.AccountId));

            ap.Project_acquisition_win_YTD__c = calcPercentage(wonAcquisitionCurrent.get(ap.AccountId), totalAcquisitionCurrent.get(ap.AccountId));
            ap.Project_acquisition_win_Y_1__c = calcPercentage(wonAcquisitionLast.get(ap.AccountId), totalAcquisitionLast.get(ap.AccountId));

            toUpdate.add(ap);
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('✅ AccountPlan batch finished (Product Focus + Project Win + Acquisition)');
    }

    // ------------------------
    // Helper: Top 3 Products
    // ------------------------
    private String processTop3(List<String> groups) {
        if (groups == null || groups.isEmpty()) return null;

        Map<String, Integer> counts = new Map<String, Integer>();
        for (String g : groups) {
            if (String.isBlank(g)) continue;
            if (counts.containsKey(g)) {
                counts.put(g, counts.get(g) + 1);
            } else {
                counts.put(g, 1);
            }
        }

        List<GroupCount> gcList = new List<GroupCount>();
        for (String k : counts.keySet()) {
            gcList.add(new GroupCount(k, counts.get(k)));
        }
        gcList.sort();

        List<String> topNames = new List<String>();
        Integer take = Math.min(3, gcList.size());
        for (Integer i = 0; i < take; i++) {
            topNames.add(gcList[i].name);
        }
        return String.join(topNames, ', ');
    }

    // ------------------------
    // Helper: Percentage calculation
    // ------------------------
    private Decimal calcPercentage(Integer won, Integer total) {
        if (total != null && total > 0 && won != null) {
            return ((Decimal) won / (Decimal) total * 100).setScale(2);
        }
        return 0;
    }

    // ------------------------
    // Helper: GroupCount for sorting
    // ------------------------
    private class GroupCount implements Comparable {
        public String name;
        public Integer count;

        public GroupCount(String name, Integer count) {
            this.name = name;
            this.count = count;
        }

        public Integer compareTo(Object other) {
            GroupCount o = (GroupCount) other;
            if (this.count == o.count) return this.name.compareTo(o.name);
            return o.count - this.count; // descending
        }
    }

    // ------------------------
    // Helper: Map AccountId -> Product Groups from involvements (PMC filtered)
    // ------------------------
    private Map<Id, List<String>> mapAccountToProductGroups(List<AccountPlan> accountPlans, Integer year) {
        Map<Id, List<String>> accountToGroups = new Map<Id, List<String>>();
        if (accountPlans.isEmpty()) return accountToGroups;

        Set<Id> accountIds = new Set<Id>();
        Map<Id, String> accountIdToPMC = new Map<Id, String>();
        for (AccountPlan ap : accountPlans) {
            if (ap.AccountId != null) {
                accountIds.add(ap.AccountId);
                accountIdToPMC.put(ap.AccountId, ap.PMC_Type__c);
            }
        }

        // Query involvements
        List<Project_Relation__c> prList = [
            SELECT Account_Ref__c, VDSProject_Ref__c
            FROM Project_Relation__c
            WHERE Account_Ref__c IN :accountIds
              AND VDSProject_Ref__c != null
        ];

        // Collect unique opportunity IDs per account
        Map<Id, Set<Id>> accountToOppIds = new Map<Id, Set<Id>>();
        Set<Id> allOppIds = new Set<Id>();
        for (Project_Relation__c pr : prList) {
            if (!accountToOppIds.containsKey(pr.Account_Ref__c)) accountToOppIds.put(pr.Account_Ref__c, new Set<Id>());
            accountToOppIds.get(pr.Account_Ref__c).add(pr.VDSProject_Ref__c);
            allOppIds.add(pr.VDSProject_Ref__c);
        }

        if (allOppIds.isEmpty()) return accountToGroups;

        // Query opportunities filtered by year
        List<Opportunity> opps = [
            SELECT Id, Product_Group__c, CreatedDate, PMC__c
            FROM Opportunity
            WHERE Id IN :allOppIds
              AND CALENDAR_YEAR(CreatedDate) = :year
              AND Product_Group__c != null
        ];

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for (Opportunity o : opps) oppMap.put(o.Id, o);

        // Collect products for top 3
        for (Id accId : accountToOppIds.keySet()) {
            String apPMC = accountIdToPMC.get(accId);
            List<String> products = new List<String>();
            Set<Id> oppIds = accountToOppIds.get(accId);

            for (Id oppId : oppIds) {
                Opportunity o = oppMap.get(oppId);
                if (o == null || String.isBlank(o.Product_Group__c)) continue;
                if (o.PMC__c != apPMC) continue; // match PMC only

                for (String p : o.Product_Group__c.split(';')) {
                    if (!String.isBlank(p)) products.add(p.trim());
                }
            }
            accountToGroups.put(accId, products);
        }

        return accountToGroups;
    }
}