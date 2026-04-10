public with sharing class AccountPMCSegmentationTableController {

    @AuraEnabled
    public static SegmentValue getSegmentValues(Id recordId){
        List<PMC__c> segmentValues = [SELECT Id, SUM_Interest__c, SUM_Potential__c, Segment__c FROM PMC__c WHERE Id = :recordId];

        SegmentValue segval = new SegmentValue();
        segval.segment = segmentValues[0].Segment__c;
        segval.sumInterest = segmentValues[0].SUM_Interest__c;
        segval.sumPotential = segmentValues[0].SUM_Potential__c;

        return segval;

    }

    @AuraEnabled
    public static List<Account_PMC_Segmentation__c> getAccountPMCSegmentations( Id recordId) {
        List<Account_PMC_Segmentation__c> segmentations = [SELECT Id,
                                                            Name, 
                                                            Topic__c, 
                                                            PMC_Account_Data__c,
                                                            Parameter_Value__c,
                                                            Parameter_Value__r.Name,
                                                            Segmentation_Parameter__c,
                                                            Segmentation_Parameter__r.Name,
                                                            Segmentation_Parameter__r.Weight_Parameter__c,
                                                            Weighted_Score__c,
                                                            LastModifiedDate
                                                            FROM Account_PMC_Segmentation__c 
                                                            WHERE PMC_Account_Data__c = :recordId ];
        return segmentations;
    }

    @AuraEnabled
    public static List<Parameter_Values__c> getParameterValues(){
        List<Parameter_Values__c> parameterValues = [SELECT Id, Name, Segmentation_Parameter__c, Score_10__c FROM Parameter_Values__c];
        return parameterValues;
    }

    @AuraEnabled
    public static void saveSegmentations(List<Account_PMC_Segmentation__c> segmentationsToSave) {
        if (segmentationsToSave == null || segmentationsToSave.isEmpty()) return;

        try {
            update segmentationsToSave;
        } catch (DmlException e) {
            throw new AuraHandledException('Error saving segmentations: ' + e.getMessage());
        }
    }

    public class SegmentValue {
        @AuraEnabled
        public String segment;
        @AuraEnabled
        public Double sumInterest;
        @AuraEnabled
        public Double sumPotential;
        
        
    }
}   