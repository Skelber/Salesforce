@isTest
public class testpubliekmotivatieCmpControllerTest {

    @isTest
    public static void getLeadTest(){
        Lead L = new Lead();
        L.FirstName = 'Test';
        L.LastName = 'Test';
        L.Company = 'Test Com';
        L.Status = 'Open - Not Contacted';
        insert L;
        
        Lead Lead = testpubliekmotivatieCmpController.getLead(L.Id);
        
        form__c form = testpubliekmotivatieCmpController.getform(L.Id);
        form.Motivation__c = 'Test';
        Map<String,Id> rec = testpubliekmotivatieCmpController.SaveRecord(form,L.Id);
    }
}