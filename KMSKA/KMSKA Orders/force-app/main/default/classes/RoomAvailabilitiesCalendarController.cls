public class RoomAvailabilitiesCalendarController {
    
    @AuraEnabled
    public static Boolean isLoggedUserGuide(){
        User u = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()]; 
        if(u.Profile.Name=='Gidsen'){
            return true;
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static Map<String,String> getAllRooms(){
        Map<String, String> options = new Map<String, String>();
        
        List<Room__c> resources = [SELECT Id, Name FROM Room__c];
        for(Room__c room: resources){
            options.put(room.Id, room.Name);
        }
        return options;
    }
    
    @AuraEnabled
    public static List<calendarData> getData(String selRoom){
        List<calendarData> dataLst = new List<calendarData>();
        
        List<Planning__c> planLst = getPlannings(selRoom);
        Map<String,String> colors = getCalendarColors();
        
        for(Planning__c plan: planLst){
            calendarData data 	= new calendarData();
            data.recordId 		= plan.Id;
            data.title 			= plan.Room__r.Name +' - '+plan.KMSKA_Activity__r.Name + '(' + plan.Name +')';
            data.startDatetime 	= plan.Start__c;
            data.endDatetime 	= plan.End__c;
            data.name 			= plan.Name;
            data.parent 		= plan.KMSKA_Activity__r.Name;
            data.oppName		= plan.KMSKA_Activity__r.Name;
            data.accName		= plan.KMSKA_Activity__r.Account.Name;
            data.conName		= plan.KMSKA_Activity__r.npsp__Primary_Contact__r.Name;
            data.roomName		= plan.Room__r.Name;
            data.Participants	= plan.KMSKA_Activity__r.Participants__c;
            
            if(colors.containsKey(plan.Room__r.Name)){
                data.ebgColor = colors.get(plan.Room__r.Name);
            }else{
                data.ebgColor = System.Label.Default_Activity_Calendar_Color;
            }
            data.eventTextColor = 'white';
            dataLst.add(data);
        }
        return dataLst;
    }
    
    @AuraEnabled
    public static List<Planning__c> getPlannings(String roomId){
        List<Planning__c> plannings = new List<Planning__c>();
        
        if(roomId.toLowerCase()=='all'){
            plannings = [SELECT Id, Name, End__c, Start__c, Type__c,Description__c, 
                         Room__c, Room__r.Name,KMSKA_Activity__c,KMSKA_Activity__r.Name,KMSKA_Activity__r.StageName,
                         KMSKA_Activity__r.Account.Name, KMSKA_Activity__r.npsp__Primary_Contact__r.Name,
                         KMSKA_Activity__r.Participants__c
                         FROM Planning__c
                         WHERE Room__c!=null
                        ];
        }else if(roomId.length()==15 || roomId.length() ==18){
            plannings = [SELECT Id, Name, End__c, Start__c, Type__c,Description__c, 
                         Room__c, Room__r.Name,KMSKA_Activity__c,KMSKA_Activity__r.Name,KMSKA_Activity__r.StageName, 
                         KMSKA_Activity__r.Account.Name, KMSKA_Activity__r.npsp__Primary_Contact__r.Name,
                         KMSKA_Activity__r.Participants__c
                         FROM Planning__c
                         WHERE Room__c =: roomId 
                        ];
        }
        return plannings;
    }
    
    @AuraEnabled
    public static Map<String,String> getCalendarColors(){
        List<Calendar_Colour_Configuration__c> Calcolors = [SELECT Id, Name, Calendar__c, Type__c, Color__c 
                                                            FROM Calendar_Colour_Configuration__c
                                                            WHERE Calendar__c = 'Room'
                                                           ];
        
        Map<String,String> colors = new Map<String,String>();
        for(Calendar_Colour_Configuration__c ccc: Calcolors){
            colors.put(ccc.Type__c, ccc.Color__c);
        }
        return colors;
    }
    
    public class calendarData {
        @AuraEnabled public Id 			recordId 		{get;set;}
        @AuraEnabled public String 		title 			{get;set;}
        @AuraEnabled public DateTime 	startDatetime 	{get;set;}
        @AuraEnabled public DateTime 	endDatetime 	{get;set;}
        @AuraEnabled public String 		name 			{get;set;}
        @AuraEnabled public String 		parent 			{get;set;}
        @AuraEnabled public String 		ebgColor  		{get;set;}
        @AuraEnabled public String 		oppName  		{get;set;}
        @AuraEnabled public String 		accName  		{get;set;}
        @AuraEnabled public String 		conName  		{get;set;}
        @AuraEnabled public String		roomName		{get;set;}
        @AuraEnabled public Decimal 	Participants  	{get;set;}
        @AuraEnabled public String 		eventTextColor	{get;set;}
    }
}