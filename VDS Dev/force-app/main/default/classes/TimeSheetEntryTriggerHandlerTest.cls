@IsTest
private class TimeSheetEntryTriggerHandlerTest {

    @IsTest
    static void testCalculateWOLITotalTimeSpent() {

        // Create required parent records
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        WorkOrder wo = new WorkOrder(
            Subject = 'Test Work Order',
            AccountId = acc.Id,
            Status = 'New'
        );
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Description = 'Test WOLI'
        );
        insert woli;

        // -----------------------------
        // INSERT TEST
        // -----------------------------
        TimeSheetEntry tse1 = new TimeSheetEntry(
            WorkOrderLineItemId = woli.Id,
            DurationInMinutes = 60,
            StartTime = System.now(),
            EndTime = System.now().addMinutes(60)
        );

        TimeSheetEntry tse2 = new TimeSheetEntry(
            WorkOrderLineItemId = woli.Id,
            DurationInMinutes = 30,
            StartTime = System.now(),
            EndTime = System.now().addMinutes(30)
        );

        insert new List<TimeSheetEntry>{ tse1, tse2 };

        woli = [
            SELECT Total_Time_Spent_minutes__c
            FROM WorkOrderLineItem
            WHERE Id = :woli.Id
        ];

        System.assertEquals(
            90,
            woli.Total_Time_Spent_minutes__c,
            'Total time should equal inserted TimeSheetEntries'
        );

        // -----------------------------
        // UPDATE TEST
        // -----------------------------
        tse1.DurationInMinutes = 120;
        update tse1;

        woli = [
            SELECT Total_Time_Spent_minutes__c
            FROM WorkOrderLineItem
            WHERE Id = :woli.Id
        ];

        System.assertEquals(
            150,
            woli.Total_Time_Spent_minutes__c,
            'Total time should recalculate after update'
        );

        // -----------------------------
        // DELETE TEST
        // -----------------------------
        delete tse2;

        woli = [
            SELECT Total_Time_Spent_minutes__c
            FROM WorkOrderLineItem
            WHERE Id = :woli.Id
        ];

        System.assertEquals(
            120,
            woli.Total_Time_Spent_minutes__c,
            'Total time should recalculate after delete'
        );
    }
}