trigger CaseTriggers on Case (before insert, after insert) {
    if (Trigger.isBefore) {
		CaseTriggerProcess.assignContact(trigger.New);
    }
    if (Trigger.isAfter) {
		CaseTriggerProcess.activateAssignmentRule(trigger.newMap);
    }
}