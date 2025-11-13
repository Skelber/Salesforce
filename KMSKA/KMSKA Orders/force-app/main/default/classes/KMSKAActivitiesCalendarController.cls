public class KMSKAActivitiesCalendarController {
    @AuraEnabled
    public static Id getRecordTypeId(){
        Id KMSKAActivityRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KMSKA Activities').getRecordTypeId();
        return KMSKAActivityRecId;
    }
    
    @AuraEnabled
    public static Map<String, String> getTypeValues(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Type.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static Map<String, List<Vacation__c>> getVacations(){
        Map<String, List<Vacation__c>> vacationMap = new Map<String, List<Vacation__c>>();
        List<Vacation__c> vacations = [SELECT Id, Name, Start_date__c, End_date__c, Type__c, Calendar_Color__c FROM Vacation__c];
        for(Vacation__c vc : vacations){
            if(!vacationMap.containsKey(vc.Type__c)){
                List<Vacation__c> vcLst = new List<Vacation__c>();
                vacationMap.put(vc.Type__c, vcLst);
            }
            vacationMap.get(vc.Type__c).add(vc);
        }
        return vacationMap;
    }
    
    @AuraEnabled
    public static List<calendarData> getData(String calType, String oppType, Boolean isCommunity, String APtype, Date startDate, Date endDate){
        startDate = startDate.addDays(-1);
        endDate = endDate.addDays(1);
        
        List<calendarData> dataLst = new List<calendarData>();
        if(calType=='Opportunity'){
            Map<String,String> colors = getCalendarColors(calType);
            List<Opportunity> oppLst = getActivities(oppType,startDate,endDate);
            for(Opportunity opp: oppLst){
                calendarData data = new calendarData();
                data.recordId = opp.Id;
                data.createdBy = opp.CreatedBy.Name;
                data.title = opp.Name + (' For : ' + opp.Account.Name);
                data.startDatetime = opp.Start_Time__c;
                data.endDatetime = opp.End_Time__c;
                data.actualEndDatetime = opp.End_Time__c;
                data.name = opp.Name;
                data.parent = opp.Account.Name;
                data.eType = opp.Type;
                if(opp.StageName=='In optie'){
                    data.ebgColor = System.Label.In_optie_Opps_Calendar_Color;
                    data.eventTextColor = 'black';
                }else{
                    if(colors.containsKey(opp.Type)){
                        data.ebgColor = colors.get(opp.Type);
                    }else{
                        data.ebgColor = System.Label.Default_Activity_Calendar_Color;
                    }
                    data.eventTextColor = 'white';
                }
                
                data.participants = String.valueof(opp.Participants__c);
                data.isAllDay = (opp.All_Day_Event__c)?true:false;
                if(data.isAllDay){
                    data.endDatetime = (opp.End_Time__c).addDays(1);
                }
                
                
                if(opp.Planningen__r.size()>0){
                    String zaal = '';
                    for(Planning__c p : opp.Planningen__r){
                        if(p.Room__c != NULL){
                            zaal += p.Room__r.Name + ', ';
                        }
                    }
                    if(zaal != ''){
                        zaal = zaal.substring(0, zaal.length()-2);
                    }else{
                        zaal = 'Geen zaal geselecteerd';
                    }
                    data.zaal = zaal;
                }else{
                    data.zaal = 'Geen zaal geselecteerd';
                }
                
                dataLst.add(data);
            }
        }else{
            List<Activity_Product__c> products = getActivitieProducts(isCommunity,APtype,startDate,endDate);
            Map<String,String> colors = getCalendarColors('Opportunity');
            for(Activity_Product__c pro: products){
                calendarData data = new calendarData();
                data.recordId = pro.Id;
                data.createdBy = pro.CreatedBy.Name;
                if(isCommunity){
                    data.title = pro.Opportunity__r.Name;
                }else{
                    data.title = pro.Name + (' For : ' + pro.Opportunity__r.Name);
                }
                
                data.startDatetime = pro.Start_Time__c;
                data.endDatetime = pro.End_Time__c;
                data.actualEndDatetime = pro.End_Time__c;
                data.name = pro.Name;
                data.parent = pro.Opportunity__r.Name;
                data.oppAccount = pro.Opportunity__r.Account.Name;
                data.product = pro.KMSKA_Product__r.Name;
                
                if(pro.Assigned_Guide__c != null){
                    String guideName = pro.Assigned_Guide__c;
                    if(guideName.contains('</a>')){
                        guideName = guideName.substringBeforeLast('</a>');
                    }
                    if(guideName.contains('<a') && guideName.contains('>')){
                        guideName = guideName.substringAfterLast('>');
                    }
                    guideName = guideName.trim();
                    
                    data.guide = (guideName!=null && guideName!='') ? guideName : 'Geen gids toegekend.';
                }else{
                    data.guide = 'Geen gids toegekend.';
                }
                
                data.eType = '';
               // data.ebgColor = colors.get(pro.Opportunity__r.Type);
                 if(pro.Opportunity__r.StageName=='In optie'){
                    data.ebgColor = System.Label.In_optie_Opps_Calendar_Color;
                    data.eventTextColor = 'black';
                }else{
                    if(colors.containsKey(pro.Opportunity__r.Type)){
                        data.ebgColor = colors.get(pro.Opportunity__r.Type);
                    }else{
                        data.ebgColor = System.Label.Default_Activity_Calendar_Color;
                    }
                    data.eventTextColor = 'white';
                }
               // data.eventTextColor = 'white';
                data.participants = String.valueof(pro.Opportunity__r.Participants__c);
                data.isAllDay = false;
                dataLst.add(data);
            }
        }
        return dataLst;
    }
    
    @AuraEnabled
    public static List<Opportunity> getActivities(String oppType,Date startDate, Date endDate){
        List<Opportunity> opps = new List<Opportunity>();
        if(oppType!=null && oppType!=''){
            opps = [SELECT Id, Name, StageName, Amount, Probability, Type, RecordTypeId, RecordType.Name,
                    Account.Name,Start_Time__c, End_Time__c,Participants__c,All_Day_Event__c,CreatedBy.Name,
                    (SELECT Id, Name, Main_Stage__c, Room__c, Room__r.Name, KMSKA_Activity__c FROM Planningen__r WHERE Main_Stage__c = true)
                    FROM Opportunity
                    WHERE RecordType.Name='KMSKA Activities' AND Type =:oppType
                    AND StageName !='Aangekocht'
                    AND StageName !='Afgewezen' AND StageName !='Withdrawn'
                    AND StageName !='Geannuleerd' AND StageName !='Geweigerd'
                    AND (((Start_Time__c >= :startDate AND Start_Time__c <= :endDate) OR (End_Time__c >= :startDate AND End_Time__c <= :endDate)) 
                         OR (Start_Time__c <= :startDate AND End_Time__c >= :startDate AND Start_Time__c <= :endDate AND End_Time__c >= :endDate)
                        )
                   ];
        }else{
            opps = [SELECT Id, Name, StageName, Amount, Probability, Type, RecordTypeId, RecordType.Name,
                    Account.Name,Start_Time__c, End_Time__c,Participants__c,All_Day_Event__c,CreatedBy.Name,
                    (SELECT Id, Name, Main_Stage__c, Room__c, Room__r.Name, KMSKA_Activity__c FROM Planningen__r WHERE Main_Stage__c = true)
                    FROM Opportunity
                    WHERE RecordType.Name='KMSKA Activities'
                    AND StageName !='Aangekocht'
                    AND StageName !='Afgewezen' AND StageName !='Withdrawn'
                    AND StageName !='Geannuleerd' AND StageName !='Geweigerd'
                    AND (((Start_Time__c >= :startDate AND Start_Time__c <= :endDate) OR (End_Time__c >= :startDate AND End_Time__c <= :endDate)) 
                         OR (Start_Time__c <= :startDate AND End_Time__c >= :startDate AND Start_Time__c <= :endDate AND End_Time__c >= :endDate)
                        )
                   ];
        }
        
        return opps;
    }
    
    @AuraEnabled
    public static List<Activity_Product__c> getActivitieProducts(Boolean isCommunity,String APtype,Date startDate, Date endDate){
        List<Activity_Product__c> activityProducts = new List<Activity_Product__c>();
        if(isCommunity){
            if(APtype=='Alle'){
                activityProducts = [SELECT Id, Name, Opportunity__c, Opportunity__r.Name, KMSKA_Product__c, Assigned_Guide__c,Opportunity_Type__c,
                                    KMSKA_Product__r.Name, Start_Time__c, Opportunity__r.StageName, End_Time__c, Opportunity__r.Participants__c, Opportunity__r.Type,
                                    Availablility__c, Availablility__r.Guide__c,Availablility__r.Guide__r.FirstName,Availablility__r.Guide__r.LastName,
                                    Opportunity__r.Account.Name,CreatedBy.Name
                                    FROM Activity_Product__c
                                    WHERE Start_Time__c!=null AND End_Time__c!=null AND Status__c != 'Annulatie'
                                    AND (Type__c ='rondleiding' OR Type__c ='Atelier')
                                    AND (((Start_Time__c >= :startDate AND Start_Time__c <= :endDate) OR (End_Time__c >= :startDate AND End_Time__c <= :endDate)) 
                                         OR (Start_Time__c <= :startDate AND End_Time__c >= :startDate AND Start_Time__c <= :endDate AND End_Time__c >= :endDate)
                                        )
                                   ];
            }else{
                String APT = (APtype=='Rondleiding')?'rondleiding':'Atelier';
                if(APtype=='Groepsevents')APT = 'groepsevents';
                activityProducts = [SELECT Id, Name, Opportunity__c, Opportunity__r.Name, KMSKA_Product__c, Assigned_Guide__c, Opportunity__r.Type,
                                    KMSKA_Product__r.Name, Opportunity__r.StageName, Start_Time__c, End_Time__c, Opportunity__r.Participants__c,Opportunity_Type__c,
                                    Availablility__c, Availablility__r.Guide__c,Availablility__r.Guide__r.FirstName,Availablility__r.Guide__r.LastName,
                                    Opportunity__r.Account.Name,CreatedBy.Name
                                    FROM Activity_Product__c
                                    WHERE Start_Time__c!=null AND End_Time__c!=null AND Status__c != 'Annulatie'
                                    AND Type__c =: APT
                                    AND (((Start_Time__c >= :startDate AND Start_Time__c <= :endDate) OR (End_Time__c >= :startDate AND End_Time__c <= :endDate)) 
                                         OR (Start_Time__c <= :startDate AND End_Time__c >= :startDate AND Start_Time__c <= :endDate AND End_Time__c >= :endDate)
                                        )
                                   ];
            }
        }else{
            activityProducts = [SELECT Id, Name, Opportunity__c, Opportunity__r.Name, KMSKA_Product__c, Assigned_Guide__c,Opportunity__r.Type,
                                KMSKA_Product__r.Name, Opportunity__r.StageName, Start_Time__c, End_Time__c, Opportunity__r.Participants__c,
                                Availablility__c, Availablility__r.Guide__c,Availablility__r.Guide__r.FirstName,Availablility__r.Guide__r.LastName, Opportunity__r.Accountid,
                                Opportunity__r.Account.Name,CreatedBy.Name
                                FROM Activity_Product__c
                                WHERE Start_Time__c!=null AND End_Time__c!=null AND Status__c != 'Annulatie'
                                AND (((Start_Time__c >= :startDate AND Start_Time__c <= :endDate) OR (End_Time__c >= :startDate AND End_Time__c <= :endDate)) 
                                     OR (Start_Time__c <= :startDate AND End_Time__c >= :startDate AND Start_Time__c <= :endDate AND End_Time__c >= :endDate)
                                    )
                               ];
        }
        return activityProducts;
    }
    
    @AuraEnabled
    public static Map<String,String> getCalendarColors(String calType){
        If(calType == 'Activity product') calType = 'Opportunity';
        List<Calendar_Colour_Configuration__c> Calcolors = [SELECT Id, Name, Calendar__c, Type__c, Color__c 
                                                            FROM Calendar_Colour_Configuration__c
                                                            WHERE Calendar__c =: calType
                                                           ];
        
        Map<String,String> colors = new Map<String,String>();
        for(Calendar_Colour_Configuration__c ccc: Calcolors){
            colors.put(ccc.Type__c, ccc.Color__c);
        }
        return colors;
    }
    
    
    public class calendarData {
        @AuraEnabled public Id 			recordId 			{get;set;}
        @AuraEnabled public String 		title 				{get;set;}
        @AuraEnabled public DateTime 	startDatetime 		{get;set;}
        @AuraEnabled public DateTime 	endDatetime 		{get;set;}
        @AuraEnabled public String 		name 				{get;set;}
        @AuraEnabled public String 		parent 				{get;set;}
        @AuraEnabled public String 		eType 				{get;set;}
        @AuraEnabled public String 		ebgColor  			{get;set;}
        @AuraEnabled public String 		participants  		{get;set;}
        @AuraEnabled public String 		guide  				{get;set;}
        @AuraEnabled public String 		oppAccount  		{get;set;}
        @AuraEnabled public Boolean 	isAllDay	  		{get;set;}
        @AuraEnabled public String 		eventTextColor		{get;set;}
        @AuraEnabled public String 		createdBy 			{get;set;}
        @AuraEnabled public String 		zaal 				{get;set;}
        @AuraEnabled public DateTime 	actualEndDatetime 	{get;set;}
        @AuraEnabled public String   	product          	{get;set;}
    }
}