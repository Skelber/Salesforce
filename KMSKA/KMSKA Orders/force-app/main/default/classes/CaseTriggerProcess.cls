public class CaseTriggerProcess {
    
    public static void activateAssignmentRule(Map<Id,Case> newMap) {
        List<case> cases = [SELECT Id FROM Case WHERE Id IN: newMap.Keyset()];
        
        //AssignmentRule AR = new AssignmentRule();
        //AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        //dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        dmlOpts.assignmentRuleHeader.useDefaultRule  = true;
        dmlOpts.EmailHeader.triggerUserEmail = true;
        
        
        List<case> casesToUpdate = new List<case>();
        for (Case cs : cases) {
            cs.setOptions(dmlOpts); 
            casesToUpdate.add(cs);
        }
    
        Database.update(casesToUpdate,false); 
    }
    
    
    public static void assignContact(List<Case> triggerNew) {
        Map<Id, Case> caseIdCaseMap = new Map<Id, Case>();
        Set<String> webEmails = new Set<String>();
        
        for (Case cs : triggerNew) {
            System.debug('### cs : ' + cs);
            //cs.setOptions(dmlOpts);
            if(cs.Origin == 'Email'){
                cs.type = 'Algemene informatie';
            }
            if (cs.ContactId == null && cs.SuppliedEMail != null) {
                caseIdCaseMap.put(cs.Id, cs);
                webEmails.add(cs.SuppliedEmail);
            }
        }
        
        if (caseIdCaseMap.size() != 0) {
            
            Map<String, Contact> contactKeyContact = new Map<String, Contact>();
            List<Contact> existingContacts = [
                SELECT Id, Name, Email, Preferred_Language__c
                FROM Contact
                WHERE Email IN :webEmails
            ];
            
            for (Contact ctc : existingContacts) {
                contactKeyContact.put(ctc.Email, ctc);
            }
            
            List<Case> casesToUpdate = new List<Case>();
            Map<Id,Contact> contactsToCreate = new Map<Id,Contact>();  
            List<Contact> contactsToUpdate = new List<Contact>();  
            
            for (Case cs : caseIdCaseMap.values()) {
                if(contactKeyContact.get(cs.SuppliedEmail)!=null){
                    Contact con = contactKeyContact.get(cs.SuppliedEmail);
                    cs.ContactId = con.Id;
                    if( (con.Preferred_Language__c==null || con.Preferred_Language__c=='') && cs.Web_Taal__c!=null && cs.Web_Taal__c!=''){
                        con.Preferred_Language__c = cs.Web_Taal__c;
                        contactsToUpdate.add(con);
                    }
                    casesToUpdate.add(cs);
                }else{
                     if(cs.Origin == 'Web'){
                        String LastName = cs.Web_Last_Name__c!=null?cs.Web_Last_Name__c: (cs.SuppliedEmail).substringBefore('@');
                    	contactsToCreate.put(cs.Id, new Contact(Email = cs.SuppliedEmail, LastName = LastName, FirstName = cs.Web_First_Name__c,Preferred_Language__c  = cs.Web_Taal__c, To_Be_Validated__c = true));
                     } else {
                        String LastName = cs.SuppliedName!=null?cs.SuppliedName: (cs.SuppliedEmail).substringBefore('@');
                    	contactsToCreate.put(cs.Id, new Contact(Email = cs.SuppliedEmail, LastName = LastName, To_Be_Validated__c = true,Preferred_Language__c  = cs.Web_Taal__c));
                     }
                   
                }
                Database.DMLOptions dbDML = new Database.DMLOptions(); 
                dbDML.DuplicateRuleHeader.allowSave = true;
                List<Database.SaveResult> sr = Database.insert(contactsToCreate.values(), dbDML);
                if(contactsToUpdate.size()>0){
                    List<Database.SaveResult> conupres = Database.update(contactsToUpdate, dbDML);
                }
                
                //insert contactsToCreate.values();
                
                for (Id caseId : contactsToCreate.keySet()) {
                    cs = caseIdCaseMap.get(caseId);
                    cs.ContactId = (contactsToCreate.get(caseId)).Id;
                    //  cs.setOptions(dmlOpts);
                    //    casesToUpdate.add(cs);
                }
            }
        }
    }
}