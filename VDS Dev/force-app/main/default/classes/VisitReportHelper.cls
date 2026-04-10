public class VisitReportHelper {
   
   @InvocableMethod(label='GetProjects' description='Return all Open/Active/Non-Basic projects linked to any account that is linked to the contact that have been changed in the last 3 months' category='Screen flows')
    public static List<List<Opportunity>> getProjects(List<ProjectRetriever> input) {
        Id contactId = input[0].contactId;

        Set<Id> accountIds = new Set<Id>();
        for (AccountContactRelation relation : [SELECT AccountId FROM AccountContactRelation WHERE ContactId = :contactId]) {
            accountIds.add(relation.AccountId);
        }
        List<Opportunity> projects =  [SELECT Id, Name FROM Opportunity WHERE Id IN (SELECT VDSProject_Ref__c FROM Project_Relation__c 
                                            WHERE Account_Ref__c IN :accountIds AND VDSProject_Ref__c != NULL) 
                                            AND Inactive__c = false AND RecordType.DeveloperName != 'VDS_Basic_Project' AND (Status__c = '10' OR LastStageChangeDate = LAST_N_MONTHS:3) ORDER BY CreatedDate ASC];

        return new List<List<Opportunity>>{projects}; 
    }
    
    public class ProjectRetriever{
        @InvocableVariable (required=true)
        public Id contactId;
    }

    public static void SetStartAndEndDateForShowroomVisits(List<Visit_Report__c> visitReports) {
        for (Visit_Report__c visitReport : visitReports) {
            if (visitReport.Visit_Date__c != null && String.isNotBlank(visitReport.Visit_Time__c) && visitReport.Start_Date__c == null && visitReport.End_Date__c == null) {
                try {
                    List<String> timeParts = visitReport.Visit_Time__c.split(' - ');
                    List<String> startTimeParts = timeParts[0].split(':');
                    List<String> endTimeParts = timeParts[1].split(':');

                    Integer startHour = Integer.valueOf(startTimeParts[0]);
                    Integer startMinutes = Integer.valueOf(startTimeParts[1]);
                    Integer endHour = Integer.valueOf(endTimeParts[0]);
                    Integer endMinutes = Integer.valueOf(endTimeParts[1]);

                    Date visitDate = visitReport.Visit_Date__c.date();
                    visitReport.Start_Date__c = Datetime.newInstance(visitDate, Time.newInstance(startHour,startMinutes,0,0));
                    visitReport.End_Date__c = Datetime.newInstance(visitDate, Time.newInstance(endHour,endMinutes,0,0));
                } catch (Exception e) {
                    Logger loggerInstance = new Logger();
                    loggerInstance.addFunctionName('VisitReportHelper')
                        .addSourceType(Logger.LOG_SOURCETYPE_APEX)
                        .addMessage('Exception Message: ' + e.getMessage() + ' CAUSE: ' + e.getCause())
                        .addMethod('SetStartAndEndDateForShowroomVisits')
                        .addSeverity(Logger.LOG_SEVERITY_ERROR)
                        .addRecordId(visitReport.Id)
                        .addStackTrace(e.getStackTraceString())
                        .fire();
                }
            }
        }
    }
}