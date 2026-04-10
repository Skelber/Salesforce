public class Utils {
    
    /** Method which calls a utility method to get all Picklist Values of a Field * 
     * @param objectAPIName The API Name of the Object which has the Picklist Field * 
     * @return A Map of picklist options key = name and value = label */
    public static Map<String, String> getObjectFieldLabels(String objectApiName){
        System.debug('objectApiName: ' + objectApiName);
        Map<String, String> fields = new Map<String, String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        for(String key : fieldMap.keySet()){
            System.debug(key);
            System.debug(fieldMap.get(key));
            fields.put(key, fieldMap.get(key).getDescribe().getLabel()) ;
        }
        return fields;
    }

    /** Method which calls a utility method to get the ObjectApiNames based on a list of recordIds* 
     * @param List<String> recordIds * 
     * @return List<String> objectApiNames */
    @InvocableMethod(label='getObjectApiNamesByRecordIds' description='Give a list of recordIds to receive a list of objectApiNames' category='Utils')
    public static List<String> getObjectApiNames(List<String> recordIds){
        List<String> objectApiNames = new List<String>();
        for(String recordId : recordIds){
            Id recordIdID = (Id) recordId;
            SObjectType objectType = recordIdID.getSObjectType();
            String objectApiName;
            if(objectType != null){
                objectApiName = objectType.getDescribe().getName();
                objectApiNames.add(objectApiName);
            }
        }
        return objectApiNames;
    }

    public static String retrieveLabelForField(String objectApiName, String fieldApiName){
        String objectName = objectApiName;
        String fieldName = fieldApiName;

        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (objectType != null) {
            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
            Schema.SObjectField field = objectDescribe.fields.getMap().get(fieldName);
            
            if (field != null) {
                return field.getDescribe().getLabel();
            } else {
                Logger logInstance = new Logger();
                logInstance.addFunctionName('Utils')
                        .addMethod('retrieveLabelForField')
                        .addSourceType(Logger.LOG_SOURCETYPE_APEX)
                        .addMessage('Something went wrong with getting the fieldLabel')
                        .fire();
            }
        } else {
            Logger logInstance = new Logger();
                logInstance.addFunctionName('Utils')
                        .addMethod('retrieveLabelForField')
                        .addSourceType(Logger.LOG_SOURCETYPE_APEX)
                        .addMessage('Something went wrong with getting the object')
                        .fire();
        }
        return null;
    }

    public static List<Schema.PicklistEntry> getPicklistValues(String objectName, String fieldName) {
        Map<String, SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        Schema.SObjectField field = fieldMap.get(fieldName);

        if (field != null) {
            return field.getDescribe().getPicklistValues();
        }
        return null;
    }

    public static String getPickListLabel(List<Schema.PicklistEntry> picklistEntries, String apiName) {
		for(Schema.PicklistEntry entry : picklistEntries) {
			if (entry.getValue() == apiName) {
				return entry.getLabel();
			}
		}
		return null;
	}

    public static String addWhereOrAddIfNeeded(String query){
        if(query.containsIgnoreCase('WHERE')){
            return query += ' AND ';
        } else {
            return query += 'WHERE ';
        }
    }

    
    public static String getFieldDataType(String objectApiName, String fieldName) {
        return String.valueOf(Schema.getGlobalDescribe()
            .get(objectApiName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldName)
            .getDescribe()
            .getType()
        );
    }

    @AuraEnabled
    public static List<FieldWrapObjectAndField> getFieldDataTypes(List<FieldWrapObjectAndField> fieldwraps){
        List<FieldWrapObjectAndField> fields = new List<FieldWrapObjectAndField>();
        for (FieldWrapObjectAndField field : fieldwraps) {
            fields.add(field);
            field.fieldType = getFieldDataType(field.objectApiName, field.fieldApiName);
        }
        return fields;
    }

    public static RecordType getRecordType(String objectType, String recordTypeName) {
        return [SELECT Id, name FROM RecordType WHERE sObjectType = :objectType AND DeveloperName = :recordTypeName];
    }

    public static String getObjectPluralLabel(String sObjectType) {
        return Schema.getGlobalDescribe().get(sObjectType).getDescribe().labelPlural;
    }
}