({ 
    getFormRec: function (cmp, event, helper) {
        var action = cmp.get("c.getform");
        action.setParams({
            LId : cmp.get('v.LeadId')
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set("v.Form", result);
                if(result.Motivation__c !='undefined' && result.Motivation__c !=null && result.Motivation__c !=''){
                    cmp.set("v.isSubmitted", true);
                }
            }
        });
        $A.enqueueAction(action);
    }, 
    
    getLeadRec: function (cmp, event, helper) {
        var action = cmp.get("c.getLead");
        action.setParams({
            LId : cmp.get('v.LeadId')
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set("v.Lead", result);
            }
        });
        $A.enqueueAction(action);
    }, 
    submitRecord: function(cmp,event) {
        var action = cmp.get("c.SaveRecord");
        action.setParams({
            formRec : cmp.get('v.Form'),
            LId :cmp.get('v.LeadId')
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
                this.showNotification(cmp, event, 'Something went wrong, please try after sometime.');
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