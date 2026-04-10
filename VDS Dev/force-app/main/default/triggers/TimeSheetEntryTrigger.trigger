trigger TimeSheetEntryTrigger on TimeSheetEntry (
    after insert,
    after update,
    after delete
) {
    if (Trigger.isAfter) {

        if (Trigger.isInsert || Trigger.isUpdate) {
            TimeSheetEntryTriggerHandler.calculateWOLITotalTimeSpent(
                Trigger.new,
                Trigger.oldMap
            );
        }

        if (Trigger.isDelete) {
            TimeSheetEntryTriggerHandler.calculateWOLITotalTimeSpent(
                null,
                Trigger.oldMap
            );
        }
    }
}