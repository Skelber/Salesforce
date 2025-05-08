// LLP-1575

trigger ShiftTrigger on Shift (after insert, after update) {
    
    if(Trigger.IsAfter) {
    
        if(Trigger.isUpdate){
            
            //Delete all existing Shift WOrk Topics of the updated shifts
            ShiftTriggerHandlerClass.deleteShiftWorkTopics(Trigger.new, Trigger.oldMap);
            
            //Create new Shift Work Topics for the updated shifts 
            ShiftTriggerHandlerClass.createShiftWorkTopics(Trigger.new, Trigger.oldMap);
            
        }
        
        if(Trigger.isInsert){
            
            //Create new Shift Work Topics for the created shifts 
            ShiftTriggerHandlerClass.createShiftWorkTopics(Trigger.new, null);
            
        }
        
    }
}