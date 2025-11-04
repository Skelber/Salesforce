public with sharing class ShowroomVisitCreationHelper {

    @AuraEnabled
    public static ContactDetailsWrapper getContactDetails(Id visitReportId) {
        try {
            Visit_Report__c visitReport = [SELECT Contact__c, Contact__r.Name, Contact__r.MailingStreet, Contact__r.MailingPostalCode, Contact__r.MailingCity, Contact__r.MailingCountryCode, Contact__r.AccountId, 
                                           Contact__r.Account.Client_Number__c, Contact__r.Account.Name, Lead__c, Lead__r.Name FROM Visit_Report__c WHERE Id = :visitReportId];

            ContactDetailsWrapper contactDetailsWrapper = new contactDetailsWrapper();

            if (String.isNotBlank(visitReport.Contact__c)) {
                contactDetailsWrapper.selectedContact = LookupSearchResult.fromContact(visitReport.Contact__c, visitReport.Contact__r.Name, visitReport.Contact__r.Account.Name); 
                contactDetailsWrapper.selectedAccount = LookupSearchResult.fromAccount(visitReport.Contact__r.AccountId, visitReport.Contact__r.Account.Name + ' (' + visitReport.Contact__r.Account.Client_Number__c + ')', '');
                contactDetailsWrapper.selectedAddress = new AddressWrapper(visitReport.Contact__r.MailingStreet, visitReport.Contact__r.MailingPostalCode, visitReport.Contact__r.MailingCity, visitReport.Contact__r.MailingCountryCode);
            } else if (String.isNotBlank(visitReport.Lead__c)) {
                contactDetailsWrapper.selectedLead = LookupSearchResult.fromLead(visitReport.Lead__c, visitReport.Lead__r.Name, '');
            }

            return contactDetailsWrapper;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchContactAndLeads(String searchTerm){
        try {
            searchTerm += '*';
            List<List<SObject>> searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    Contact(Id, Name, Account.Name, Inactive__c),
                    Lead(Id, Name)
                LIMIT 10
            ];

            List<LookupSearchResult> results = new List<LookupSearchResult>();
            
            Contact[] contacts = (List<Contact>) searchResults[0];
            for (Contact contact : contacts) {
                if (!contact.Inactive__c) {
                    results.add(LookupSearchResult.fromContact(contact.Id, contact.Name, contact.Account.Name));
                }
            }

            Lead[] leads = (List<Lead>) searchResults[1];
            for (Lead lead : leads) {
                results.add(LookupSearchResult.fromLead(lead.Id, lead.Name, ''));
            }

            return results;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchAccounts(String searchTerm){
        try {
            searchTerm = '%' + searchTerm + '%';
            List<LookupSearchResult> searchResults = new List<LookupSearchResult>();
            for (Account account : [SELECT Id, Name, Client_Number__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry 
                        FROM Account WHERE Name LIKE :searchTerm OR Client_Number__c LIKE :searchTerm OR BillingStreet LIKE :searchTerm OR BillingCity LIKE :searchTerm
                        OR BillingPostalCode LIKE :searchTerm
                        ORDER BY Name]) {
                String title = account.Name + ' (' + account.Client_Number__c + ')';
                String subTitle = account.BillingStreet + ', ' + account.BillingPostalCode + ' ' + account.BillingCity + ' ' + account.BillingCountry;
                LookupSearchResult searchResult = LookupSearchResult.fromAccount(account.Id, title, subTitle);
                searchResults.add(searchResult);
            }
            return searchResults;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ProjectVisitWrapper> getProjectVisits(Id visitReportId) {
        try {
            List<ProjectVisitWrapper> projectVisits = new List<ShowroomVisitCreationHelper.ProjectVisitWrapper>();
            
            for(Project_Visit__c projectVisit : [SELECT Id, Project__c, Project__r.Name FROM Project_Visit__c WHERE Visit_Report__c = :visitReportId]) {
                projectVisits.add(new ProjectVisitWrapper(projectVisit.Id, projectVisit.Project__c, projectVisit.Project__r.Name));
            }

            return projectVisits;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ProjectProductWrapper> getProjectDetails(Id projectVisitId){
        try {
            List<ProjectProductWrapper> productsList = new List<ProjectProductWrapper>();
            List<Sample_Collection_Line__c> sampleCollectionLines = [SELECT Product__c, Sample_Collection__r.Project_Visit__c FROM Sample_Collection_Line__c WHERE Sample_Collection__c IN (SELECT Id FROM Sample_Collection__c WHERE Project_Visit__c = :projectVisitId)];

            for (OpportunityLineItem lineItem : [SELECT Id, Product2Id, Product_description__c, Amount_m__c FROM OpportunityLineItem WHERE OpportunityId IN (SELECT Project__c FROM Project_Visit__c WHERE Id = :projectVisitId)]) {
                Boolean sampleProvided = false;
                for (Sample_Collection_Line__c sampleCollectionLine : sampleCollectionLines) {
                    if (sampleCollectionLine.Product__c == lineItem.Product2Id) {
                        sampleProvided = true;
                        break;
                    }
                }

                productsList.add(new ProjectProductWrapper(lineItem.Id, lineItem.Product2Id, lineItem.Product_description__c, lineItem.Amount_m__c, sampleProvided));
            }

            return productsList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<Map<String, String>> getCountryOptions(){
        try {
            List<Schema.PicklistEntry> values = Contact.MailingCountryCode.getDescribe().getPickListValues();
            List<Map<String, String>> options = new List<Map<String, String>>();
            for (Schema.PicklistEntry v : values) {
                options.add(new Map<String, String>{
                    'label' => v.label,
                    'value' => v.value
                });
            }
            return options;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchProjects(Id visitReportId, String searchTerm, List<String> selectedIds){
        try {
            searchTerm = '%' + searchTerm + '%';
            Visit_Report__c visitReport = [SELECT Contact__c, Contact__r.AccountId FROM Visit_Report__c WHERE Id = :visitReportId];

            List<LookupSearchResult> searchResults = new List<LookupSearchResult>();
            for (Opportunity project : [SELECT Id, Name, projectnr__c, Project_Address__Street__s, Project_Address__PostalCode__s, Project_Address__City__s, PMC__c, Account.Name, Follow_Up_Date__c 
                        FROM Opportunity WHERE
                            (Name LIKE :searchTerm OR projectnr__c LIKE :searchTerm OR Project_Address__Street__s LIKE :searchTerm OR Project_Address__City__s LIKE :searchTerm OR Project_Address__PostalCode__s LIKE :searchTerm)
                            AND Id NOT IN :selectedIds 
                            /*AND Id IN (SELECT VDSProject_Ref__c
						            FROM Project_Relation__c
                                    WHERE
                                        (Account_Ref__c = :visitReport.Contact__r.AccountId OR Contact_Ref__c = :visitReport.Contact__c)
                                        AND VDSProject_Ref__c != NULL
                                ) */
                        ORDER BY Name]) {
                String subTitle = project.Project_Address__Street__s + ', ' + project.Project_Address__PostalCode__s + ' ' + project.Project_Address__City__s;
                LookupSearchResult searchResult = LookupSearchResult.fromProject(project.Id, project.Name + ' - ' + project.projectnr__c, subTitle);
                searchResults.add(searchResult);
            }
            return searchResults;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchProducts(String searchTerm){
        try {
            searchTerm += '*';
            List<List<SObject>> searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    Product2(Id, Name, Description__c, Size__c, Colour_Description__c ORDER BY Description__c ASC)
                LIMIT 20
            ];

            List<LookupSearchResult> lookupResults = new List<LookupSearchResult>();
            
            for (Product2 product : (List<Product2>) searchResults[0]) {
                String subTitle = product.Description__c;
                if (String.isNotBlank(product.Size__c)) {
                    subTitle += ' ' + product.Size__c;
                }
                if (String.isNotBlank(product.Colour_Description__c)) {
                    subTitle += ' ' + product.Colour_Description__c;
                }
                LookupSearchResult lookupResult = LookupSearchResult.fromProduct(product.Id, product.Name, subTitle);
                lookupResults.add(lookupResult);
            }
            return lookupResults;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ProjectProductWrapper addProductToProject(Id projectId, Id productId){
        try {
            List<OpportunityLineItem> existing = [SELECT Id, Product2Id, Product_description__c, Amount_m__c FROM OpportunityLineItem WHERE Product2Id = :productId AND OpportunityId = :projectId LIMIT 1];
            if (existing.size() == 1) {
                OpportunityLineItem lineItem = existing.get(0);
                return new ProjectProductWrapper(lineItem.Id, lineItem.Product2Id, lineItem.Product_description__c, lineItem.Amount_m__c, false);
            }

            // Check if opportunity already has a pricebook linked to it
            Product2 product = [SELECT Description__c FROM Product2 WHERE  Id = :productId];
            Opportunity project = [SELECT Pricebook2Id, CurrencyIsoCode FROM Opportunity WHERE Id = :projectId];
            PricebookEntry pbEntry= [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE Product2Id = :productId AND CurrencyIsoCode = :project.CurrencyIsoCode LIMIT 1];
            if (String.isBlank(project.Pricebook2Id)) {
                project.Pricebook2Id = pbEntry.Pricebook2Id;                
                update project;
            }
            OpportunityLineItem line = new OpportunityLineItem(
                OpportunityId = projectId,
                Product2Id = productId,
                Quantity = 1,
                Amount_m__c = 1,
                TotalPrice = 0,
                PricebookEntryId = pbEntry.Id
            );
            insert line;
            return new ProjectProductWrapper(line.Id, productId, product.Description__c, line.Amount_m__c, false);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void removeLineItem(Id lineItemId) {
        try {
            OpportunityLineItem lineItem = [SELECT Id, OpportunityId, Product2Id FROM OpportunityLineItem WHERE Id = :lineItemId];
            // TODO delete sample?

            delete lineItem;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateLineItem(Id projectVisitId, Id lineItemId, Boolean sampleProvided){
        try {
            Project_Visit__c projectVisit = [SELECT Project__c FROM Project_Visit__c WHERE Id = :projectVisitId];
            OpportunityLineItem lineItem = [SELECT Id, Amount_m__c, Product2Id FROM OpportunityLineItem WHERE Id = :lineItemId];

            List<Sample_Collection__c> sampleCollections = [SELECT Id FROM Sample_Collection__c WHERE Project_Visit__c = :projectVisitId LIMIT 1];
            Sample_Collection__c sampleCollection = sampleCollections.size() == 1 ? sampleCollections.get(0) : null;
            if (sampleCollection == null && sampleProvided) {
                sampleCollection = new Sample_Collection__c(Project_Visit__c = projectVisitId, Project__c = projectVisit.Project__c, SampleCollectionId_ext__c = UUID.randomUUID().toString().left(10));
                insert sampleCollection;
            }

            List<Sample_Collection_Line__c> sampleCollectionLines = [SELECT Id FROM Sample_Collection_Line__c WHERE Sample_Collection__c = :sampleCollection.Id AND Product__c = :lineItem.Product2Id LIMIT 1];
            Sample_Collection_Line__c sampleCollectionLine = sampleCollectionLines.size() == 1 ? sampleCollectionLines.get(0) : null;
            if (sampleCollectionLine != null && sampleProvided != null && !sampleProvided) {
                delete sampleCollectionLine;
            } else if (sampleCollectionLine == null && sampleProvided != null && sampleProvided) {
                sampleCollectionLine = new Sample_Collection_Line__c(
                    Sample_Collection__c = sampleCollection.Id,
                    Product__c = lineItem.Product2Id,
                    SampleCollectionLineId_ext__c = UUID.randomUUID().toString().left(16)
                );
                insert sampleCollectionLine;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class ProjectVisitWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public Id projectId;
        @AuraEnabled public String projectName;
        
        public ProjectVisitWrapper(Id id, Id projectId, String projectName) {
            this.id = id;
            this.projectId = projectId;
            this.projectName = projectName;
        }
    }

    public class ProjectProductWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public Id productId;
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal amountM2;
        @AuraEnabled public Boolean sampleProvided;

        public ProjectProductWrapper(Id id, Id productId, String productName, Decimal amountM2, Boolean sampleProvided) {
            this.id = id;
            this.productId = productId;
            this.productName = productName;
            this.amountM2 = amountM2;
            this.sampleProvided = sampleProvided;
        }
    }

    public class ContactDetailsWrapper {
        @AuraEnabled public LookupSearchResult selectedContact;
        @AuraEnabled public LookupSearchResult selectedLead;
        @AuraEnabled public LookupSearchResult selectedAccount;
        @AuraEnabled public AddressWrapper selectedAddress; 
    }

    public class AddressWrapper {
        @AuraEnabled public String street;
        @AuraEnabled public String postalCode;
        @AuraEnabled public String city;
        @AuraEnabled public String countryCode;

        public AddressWrapper(String street, String postalCode, String city, String countryCode) {
            this.street = street;
            this.postalCode = postalCode;
            this.city = city;
            this.countryCode = countryCode;
        }
    }
}