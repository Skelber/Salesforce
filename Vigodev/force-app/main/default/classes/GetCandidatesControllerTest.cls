@isTest
public with sharing class GetCandidatesControllerTest {
    
    @IsTest(seeAllData = true)
    static void valdiateGetEligibleServiceResources(){

        WorkTypeGroup wtg = new WorkTypeGroup();
        wtg.Name = 'Mobility - bikes - test - test';
        wtg.Business_Unit__c = 'Orthotics';
        wtg.Product_Group__c = 'Head';
        wtg.Product_SubGroup__c = 'Crash helmet';
        wtg.Appointment_Type__c = 'Measurement';
        wtg.GroupType = 'Default';
        insert wtg;
        
        WorkType wt = new WorkType();
        wt.Name = 'test worktype';
        wt.EstimatedDuration = 60;
        wt.DurationType = 'minutes';
        insert wt;

        WorkTypeGroupMember wtgm = new WorkTypeGroupMember();
        wtgm.WorkTypeId = wt.Id;
        wtgm.WorkTypeGroupId = wtg.Id;
        insert wtgm;

        ShiftWorkTopic swt = [SELECT Id, ShiftId FROM ShiftWorkTopic WHERE WorkTypeGroupId != null LIMIT 1];
        system.debug('swt = ' + swt);

        List<GetCandidatesController.shiftInput> ShiftInput = new List<GetCandidatesController.shiftInput>();
        GetCandidatesController.ShiftInput si = new GetCandidatesController.ShiftInput();

        si.StartDate = Date.newInstance(2024, 7, 29);
        si.endDate = Date.newInstance(2024, 8, 30);

        si.shiftId = swt.ShiftId;
        ShiftInput.add(si);

        GetCandidatesController.getEligibleServiceResources(shiftInput);


    }
}