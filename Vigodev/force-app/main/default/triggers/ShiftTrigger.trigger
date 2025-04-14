trigger ShiftTrigger on Shift (after insert, after update) {
    // ShiftTriggerHandlerClass handler = new ShiftTriggerHandlerClass();

    if(Trigger.isUpdate && Trigger.IsAfter){
        List <Shift> shiftListToDelete = new List <Shift>();
        List <Shift> shiftToUpdate = new List <Shift>();
       for(Shift shift :Trigger.new){
        if (shift.Job_Profile__c != Trigger.oldMap.get(shift.Id).Job_Profile__c) {
            shiftListToDelete.add(shift);
            if(shift.Job_Profile__c != null){
                shiftToUpdate.add(shift);
            }
        }
       }
    if(shiftListToDelete.size() > 0) {
       ShiftTriggerHandlerClass.deleteShiftWorkTopics(shiftListToDelete);
        }
    if(shiftToUpdate.size() > 0) {
        ShiftTriggerHandlerClass.createShiftWorkTopics(shiftToUpdate);
      } 
    }

    if(Trigger.isInsert && Trigger.IsAfter){
        List <Shift> shiftList = new List <Shift>();
        for(Shift shift :Trigger.new){
            if(shift.Job_Profile__c != null) {
                System.debug('passing shift to controller');
                shiftList.add(shift);
            }
        }
        if(shiftList.size() > 0) {
       ShiftTriggerHandlerClass.createShiftWorkTopics(shiftList);
        }
    }
}
