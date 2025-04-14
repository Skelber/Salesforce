@isTest
public with sharing class ShiftTemplateHandlerClassTest {

    @testSetup static void createData() {

    Job_Profile__c jp = new Job_Profile__c();
    jp.Name = 'Test jobprofile';
    insert jp;
 
     Shift_Template__c st = new Shift_Template__c();
     st.Name = 'test template to test';
     st.Start_Time__c = Time.newInstance(8, 0, 0, 0);
     st.End_Time__c = Time.newInstance(17, 0, 0, 0);
     st.Job_Profile__c = jp.Id;
     insert st;
     }

    @IsTest
   public static void validateLookForDuplicates(){

    String jpId = [SELECT Id FROM Job_Profile__c WHERE Name = 'Test jobprofile' LIMIT 1]?.Id;
  

    test.startTest();

    List<Shift_Template__c> stList = new List<Shift_Template__c>();

    Shift_Template__c st = new Shift_Template__c();
     st.Name = 'test template to test';
     st.Start_Time__c = Time.newInstance(8, 0, 0, 0);
     st.End_Time__c = Time.newInstance(18, 0, 0, 0);
     st.Job_Profile__c = jpId;
     insert st;

      stList.add(st);

     ShiftTemplateHandlerClass.lookForDuplicates(stList);

     test.stopTest();

     List<Shift_Template__c> templatesToValidate = [SELECT Id FROM Shift_Template__c WHERE Name = 'test template to test'];
    

     system.assertEquals(2, templatesToValidate.size());


   }
}