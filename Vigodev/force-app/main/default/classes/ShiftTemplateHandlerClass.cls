public class ShiftTemplateHandlerClass {
    public static void lookForDuplicates(List<Shift_Template__c> newShiftTemplates) {
        // Create sets to hold the unique Start_Time__c, End_Time__c, and Job_Profile__c values
        Set<Time> startTimeSet = new Set<Time>();
        Set<Time> endTimeSet = new Set<Time>();
        Set<Id> jobProfileSet = new Set<Id>();

        // Map to store keys and corresponding new records for error checking
        Map<String, Shift_Template__c> newShiftTemplateMap = new Map<String, Shift_Template__c>();

        // Populate the sets with the values from the new records
        for (Shift_Template__c st : newShiftTemplates) {
            startTimeSet.add(st.Start_Time__c);
            endTimeSet.add(st.End_Time__c);
            jobProfileSet.add(st.Job_Profile__c);

            String key = st.Start_Time__c.toString() + '_' + st.End_Time__c.toString() + '_' + st.Job_Profile__c;
            newShiftTemplateMap.put(key, st);
        }

        // Query existing records that match any of the values in the sets
        List<Shift_Template__c> existingTemplates = [
            SELECT Id, Start_Time__c, End_Time__c, Job_Profile__c 
            FROM Shift_Template__c 
            WHERE Start_Time__c IN :startTimeSet 
            AND End_Time__c IN :endTimeSet
            AND Job_Profile__c IN :jobProfileSet
            AND Id NOT IN :newShiftTemplates
        ];

        // Check for duplicates by comparing the keys of the existing records
        for (Shift_Template__c existing : existingTemplates) {
            String existingKey = existing.Start_Time__c.toString() + '_' + existing.End_Time__c.toString() + '_' + existing.Job_Profile__c;
            if (newShiftTemplateMap.containsKey(existingKey)) {
                newShiftTemplateMap.get(existingKey).addError(
                    System.label.DuplicateShiftTemplateMessage
                );
            }
        }
    }
}