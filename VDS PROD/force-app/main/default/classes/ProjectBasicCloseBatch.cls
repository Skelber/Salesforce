/*******************************************************************************
* @author           BRIGHTFOX-NVAESEN
* @date             8 January 2024
* @description      This class will close the Projects of recordtype VDS Basic Project when all Quotes are Denied.
********************************************************************************/
public class ProjectBasicCloseBatch implements Database.Batchable<SObject>, Database.Stateful {

    public String errorLogId = '';
    public List<String> recordIdsUpdated = new List<String>();
    public List<String> recordIdsWithError = new List<String>();
    public Integer recordsUpdated = 0;
    public Integer recordsFailed = 0;
    public Boolean updateAll = false;

    public ProjectBasicCloseBatch(Boolean updateAllInput) {
        initializeLogger();
        updateAll = updateAllInput;
    }

    private void initializeLogger() {
        String userId = UserInfo.getUserId();
        Log__c parentLog = new Log__c(
            Function_Name__c = 'ProjectBasicCloseBatch',
            Message__c = 'ProjectBasicCloseBatch was executed.',
            Method__c = 'ProjectBasicCloseBatch.execute()',
            Source_Type__c = Logger.LOG_SOURCETYPE_BATCH,
            Severity__c = Logger.LOG_SEVERITY_INFO
        );
        insert parentLog;
        errorLogId = parentLog.Id;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime now = DateTime.now().addDays(-1);
        DateTime startOfDay = now.addHours(-now.hour()).addMinutes(-now.minute()).addSeconds(-now.second());
        String yesterday = startOfDay.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String basicProjectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VDS_Basic_Project').getRecordTypeId();

        String query = 'SELECT Id, Number_of_Quotes__c, Amount_Denied_Quotes__c, IsClosed ' +
                       'FROM Opportunity ' +
                       'WHERE Amount_Denied_Quotes__c != null AND IsClosed = false AND RecordTypeId = \'' + basicProjectRecordTypeId + '\'';

        if (!updateAll) {
            query += ' AND LastModifiedDate >= ' + yesterday;
        }

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> projects) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        for (Opportunity project : projects) {
            if (project.Number_of_Quotes__c != null && project.Amount_Denied_Quotes__c != null &&
                project.Number_of_Quotes__c == project.Amount_Denied_Quotes__c) {
                project.Status__c = '50';
                project.StageName = 'Closed Lost';
                opportunitiesToUpdate.add(project);
            }
        }

        Database.SaveResult[] saveResults;
        try {
            if (!opportunitiesToUpdate.isEmpty()) {
                saveResults = Database.update(opportunitiesToUpdate, false);
            }
        } catch (Exception exceptionError) {
            handleExceptionError(exceptionError);
        }
        if (saveResults != null && saveResults.size() > 0){
            handleSaveResults(saveResults);
        }
    }

    private void handleExceptionError(Exception exceptionError) {
        Logger loggerInstance = new Logger();
        loggerInstance.addFunctionName('ProjectBasicCloseBatch')
            .addSourceType(Logger.LOG_SOURCETYPE_BATCH)
            .addMessage('Exception Message: ' + exceptionError.getMessage() + ' CAUSE: ' + exceptionError.getCause())
            .addMethod('ProjectBasicCloseBatch.execute()')
            .addSeverity(Logger.LOG_SEVERITY_ERROR)
            .addParentId(String.isNotBlank(errorLogId) ? errorLogId : null)
            .addStackTrace(exceptionError.getStackTraceString())
            .fire();
    }

    private void handleSaveResults(Database.SaveResult[] saveResults) {
        String baseURL = Base_URL_Settings__c.getOrgDefaults().Base_URL__c;

        for (Database.SaveResult saveResult : saveResults) {
            if (saveResult.isSuccess()) {
                recordsUpdated++;
                recordIdsUpdated.add(baseURL + '/' + saveResult.getId());
            } else {
                handleSaveError(saveResult, baseURL);
            }
        }
    }

    private void handleSaveError(Database.SaveResult saveResult, String baseURL) {
        String errorMessage = '';
        recordsFailed++;
        recordIdsWithError.add(baseURL + '/' + saveResult.getId());

        for (Database.Error error : saveResult.getErrors()) {
            errorMessage += 'Error Message: ' + error.getMessage() + ' on the fields: ' + error.getFields() + ' - ProjectId: ' + saveResult.getId();
        }

        Logger loggerInstance = new Logger();
        loggerInstance.addFunctionName('ProjectBasicCloseBatch')
            .addSourceType(Logger.LOG_SOURCETYPE_BATCH)
            .addSeverity(Logger.LOG_SEVERITY_ERROR)
            .addMessage(errorMessage)
            .addRecordId(saveResult.getId())
            .addParentId(String.isNotBlank(errorLogId) ? errorLogId : null)
            .fire();
    }

    public void finish(Database.BatchableContext BC) {
        updateErrorLog();
    }

    private void updateErrorLog() {
        List<Log__c> logs = [SELECT Id, Message__c, FailedRecords__c FROM Log__c WHERE Id = :errorLogId LIMIT 1];

        if (!logs.isEmpty()) {
            Log__c log = logs[0];
            String message = log.Message__c;
            message += '\n' + recordsUpdated + ' record(s) updated.';
            message += '\n' + recordsFailed + ' record(s) failed to update.';
            log.FailedRecords__c = String.join(recordIdsWithError, '\n');
            log.Message__c = message;
            update log;
        }
    }
}