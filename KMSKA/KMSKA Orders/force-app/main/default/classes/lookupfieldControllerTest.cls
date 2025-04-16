@isTest
public class lookupfieldControllerTest {
	@isTest
    public static void testlookupfieldController(){
        lookupfieldController.objectDetails response = lookupfieldController.getObjectDetails('Account');
        string iconName = lookupfieldController.findObjectIcon('Account');
        
        Account act = new Account(Name='Test class Lookup');
        insert act;

		List<String> ReturnFields = new List<String>();
        List<String> QueryFields = new List<String>();
        QueryFields.add('Name');
        
        List<sObject> res = lookupfieldController.GetRecord('Account', ReturnFields, act.Id);
        res = lookupfieldController.GetRecentRecords('Account', ReturnFields,5);
        res = lookupfieldController.SearchRecords('Account', ReturnFields, QueryFields,'Test class Lookup','Name','DESC',1,null,false);
        res = lookupfieldController.SearchRecords('User', ReturnFields, QueryFields,'Admin','Name','DESC',1,null,true);
        
        system.assertEquals(true, iconName!=null);
    }
}