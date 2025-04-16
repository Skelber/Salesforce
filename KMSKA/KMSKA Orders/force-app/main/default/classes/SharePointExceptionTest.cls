@isTest
private class SharePointExceptionTest {
    static testmethod void testM(){
        Test.startTest();
        SharePointException  e = new SharePointException ('Error', false);
        e.addError('Error', false);
        Test.stopTest();
    }
}