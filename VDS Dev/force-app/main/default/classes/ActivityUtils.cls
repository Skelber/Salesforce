public class ActivityUtils {
    
    /** Method which calls two methods to get all Events and Tasks of an object Id * 
     * @param recordId The Id of an Object * 
     * @return A list of ActivityWrapper which represents values used in LWC ActivityTable */
    @AuraEnabled(cacheable = true)
    public static List<ActivityWrapper> getActivities(String recordId){
        try {
            List<ActivityWrapper> activities = new List<ActivityWrapper>();
            //get all tasks and process
            List<Task> tasks = getAllTasks(recordId);
            if(tasks != null && !tasks.isEmpty()){
                List<String> taskIds = new List<String>();
                for (Task task : tasks) {
                    taskIds.add(task.Id);
                }
                Map<String, String> taskWithEmails = getEmailsOfTasks(taskIds);
                for (Task task : tasks) {
                    Boolean isEmail = task.TaskSubtype?.toLowerCase().equals('email');
                    System.debug('isEmail: '+ isEmail);
                    String taskWithEmail = taskWithEmails?.get(task.Id);
                    String activityId = isEmail != null && isEmail ? taskWithEmail : task.Id;
                    activities.add(convertTaskToActivityWrapper(task, activityId == null ? task.Id : activityId));
                }    
            }
            //get all events and process
            List<Event> events = getAllEvents(recordId);
            if(events != null && events.size() > 0){
                for (Event event : events) {
                    activities.add(convertEventToActivityWrapper(event));
                }
            }
            return activities;      
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /** Method which uses a SOQL method to get all Tasks of an object Id that is in WhatId or AccountId* 
     * @param recordId The Id of an Object * 
     * @return A list of Tasks */
    public static List<Task> getAllTasks(String recordId){
        List<Task> tasks = [SELECT Id, LastModifiedDate, ActivityDate, Subject, Activity_Type__c, Action_Case__c, Type, TaskSubtype, Status, Owner.Id, Owner.Name, WhatId, What.Name FROM Task WHERE AccountId = :recordId OR WhatId = :recordId ORDER BY ActivityDate DESC ALL ROWS];
        return !tasks.isEmpty() ? tasks : null;
    }

    /** Method which calls a utility method to get all Events of an object Id hat is in WhatId or AccountId* 
     * @param recordId The Id of an Object * 
     * @return A list of Events */
    public static List<Event> getAllEvents(String recordId){
        List<Event> events = [SELECT Id, LastModifiedDate, ActivityDate, Owner.Id, Owner.Name, Subject, Activity_Type__c, Action_Case__c, Type, What.Name, WhatId, EventSubtype FROM Event WHERE AccountId = :recordId OR WhatId = :recordId ORDER BY ActivityDate DESC ALL ROWS];
        return !events.isEmpty() ? events : null;
    }

    /** Method which calls the method getObjectFieldLabels of the Class Utils to get all translated labels of the fields an object* 
     * @param NONE * 
     * @return A list of Fieldwrapper which represent the name and label of all fields */
    @AuraEnabled(cacheable = true)
    public static List<FieldWrapper> getTaskFields(){
        Map<String, String> fieldsMap = Utils.getObjectFieldLabels('Task');
        List<FieldWrapper> fields = new List<FieldWrapper>();
        for(String fieldName : fieldsMap.keySet()){ 
            String fieldLabel = fieldsMap.get(fieldName);
            fields.add(createFieldWrapper(fieldName, fieldLabel));
        }
        return fields;
    }

    /** Method which gathers the emails related to the tasks of the emails*
     * @param List<String> list of task Ids of the e-mails
     * @return Map<String, String> which represents the task Id with the respective EmailMessage Id */
    public static Map<String, String> getEmailsOfTasks(List<String> tasks){
        List<EmailMessage> emails = [SELECT Id, ActivityId FROM EmailMessage WHERE ActivityId IN :tasks];
        Map<String, String> tasksWithEmails = new Map<String, String>();
        if(emails.isEmpty()){
            return null;
        }
        for(EmailMessage email : emails){
            tasksWithEmails.put(email.ActivityId, email.Id);
        }
        return tasksWithEmails;
    }

    /** Method which calls the Schema Class and methods to get all translated labels of the values of the picklist TaskSubtype* 
     * @param NONE * 
     * @return A Map<String, String> which represent the name (key) and label(value) of all picklist values */
    @AuraEnabled(cacheable = true)
    public static Map<String, String> getLabelsOfTaskSubtype(){
        Map<String, String> pickListValues = new Map<String, String>();
		Schema.DescribeFieldResult fieldResult = Task.TaskSubtype.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            pickListValues.put(pickListVal.getValue(), pickListVal.getLabel());
		}     
		return pickListValues;
    }

    /** Method which calls the Schema Class and methods to get all translated labels of the values of the picklist EventSubtype* 
     * @param NONE * 
     * @return A Map<String, String> which represent the name (key) and label(value) of all picklist values */
    @AuraEnabled(cacheable = true)
    public static Map<String, String> getLabelsOfEventSubtype(){
        Map<String, String> pickListValues = new Map<String, String>();
		Schema.DescribeFieldResult fieldResult = Event.EventSubtype.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            pickListValues.put(pickListVal.getValue(), pickListVal.getLabel());
		}     
		return pickListValues;
    }

    public class ActivityWrapper{
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public Date dateActivity {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String subject {get; set;}
        @AuraEnabled
        public String assignedTo {get; set;}
        @AuraEnabled
        public String assignedToId {get; set;}
        @AuraEnabled
        public String relatedTo {get; set;}
        @AuraEnabled
        public String relatedToId {get; set;}
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public String taskSubType {get; set;}
        @AuraEnabled
        public String eventSubType {get; set;}
        @AuraEnabled
        public String action {get; set;}
        @AuraEnabled
        public String actionCase {get; set;}


        //empty constructor needed to be able to be initialized in LWC
        public ActivityWrapper(){
        }
    }

    public class FieldWrapper{
        @AuraEnabled
        public String fieldName {get; set;}
        @AuraEnabled
        public String fieldLabel {get; set;}

        public FieldWrapper(String fieldName, String fieldLabel){
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
        }
        public FieldWrapper(){

        }
    }

    public static FieldWrapper createFieldWrapper(String fieldName, String fieldLabel){
        FieldWrapper field = new FieldWrapper();
        field.fieldName = fieldName;
        field.fieldLabel = fieldLabel;
        return field;
    }

    public static ActivityWrapper convertTaskToActivityWrapper(Task task, string emailId){
        ActivityWrapper activity = new ActivityWrapper();
        System.debug('emailId: ' + emailId);
        //activity.id = emailId != null ? emailId : task.Id; this was used to make the link 
        activity.id = task.Id;
        activity.dateActivity = task.ActivityDate != null ? task.ActivityDate : null; 
        PickListWrap pickListWrap = new PickListWrap();
        pickListWrap.objectApiName = 'Task';
        pickListWrap.fieldApiName = 'Status';
        pickListWrap.fieldValue = Task.Status;
        activity.status = GetPicklistValueLabel.getPicklistValueLabel(new List<PickListWrap>{pickListWrap})?.get(0);
        activity.subject = task.Subject;
        activity.assignedTo = task.Owner.Name;
        activity.assignedToId = task.Owner.Id;
        activity.action = task.Activity_Type__c;
        activity.relatedTo = task.What.Name;
        activity.relatedToId = task.WhatId;
        activity.taskSubType = task.TaskSubtype;
        activity.actionCase = task.Action_Case__c;
        return activity;
    }

    public static ActivityWrapper convertEventToActivityWrapper(Event event){
        ActivityWrapper activity = new ActivityWrapper();
        activity.id = event.Id;
        activity.dateActivity = event.ActivityDate != null ? event.ActivityDate : null;
        activity.subject = event.Subject;
        activity.assignedTo = event.Owner.Name;
        activity.assignedToId = event.Owner.Id;
        activity.action = event.Activity_Type__c;
        activity.relatedTo = event.What.Name;
        activity.relatedToId = event.WhatId; 
        activity.eventSubType = event.EventSubtype; 
        return activity;
    }
}