/*******************************************************************************
* @author           BRIGHTFOX-NVAESEN
* @date             8 January 2024
* @description      Scheduler class to launch the ProjectBasicCloseBatch every day at 3 am
********************************************************************************/
public with sharing class ProjectBasicCloseBatchScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc){
        ProjectBasicCloseBatch projectBatch = new ProjectBasicCloseBatch(false);
        Database.executeBatch(projectBatch, 20);
    }
}