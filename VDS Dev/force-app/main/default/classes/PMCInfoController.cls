/**
 * Created by Tom Vanhouche on 29/04/2024.
 */

public with sharing class PMCInfoController {

    @AuraEnabled(Cacheable = true)
    public static List<PMCWrapper> getPMCInfo(Id accountId) {
        try {
            List<PMCWrapper> pmcList = new List<PMCWrapper>();
            List<PMC__c> activePMCs = [SELECT Id, Type__c, toLabel(Type__c) TypeLabel, Account__r.RecordType.DeveloperName FROM PMC__c WHERE Account__c = :accountId AND Inactive__c = FALSE AND Type__c != null ORDER BY Type__c ASC];

            // Fetch PMC Layout info for all active PMCs
            List<String> pmcTypes = new List<String>();
            for(PMC__c activePMC : activePMCs) {
                pmcTypes.add(activePMC.Type__c);
            }

            // Create a map PMCType-AccountCategory
            Map<String, List<PMC_Layout__c>> pmcLayoutMap = new Map<String, List<PMC_Layout__c>>();
            for (PMC_Layout__c pmcLayout : [SELECT PMC_Type__c, Account_Category__c, Section__c, Field_API_Name__c, Column__c, Order__c FROM PMC_Layout__c WHERE PMC_Type__c IN :pmcTypes WITH SYSTEM_MODE ORDER BY Section__c ASC]) {
                String layoutKey = pmcLayout.PMC_Type__c + '-' + (pmcLayout.Account_Category__c ?? 'All');
                if (!pmcLayoutMap.containsKey(layoutKey)) {
                    pmcLayoutMap.put(layoutKey, new List<PMC_Layout__c>());
                }

                List<PMC_Layout__c> pmcLayouts = pmcLayoutMap.get(layoutKey);
                pmcLayouts.add(pmcLayout);
            }

            // Create the layout
            for(PMC__c pmc : activePMCs) {
                String specificLayoutKey = pmc.Type__c + '-' + pmc.Account__r.RecordType.DeveloperName;
                String generalLayoutKey = pmc.Type__c + '-' + 'All';

                // If specific layout does not exist, then use the general All layout (meaning not bound to specific account category)
                List<PMC_Layout__c> pmcLayoutList = pmcLayoutMap.get(specificLayoutKey) ?? pmcLayoutMap.get(generalLayoutKey);
                PMCWrapper pmcWrapper = new PMCWrapper(pmc.Id, pmc.Type__c, (String)pmc.get('TypeLabel'));

                // If no layout exist, just add the PMC to the list without sections-columns-fields
                if (pmcLayoutList == null) {
                    pmcList.add(pmcWrapper);
                    continue;
                }

                // Else create the layout
                Map<String, Map<String, List<PMC_Layout__c>>> sectionMap = new Map<String, Map<String, List<PMC_Layout__c>>>();

                for(PMC_Layout__c pmcLayout : pmcLayoutList) {
                    // sections
                    if (!sectionMap.containsKey(pmcLayout.Section__c)) {
                        sectionMap.put(pmcLayout.Section__c, new Map<String, List<PMC_Layout__c>>());
                    }

                    // columns
                    Map<String, List<PMC_Layout__c>> columnMap = sectionMap.get(pmcLayout.Section__c);
                    String column = String.valueOf(pmcLayout.Column__c);
                    if (!columnMap.containsKey(column)) {
                        columnMap.put(column, new List<PMC_Layout__c>());
                    }

                    // fields
                    List<PMC_Layout__c> fields = columnMap.get(column);
                    fields.add(pmcLayout);
                }

                // convert the map into a list of sections with a list of columns with a list of fields -> lwc cannot iterate over a Map
                for(String section : sectionMap.keySet()) {
                    Section sectionWrapper = new Section(section);
                    Map<String, List<PMC_Layout__c>> columnMap = sectionMap.get(section);

                    for(String column : columnMap.keySet()) {
                        List<PMC_Layout__c> fields = columnMap.get(column);
                        fields.sort(new FieldComparator());
                        sectionWrapper.columns.add(fields);
                    }

                    pmcWrapper.sections.add(sectionWrapper);
                }

                pmcWrapper.sections.sort(new SectionComparator());
                pmcList.add(pmcWrapper);
            }

            User user = [SELECT Default_PMC__c FROM User WHERE Id = :System.UserInfo.getUserId()];
            pmcList.sort(new PMCComparator(user.Default_PMC__c));

            return pmcList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getStackTraceString());
        }
    }

    public class PMCWrapper {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<Section> sections = new List<PMCInfoController.Section>();

        public PMCWrapper(Id id, String type, String label) {
            this.id = id;
            this.type = type;
            this.label = label;
        }
    }

    public class Section {
        @AuraEnabled
        public String identifier;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<List<PMC_Layout__c>> columns = new List<List<PMC_Layout__c>>();

        public Section(String identifier) {
            this.identifier = identifier;
            this.label = System.Label.get('', identifier, UserInfo.getLanguage()) ?? '';
        }
    }

    public class PMCComparator implements Comparator<PMCWrapper> {
        private String defaultPMC;

        public PMCComparator(String defaultPMC) {
            this.defaultPMC = defaultPMC;
        }

        public Integer compare(PMCWrapper pmcA, PMCWrapper pmcB) {
            if (pmcA.type.equals(this.defaultPMC)) {
                return -1;
            } else if (pmcB.type.equals(this.defaultPMC)) {
                return 1;
            }
            return 0;
        }
    }

    public class FieldComparator implements Comparator<PMC_Layout__c> {
        public Integer compare(PMC_Layout__c fieldA, PMC_Layout__c fieldB) {
            Decimal orderA = fieldA.Order__c;
            Decimal orderB = fieldB.Order__c;
            return orderA < orderB ? -1 : 1;
        }
    }

    public class SectionComparator implements Comparator<Section> {
        public Integer compare(Section sectionA, Section sectionB) {
            if (sectionA.identifier.equalsIgnoreCase('General')) {
                return -1;
            } else if(sectionA.identifier.equalsIgnoreCase('E_Board') && !sectionB.identifier.equalsIgnoreCase('General')) {
                return -1;
            } else if(sectionA.identifier.equalsIgnoreCase('Financial') && (sectionB.identifier.equalsIgnoreCase('Financial') || sectionB.identifier.equalsIgnoreCase('Accountplan'))) {
                return -1;
            }
            return 1;
        }
    }
}