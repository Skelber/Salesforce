@isTest
public class CampaignInvitationkulFormControllerTest {
    @isTest
    public static void testCampaignInvitationFormCntr(){
        contact con = new contact();
        con.FirstName = 'test';
        con.LastName = 'test';
        con.Email = 'test@email.com';
        insert con;
        
        CampaignInvitationkulFormController.getAllPicklistMap();
        CampaignInvitationkulFormController.getData(con.Id);
        CampaignInvitationkulFormController.formRes res =  CampaignInvitationkulFormController.getFormInfo();
        CampaignInvitationkulFormController.conInfo cInfo = new CampaignInvitationkulFormController.conInfo();
        
        cInfo.conId = con.Id;
        cInfo.isVoornaam = true;
        cInfo.isNaam = true;
        cInfo.isAdres = false;
        cInfo.isPostcode = false;
        cInfo.isGemeente = false;
        cInfo.isEmail = false;
        cInfo.isGeboortedatum = false;
        cInfo.isGender = false;
        cInfo.adres = '123';
        cInfo.postcode = '123';
        cInfo.gemeente = '123';
        cInfo.email = 'test@class.com.testclass';
        cInfo.geboortedatum = Date.today().addYears(-20);
        cInfo.gender = 'Male';
        
        CampaignInvitationkulFormController.saveResponse(cInfo,res);
    }
}