@isTest
public class CaseTriggersTest {

    @isTest
    public static void testInsert(){
        Case cs = new Case();
        cs.Origin = 'Email';
        cs.SuppliedEMail = 'testclass@class.com';
        cs.SuppliedName = 'Test Class';
        cs.Web_First_Name__c = 'Test FName';
        cs.Web_Last_Name__c = 'Test';
        cs.Web_Taal__c = 'Frans';
        insert cs;
        
        Case cs1 = new Case();
        cs1.Origin = 'Email';
        cs1.SuppliedEMail = 'testclasses@class.com';
        cs1.SuppliedName = 'Test Class2';
        cs1.Web_First_Name__c = 'Test FName2';
        cs1.Web_Last_Name__c = 'Test lastname 2';
        cs1.Web_Taal__c = 'Frans';
        insert cs1;
    }
}