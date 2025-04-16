@isTest
public class testpubliekCmpControllerTest {
    @isTest
    public static void testPicklistVal(){
        Map<String, String> P1 = testpubliekCmpController.getGender();
        Map<String, String> P2 = testpubliekCmpController.getCurrentSituation();
        Map<String, String> P3 = testpubliekCmpController.getStudyArea();
        Map<String, String> P4 = testpubliekCmpController.getWorkSector();
        Map<String, String> P5 = testpubliekCmpController.getVisitedKMSKA();
        Map<String, String> P6 = testpubliekCmpController.getVisitMusea();
        Map<String, String> P7 = testpubliekCmpController.getReasonNoVisit();
        Map<String, String> P8 = testpubliekCmpController.getContextVisit();
        Map<String, String> P9 = testpubliekCmpController.getInterest();
        Map<String, String> P10 = testpubliekCmpController.getReasonVisits();
        Map<String, String> P11 = testpubliekCmpController.getReasonToVisits();
        Map<String, String> P12 = testpubliekCmpController.getCampaignSource();
        
        Lead l = testpubliekCmpController.getleadObj();
        form__c f = testpubliekCmpController.getformObj();
        
        l.LastName = 'Test';
        l.FirstName = 'Test';
        l.Company = 'Test';
        l.Status = 'Open - Not Contacted';
       	Map<String,String> Result = testpubliekCmpController.SaveRecord(l,f);
        
        Lead lupdated = [SELECT Id FROM Lead WHERE Id =: Result.get('Lead')];
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(lupdated.id);
        lc.setDoNotCreateOpportunity(true);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
    }
}