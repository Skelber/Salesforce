@IsTest
public class ProjectBasicCloseBatchScheduler_Test {
    @IsTest
    static void testSchedulerExecution() {
        Test.startTest();
        String jobId = System.schedule('Test ProjectBasicCloseBatchScheduler', '0 0 * * * ?', new ProjectBasicCloseBatchScheduler());
        Test.stopTest();
        Assert.areEqual(true, jobId != null, 'jobId shouldn\'t be null.');
    }
}