@isTest
public class CampaignInvitationFormControllerTest {
    @isTest
    public static void testCampaignInvitationFormCntr(){
        Campaign cam = new Campaign();
        cam.Name = 'Test class';
        cam.StartDate = Date.today().addDays(-100);
        cam.EndDate = Date.today().addDays(100);
        cam.Title_EN__c = 'test';
        cam.Title_NL__c = 'test';
        cam.Confirmation_EN__c = 'test';
        cam.Confirmation_NL__c = 'test';
        cam.Text_Subscription_EN__c = 'test';
        cam.Text_Subscription_NL__c = 'test';
        cam.Incorrect_Link_EN__c = 'test';
        cam.Incorrect_Link_NL__c = 'test';
        insert cam;
        
        cam = CampaignInvitationFormController.getCampaign(cam.Id);
        
        contact con = new contact();
        con.FirstName = 'test';
        con.LastName = 'test';
        con.Email = 'test@email.com';
        insert con;
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = cam.Id;
        cm.Additional_Info__c = 'test rk\ntest jk';
        cm.Amount_Of_Persons__c = 2;
        insert cm;
        
        List<Campaign_Timeslot__c> ctLst = CampaignInvitationFormController.getTimeSlot(cam.Id);
        
        Map<String,Object> ErrRes = CampaignInvitationFormController.getCampaignMember(cam.Id, cam.Id);
        Map<String,Object> res = CampaignInvitationFormController.getCampaignMember(cam.Id, con.Id);
        
        List<CampaignInvitationFormController.otherPersonInfo> opLst = CampaignInvitationFormController.getNewOtherPerson(2,0);
        CampaignInvitationFormController.responseClass response = (CampaignInvitationFormController.responseClass)res.get('response');
        response.registered = 'yes';
        CampaignInvitationFormController.saveResponse(response);
        
        CampaignMember cm1 = new CampaignMember();
        cm1.Id = cm.Id;
        cm1.Amount_Of_Persons__c = null;
        update cm1;
        
        res = CampaignInvitationFormController.getCampaignMember(cam.Id, con.Id);
        response = (CampaignInvitationFormController.responseClass)res.get('response');
        response.registered = 'no';
        CampaignInvitationFormController.saveResponse(response);
        
        CampaignMember cm2 = new CampaignMember();
        cm2.Id = cm.Id;
        cm2.Amount_Of_Persons__c = 0;
        cm2.Additional_Info__c = null;
        update cm2;
        
        res = CampaignInvitationFormController.getCampaignMember(cam.Id, con.Id);
        response = (CampaignInvitationFormController.responseClass)res.get('response');
        response.registered = 'no';
        CampaignInvitationFormController.saveResponse(response);
    }
}