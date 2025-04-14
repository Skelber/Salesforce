trigger EventTrigger on Event (before update, before delete) {

    triggerBypass__c bypassTriggerSetting = triggerBypass__c.getOrgDefaults();
    
    public Boolean bypass = false;

    if(trigger.isUpdate){

        for(Event event :Trigger.new){
            
            
            if(Trigger.oldMap.get(event.Id).Resource_Absence__c == null && event.Resource_Absence__c != null){
                bypass = true;
            }
            
            
            if (event.Resource_Absence__c != null && bypassTriggerSetting.isActive__c == false) {
                event.addError('You can not update an event if it has a linked resource absence.');
            }
        }
    }
    if(trigger.isDelete){

        for(Event event :Trigger.old){
            
            
            if(Trigger.oldMap.get(event.Id).Resource_Absence__c == null && event.Resource_Absence__c != null){
                bypass = true;
            }
            
            
            if (event.Resource_Absence__c != null && bypassTriggerSetting.isActive__c == false) {
                event.addError('You can not delete an event if it has a linked resource absence.');
            }
        }
    }
} 