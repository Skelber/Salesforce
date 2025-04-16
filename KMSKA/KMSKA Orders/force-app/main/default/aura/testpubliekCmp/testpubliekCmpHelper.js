({
    submitRecord: function(cmp,event,lead,form) {
        var action = cmp.get("c.SaveRecord");
        action.setParams({
            leadRec : lead,
            formRec : form
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set("v.Error", false);
                cmp.set("v.Errormessage", '');
                cmp.set("v.recordAddded", true);
            }else{
                cmp.set("v.Error", true);
                cmp.set("v.Errormessage", 'Something went wrong, please try after sometime.');
                self.showNotification(cmp, event, 'Something went wrong, please try after sometime.');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchLead: function(cmp, event) {
        var action = cmp.get("c.getleadObj");
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set("v.Lead", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchForm: function(cmp, event) {
        var action = cmp.get("c.getformObj");
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set("v.Form", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchGender: function(cmp, event) {
        var action = cmp.get("c.getGender");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    ValMap.push({key: allValues[key], value:key});
                }
                cmp.set("v.GenderMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchCurrentSituation: function(cmp, event) {
        var action = cmp.get("c.getCurrentSituation");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    ValMap.push({key: allValues[key], value:key});
                }
                cmp.set("v.CurrentSituationMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchStudyArea: function(cmp, event) {
        var action = cmp.get("c.getStudyArea");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    //ValMap.push({key: allValues[key], value:key});
                    ValMap.push({label: allValues[key], value: key});
                }
                cmp.set("v.StudyAreaMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchWorkSector: function(cmp, event) {
        var action = cmp.get("c.getWorkSector");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    //ValMap.push({key: allValues[key], value:key});
                    ValMap.push({label: allValues[key], value: key});
                }
                cmp.set("v.WorkSectorMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
        
    fetchVisitedKMSKA: function(cmp, event) {
        var action = cmp.get("c.getVisitedKMSKA");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    ValMap.push({key: allValues[key], value:key});
                }
                cmp.set("v.VisitedKMSKAMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchVisitMusea: function(cmp, event) {
        var action = cmp.get("c.getVisitMusea");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    ValMap.push({key: allValues[key], value:key});
                }
                cmp.set("v.VisitMuseaMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchReasonNoVisit: function(cmp, event) {
        var action = cmp.get("c.getReasonNoVisit");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    //ValMap.push({key: allValues[key], value:key});
                    ValMap.push({label: allValues[key], value: key});
                }
                cmp.set("v.ReasonNoVisitMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchContextVisit : function(cmp, event) {
        var action = cmp.get("c.getContextVisit");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    //ValMap.push({key: allValues[key], value:key});
                    ValMap.push({label: allValues[key], value: key});
                }
                cmp.set("v.ContextVisitMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchInterest : function(cmp, event) {
        var action = cmp.get("c.getInterest");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    //ValMap.push({key: allValues[key], value:key});
                    ValMap.push({label: allValues[key], value: key});
                }
                cmp.set("v.InterestMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchReasonVisits : function(cmp, event) {
        var action = cmp.get("c.getReasonVisits");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    //ValMap.push({key: allValues[key], value:key});
                    ValMap.push({label: allValues[key], value: key});
                }
                cmp.set("v.ReasonVisitsMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchReasonToVisits : function(cmp, event) {
        var action = cmp.get("c.getReasonToVisits");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    //ValMap.push({key: allValues[key], value:key});
                    ValMap.push({label: allValues[key], value: key});
                }
                cmp.set("v.ReasonToVisitsMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchCampaignSource : function(cmp, event) {
        var action = cmp.get("c.getCampaignSource");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var ValMap = [];
                for(var key in allValues){
                    //ValMap.push({key: allValues[key], value:key});
                    ValMap.push({label: allValues[key], value: key});
                    
                }
                cmp.set("v.CampaignSourceMap", ValMap);
            }
        });
        $A.enqueueAction(action);
    },
    showNotification: function(cmp, event,msg){
        cmp.set("v.notificationmessage", msg);
        $A.util.removeClass(cmp.find('warningDiv'), 'slds-hide');
        window.setTimeout($A.getCallback(function() {
            $A.util.addClass(cmp.find('warningDiv'), 'slds-hide');
        }), 3000);
    },
    
})