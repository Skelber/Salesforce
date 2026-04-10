public with sharing class TimeSheetEntryTriggerHandler {

    public static void calculateWOLITotalTimeSpent(
        List<TimeSheetEntry> newList,
        Map<Id, TimeSheetEntry> oldMap
    ) {
        Set<Id> workOrderLineItemIds = new Set<Id>();

        // From inserted/updated records
        if (newList != null) {
            for (TimeSheetEntry tse : newList) {
                if (tse.WorkOrderLineItemId != null) {
                    workOrderLineItemIds.add(tse.WorkOrderLineItemId);
                }
            }
        }

        // From deleted/updated old records
        if (oldMap != null) {
            for (TimeSheetEntry tse : oldMap.values()) {
                if (tse.WorkOrderLineItemId != null) {
                    workOrderLineItemIds.add(tse.WorkOrderLineItemId);
                }
            }
        }

        if (workOrderLineItemIds.isEmpty()) {
            return;
        }

        // Aggregate all durations per WOLI
        Map<Id, Decimal> totalDurationByWOLI = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT WorkOrderLineItemId woliId,
                   SUM(DurationInMinutes) totalDuration
            FROM TimeSheetEntry
            WHERE WorkOrderLineItemId IN :workOrderLineItemIds
            GROUP BY WorkOrderLineItemId
        ]) {
            totalDurationByWOLI.put(
                (Id) ar.get('woliId'),
                (Decimal) ar.get('totalDuration')
            );
        }

        List<WorkOrderLineItem> wolisToUpdate = new List<WorkOrderLineItem>();

        for (Id woliId : workOrderLineItemIds) {
            wolisToUpdate.add(new WorkOrderLineItem(
                Id = woliId,
                Total_Time_Spent_minutes__c =
                    totalDurationByWOLI.containsKey(woliId)
                    ? totalDurationByWOLI.get(woliId)
                    : 0
            ));
        }

        if (!wolisToUpdate.isEmpty()) {
            update wolisToUpdate;
        }
    }
}