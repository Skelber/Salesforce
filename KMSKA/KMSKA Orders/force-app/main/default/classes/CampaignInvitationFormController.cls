public without sharing class CampaignInvitationFormController {
    @AuraEnabled(cacheable=true)
    public static Campaign getCampaign(String campId){
        List<Campaign> campaign = [SELECT Id, Name, RecordTypeId, Status, StartDate, EndDate, Start_Date_Time__c, Type_Invitation__c,
                                   Title_NL__c, Title_EN__c, Text_Subscription_NL__c, Text_Subscription_EN__c, 
                                   Confirmation_NL__c, Confirmation_EN__c, RSVP_Closed_NL__c, RSVP_Closed_EN__c, 
                                   Incorrect_Link_NL__c, Incorrect_Link_EN__c, Timeslot_Label_NL__c, Timeslot_Label_EN__c,
                                   Show_Availability_in_Picklist__c, Show_Availability_Picklist__c
                                   FROM Campaign
                                   WHERE Id =: campId];
        return campaign.size()>0 ? campaign[0] : null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getCampaignMember(String campId, String conId){
        Map<String,Object> response = new Map<String,Object>();
        try{
            List<Campaign> campaign = [SELECT Id, Name,StartDate,EndDate, Show_Availability_in_Picklist__c, Show_Availability_Picklist__c  FROM Campaign WHERE Id =: campId];
            
            List<CampaignMember> campMembers = [SELECT Id, CampaignId, ContactId, Amount_Of_Persons__c,Additional_Info__c,Status, 
                                                Selected_Timeslot__c, Subscribed_persons__c
                                                FROM CampaignMember
                                                WHERE CampaignId =: campId AND ContactId =: conId
                                               ];
            if(campMembers.size()>0){
                CampaignMember cm = campMembers[0];
                responseClass res = new responseClass();
                res.campMemberId = cm.Id;
                res.campId = cm.CampaignId;
                res.conId = cm.ContactId;
                
                res.showAvailabilityPicklist = campaign[0].Show_Availability_Picklist__c;
                res.showAvailabilityInPicklist = campaign[0].Show_Availability_in_Picklist__c;
                
                if(cm.status=='Aanwezig'){
                    res.registered = 'yes';
                }else if(cm.status=='Niet aanwezig'){
                    res.registered = 'no';
                }else{
                    res.registered = '';
                }
                
                if(cm.Amount_Of_Persons__c==null){
                    res.withOther = false;
                    res.noOfOthers = 0;
                    res.showOther = false;
                    res.otherPerson = new List<otherPersonInfo>();
                }else{
                    res.noOfOthers = (Integer.valueOf(cm.Amount_Of_Persons__c) - 1);
                    res.withOther = res.noOfOthers>0? true : false;
                    res.showOther = res.noOfOthers>0;
                    
                    if(cm.Additional_Info__c!=null){
                        List<String> addInfo = (cm.Additional_Info__c).split('\n');
                        List<otherPersonInfo> otherPersons = new List<otherPersonInfo>();
                        for(Integer i=0; i < addInfo.size(); i++){
                            otherPersonInfo op = new otherPersonInfo();
                            op.index = i;
                            op.Name =  (addInfo[i]);
                            otherPersons.add(op);
                        }
                        if(otherPersons.size() != res.noOfOthers && otherPersons.size() < res.noOfOthers){
                            otherPersons.addAll(getNewOtherPerson(res.noOfOthers - otherPersons.size(),  otherPersons.size()));
                        }
                        res.otherPerson = otherPersons;
                    }else{
                        res.withOther = false;
                        res.otherPerson =  getNewOtherPerson(res.noOfOthers,0);
                    }
                }
                res.mySelf = (cm.Subscribed_persons__c!=null && cm.Subscribed_persons__c == 1) ? true : false;
                res.timeSlotId = cm.Selected_Timeslot__c;
                res.extTimeSlotId = cm.Selected_Timeslot__c;
                res.extSubscribedPerson = Integer.valueOf(cm.Subscribed_persons__c);
                
                response.put('response',res);
                response.put('isActive', campaign[0].EndDate!=null?(campaign[0].EndDate>Date.today()?true:false) :true);
                response.put('isSuccess',true);
            }else{
                response.put('isSuccess',false);
                response.put('message','Campaign Member not found.');
            }
        }catch(Exception ex){
            response.put('isSuccess',false);
            response.put('message',ex.getMessage());
        }
        
        return response;
    }
    
    public static List<otherPersonInfo> getNewOtherPerson(Integer noOfPerson, Integer index){
        List<otherPersonInfo> otherPersons = new List<otherPersonInfo>();
        for(Integer i=0; i < noOfPerson; i++){
            otherPersonInfo op = new otherPersonInfo();
            op.index = index;
            op.Name = '';
            otherPersons.add(op);
            index++;
        }
        return otherPersons;
    }
    
    @AuraEnabled //(cacheable=true)
    public static List<Campaign_Timeslot__c> getTimeSlot(String campId){
        return [SELECT Id, Name, Active__c, Time__c, Max__c, Subscribed__c, Visible__c, Campaign__c, Remaining__c 
                FROM Campaign_Timeslot__c 
                WHERE Campaign__c =: campId AND Visible__c = true
               ];
    }
    
    @AuraEnabled
    public static Map<String,Object> saveResponse(responseClass response){
        Map<String,Object> res = new Map<String,Object>();
        try{
            CampaignMember cm = new CampaignMember();
            cm.Id = response.campMemberId;
            if(response.registered=='yes'){
                cm.Selected_Timeslot__c = response.timeSlotId;
                cm.Status = 'Aanwezig';
                String otherPersonsInfo = '';
                if(!response.mySelf){
                    Integer otherPerson = 0;
                    for(otherPersonInfo op : response.otherPerson){
                        String name = '';
                        if(op.Name!=null && op.Name!=''){
                            name = op.Name;
                            otherPerson++;
                        }
                        if(otherPersonsInfo!='') otherPersonsInfo+='\n';
                        if(name!='')otherPersonsInfo += name;
                    }
                    cm.Subscribed_persons__c = 1 + otherPerson; 
                }else{
                   cm.Subscribed_persons__c = 1; 
                }
                cm.Additional_Info__c = otherPersonsInfo;
            }else if(response.registered=='no'){
                cm.Status = 'Niet aanwezig';
                cm.Additional_Info__c = '';
                cm.Selected_Timeslot__c = null;
                cm.Subscribed_persons__c = 0;
            }
            
            if(response.showAvailabilityPicklist){
                if(response.timeSlotId != response.extTimeSlotId || response.extSubscribedPerson != cm.Subscribed_persons__c){
                    Map<String,Object> validation = validateTimeSlot(response.timeSlotId , Integer.valueOf(cm.Subscribed_persons__c));
                    if(!(Boolean) validation.get('isSuccess')){
                        return validation;
                    }
                }
            }
            
            update cm;
            
            if(response.timeSlotId!=null && response.timeSlotId!='')
                updateTimeSlot(response.timeSlotId);
            if(response.extTimeSlotId!=null && response.extTimeSlotId!='' && response.extTimeSlotId!=response.timeSlotId)
                updateTimeSlot(response.extTimeSlotId);
            
            res.put('isSuccess',true);
        }catch(Exception ex){
            res.put('isSuccess',false);
            res.put('message',ex.getMessage());
        }
        return res;
    }
    
    public static Map<String,Object> validateTimeSlot(String timeSlotId, Integer noOfPerson){
        Map<String,Object> res = new Map<String,Object>();
        Campaign_Timeslot__c CT = [SELECT Id, Remaining__c FROM Campaign_Timeslot__c WHERE Id =: timeSlotId];
        if(CT.Remaining__c >= noOfPerson){
            res.put('isSuccess',true);
        }else{
            res.put('isSuccess',false);
            res.put('person',CT.Remaining__c);
        }
        return res;
    }
    
    public static void updateTimeSlot(String timeSlotId){
        Campaign_Timeslot__c CT = new Campaign_Timeslot__c(Id = timeSlotId);
        Boolean isFound = false;
        
        for(AggregateResult  objAgr: [SELECT SUM(Subscribed_persons__c) total 
                                      from CampaignMember 
                                      where Selected_Timeslot__c =: timeSlotId 
                                      GROUP BY Selected_Timeslot__c])
        {
            CT.Subscribed__c = (Decimal)objAgr.get('total');
            isFound = true;
        }
        if(!isFound) CT.Subscribed__c = 0;       
        update CT;
    }
    
    public class responseClass{
        @AuraEnabled public Id campMemberId {get;set;}
        @AuraEnabled public Id campId {get;set;}
        @AuraEnabled public Id conId {get;set;}
        @AuraEnabled public String registered {get;set;}
        @AuraEnabled public Boolean withOther {get;set;}
        @AuraEnabled public Integer noOfOthers {get;set;}
        @AuraEnabled public Boolean showOther {get;set;}
        @AuraEnabled public Boolean mySelf {get;set;}
        @AuraEnabled public List<otherPersonInfo> otherPerson {get;set;}
        @AuraEnabled public String timeSlotId {get;set;}
        @AuraEnabled public String extTimeSlotId {get;set;}
        @AuraEnabled public Integer extSubscribedPerson {get;set;}
        @AuraEnabled public Boolean showAvailabilityPicklist {get;set;}
        @AuraEnabled public Boolean showAvailabilityInPicklist {get;set;}
    }
    
    Public class otherPersonInfo{
        @AuraEnabled public Integer index {get;set;}
        @AuraEnabled public String Name {get;set;}
    }
}