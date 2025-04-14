trigger ShiftTemplateTrigger on Shift_Template__c (before insert, before update) {


    List<Shift_Template__c> stList = new List<Shift_Template__c>();
    for(Shift_Template__c st :Trigger.new){
        stList.add(st);
    }

    ShiftTemplateHandlerClass.lookForDuplicates(stList);
}