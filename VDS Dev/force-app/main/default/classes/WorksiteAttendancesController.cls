public with sharing class WorksiteAttendancesController {
    
    @AuraEnabled(Cacheable = false)
    public static List<WorksiteAttendanceWrapper> getAttendances(Id workStepId){
        try {
            List<WorksiteAttendanceWrapper> worksiteAttendancesList = new List<WorksiteAttendanceWrapper>();
            WorkStep workStep = [SELECT WorkOrderLineItemId, WorkOrderLineItem.WorkOrder.CaseId FROM WorkStep WHERE Id = :workStepId];
            List<Worksite_Attendance__c> worksiteAttendances = [SELECT Id, Contact__c, Contact__r.Name, Other_Contact__c, Role__c, toLabel(Role__c) RoleLabel, Present__c, Worksite_Report__c FROM Worksite_Attendance__c WHERE Work_Order_Line_Item__c = :workStep.WorkOrderLineItemId];

            Integer i = 1;
            for(Project_Relation__c projectRelation : [SELECT Contact_Ref__c, Contact_Ref__r.Name, Role__c, toLabel(Role__c) RoleLabel FROM Project_Relation__c WHERE Case_Ref__c = :workStep.WorkOrderLineItem.WorkOrder.CaseId AND Contact_Ref__c <> NULL]) {
                Boolean found = false;
                for(Worksite_Attendance__c worksiteAttendance : worksiteAttendances) {
                    if (worksiteAttendance.Contact__c != null && worksiteAttendance.Contact__c.equals(projectRelation.Contact_Ref__c)) {
                        worksiteAttendancesList.add(new WorksiteAttendanceWrapper(i, worksiteAttendance.Contact__c, worksiteAttendance.Contact__r.Name, worksiteAttendance.Role__c, (String)worksiteAttendance.get('RoleLabel'), worksiteAttendance.Present__c, worksiteAttendance.Worksite_Report__c));
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    worksiteAttendancesList.add(new WorksiteAttendanceWrapper(i, projectRelation.Contact_Ref__c, projectRelation.Contact_Ref__r.Name, projectRelation.Role__c, (String)projectRelation.get('RoleLabel'), false, false));
                }
                i++;
            }

             WorksiteAttendanceWrapper otherContactWrapper = new WorksiteAttendanceWrapper(i, null, '', '','', false, false);
             for(Worksite_Attendance__c worksiteAttendance : worksiteAttendances) {
                 if (String.isNotBlank(worksiteAttendance.Other_Contact__c)) {
                     otherContactWrapper.contactName = worksiteAttendance.Other_Contact__c;
                     otherContactWrapper.role = worksiteAttendance.Role__c;
                     otherContactWrapper.present = worksiteAttendance.Present__c;
                     otherContactWrapper.report = worksiteAttendance.Worksite_Report__c;
                 }
             }
             worksiteAttendancesList.add(otherContactWrapper);
            return worksiteAttendancesList;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<WorksiteAttendanceWrapper> save(Id workStepId, List<WorksiteAttendanceWrapper> attendances) {
        try {
            WorkStep workStep = [SELECT Id, WorkOrderLineItemId FROM WorkStep WHERE Id = :workStepId];
            List<Worksite_Attendance__c> existingAttendances = [SELECT Id FROM Worksite_Attendance__c WHERE Work_Order_Line_Item__c = :workStep.WorkOrderLineItemId];
            delete existingAttendances;

            List<Worksite_Attendance__c> newAttendances = new List<Worksite_Attendance__c>();
            for(WorksiteAttendanceWrapper attendance : attendances) {
                if (!(attendance.present || attendance.report)) {
                    continue;
                }
                newAttendances.add(new Worksite_Attendance__c(
                    Work_Order_Line_Item__c = workStep.WorkOrderLineItemId,
                    Contact__c = attendance.contactId,
                    Role__c = attendance.role,
                    Other_Contact__c = attendance.contactId == null ? attendance.contactName : null,
                    Present__c = attendance.present,
                    Worksite_Report__c = attendance.report
                ));
            }
            insert newAttendances;

            workStep.Status = 'Voltooid';
            update workStep;

            return getAttendances(workStepId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 

    public class WorksiteAttendanceWrapper {
        @AuraEnabled
        public Integer key {get; set;}
        @AuraEnabled
        public Id contactId {get; set;}
        @AuraEnabled
        public String contactName {get; set;}
        @AuraEnabled
        public String role {get; set;}
        @AuraEnabled
        public String roleLabel {get; set;}
        @AuraEnabled
        public Boolean present {get; set;}
        @AuraEnabled
        public Boolean report {get; set;}

        public WorksiteAttendanceWrapper() {}

        public WorksiteAttendanceWrapper(Integer key, Id contactId, String contactName, String role, String roleLabel, Boolean present, Boolean report) {
            this.key = key;
            this.contactId = contactId;
            this.contactName = contactName;
            this.role = role;
            this.roleLabel = roleLabel;
            this.present = present;
            this.report = report;
        }
    }

}