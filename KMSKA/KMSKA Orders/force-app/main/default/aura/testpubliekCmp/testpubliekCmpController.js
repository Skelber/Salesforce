({
    
    doInit: function (cmp, event, helper) {
        helper.fetchLead(cmp,event);
        helper.fetchForm(cmp,event);
        helper.fetchGender(cmp,event);
        helper.fetchCurrentSituation(cmp,event);
        helper.fetchStudyArea(cmp,event);
        helper.fetchWorkSector(cmp,event);
        helper.fetchVisitedKMSKA(cmp,event);
        helper.fetchVisitMusea(cmp,event);
        helper.fetchReasonNoVisit(cmp,event);
        helper.fetchContextVisit(cmp,event);
        helper.fetchInterest(cmp,event);
        helper.fetchReasonVisits(cmp,event);
        helper.fetchReasonToVisits(cmp,event);
        helper.fetchCampaignSource(cmp,event);
    },
    
    isSAOther: function(component, event, helper) {
        var getList = component.get("v.StudyArea");
        var getElementIndex = getList.indexOf('Andere');
        
        if(getElementIndex != -1){ 
            component.set("v.IsStudyAreaOther", true);
        }else{
            component.set("v.IsStudyAreaOther", false);
        }
    },
    
    isWSOther: function(component, event, helper) {
        var getList = component.get("v.WorkSector");
        var getElementIndex = getList.indexOf('Andere');
        
        if(getElementIndex != -1){ 
            component.set("v.IsWorkSectorOther", true);
        }else{
            component.set("v.IsWorkSectorOther", false);
        }
    },
    
    isPWSOther: function(component, event, helper) {
        var getList = component.get("v.PreferWorkSector");
        var getElementIndex = getList.indexOf('Andere');
        
        if(getElementIndex != -1){ 
            component.set("v.IsPreferWorkSectorOther", true);
        }else{
            component.set("v.IsPreferWorkSectorOther", false);
        }
    },
    
    
    isRNVOther: function(component, event, helper) {
        var getList = component.get("v.ReasonNoVisit");
        var getElementIndex = getList.indexOf('Andere');
        
        if(getElementIndex != -1){ 
            component.set("v.IsReasonNoVisitOther", true);
        }else{
            component.set("v.IsReasonNoVisitOther", false);
        }
    },
    
    isCVOther: function(component, event, helper) {
        var getList = component.get("v.ContextVisit");
        var getElementIndex = getList.indexOf('Andere');
        
        if(getElementIndex != -1){ 
            component.set("v.IsContextVisitOther", true);
        }else{
            component.set("v.IsContextVisitOther", false);
        }
    },
    
    isCSVOther: function(component, event, helper) {
        var getList = component.get("v.CampaignSource");
        var getElementIndex = getList.indexOf('Andere');
        
        if(getElementIndex != -1){ 
            component.set("v.IsCampaignSourceOther", true);
        }else{
            component.set("v.IsCampaignSourceOther", false);
        }
    },
    
    submit : function(component, event, helper) {
        var allValid = component.find('reqfield').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        if(allValid){
            var SA = component.get("v.StudyArea");
            var WS = component.get("v.WorkSector");
            var RNV = component.get("v.ReasonNoVisit");
            var CV = component.get("v.ContextVisit");
            var In = component.get("v.Interest");
            var RTV = component.get("v.ReasonToVisits");
            var CS = component.get("v.CampaignSource");
            
            
            var lead = component.get('v.Lead');
            var form = component.get('v.Form');
            
            form.Study_area__c 						= SA!=null?SA.join(';'):'';
            form.Work_Sector__c 					= WS!=null?WS.join(';'):'';
            form.Reason_no_visits__c 				= RNV!=null?RNV.join(';'):'';
            form.Context_Visits__c 					= CV!=null?CV.join(';'):'';
            form.interests__c 						= In!=null?In.join(';'):'';
            form.Reasons_To_Visit__c 				= RTV!=null?RTV.join(';'):'';
            form.Campaign_Source__c 				= CS!=null?CS.join(';'):'';
            
            console.log(component.get("v.Lead"));
            console.log(component.get("v.Form"));
            
            helper.submitRecord(component,event,lead,form);
            
        }else{
            component.set("v.Error", true);
            component.set("v.Errormessage", 'Het formulier is niet correct ingevuld, gelieve het formulier aan te passen.');
            helper.showNotification(component, event, 'Het formulier is niet correct ingevuld, gelieve het formulier aan te passen.');    
        }
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    },
})