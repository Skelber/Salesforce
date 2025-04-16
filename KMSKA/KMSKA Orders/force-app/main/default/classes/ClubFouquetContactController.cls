public with sharing class ClubFouquetContactController {
    @AuraEnabled
    public static void createContact(String firstName, String lastName, String email, String recordId){
       Contact contact = new Contact();
       contact.FirstName = firstName;
       contact.lastName = lastName;
       contact.Email = email;
       contact.Club_Fouquet_Account__c = recordId;
       contact.Club_Fouquet_lid__c = true;
       insert contact;
    }

    @AuraEnabled(cacheable = true)
    public static List<SObject> getClubFouquetContacts(string recordId){
       return [SELECT Id, FirstName, LastName, AccountId, Email FROM Contact WHERE Club_Fouquet_Account__c = :recordId];
    }

    @AuraEnabled
    public static void addClubFouquetContact(String contactId, String accountId){
        Contact contact = [SELECT Id, FirstName, LastName, Email,Club_Fouquet_Account__c, Club_Fouquet_lid__c FROM Contact WHERE Id = :contactId];
        contact.Club_Fouquet_Account__c = accountId;
        contact.Club_Fouquet_lid__c = true;
        update contact;
    }
    
    @AuraEnabled
    public static void deleteClubFouquetInfo(String contactId){

        Contact contact = [SELECT Id, Club_Fouquet_Account__c, Club_Fouquet_lid__c  FROM Contact WHERE Id = :contactId];
        
        contact.Club_Fouquet_Account__c = null;
        contact.Club_Fouquet_lid__c = false;
        update contact;
    }
}