({
    doInit: function (cmp, event, helper) {
        if(cmp.get('v.LeadId')!=null && cmp.get('v.LeadId')!=''){
            helper.getLeadRec(cmp, event, helper);
            helper.getFormRec(cmp, event, helper);
        }else{
            helper.showNotification(cmp, event, 'Invalid URL.');
            cmp.set('v.isInvalid',true);
        }
    }, 
    
    submit : function(component, event, helper) {
        var Rec = component.get('v.Form');

        var allValid = false;
        if(Rec.Motivation__c !=undefined && Rec.Motivation__c !=null && Rec.Motivation__c !=''){
            allValid = true;
        }
        
        if(allValid){
            var valLength = Rec.Motivation__c.split(' ').length;
            if(valLength<=50){
                helper.submitRecord(component,event);
            }else{
                component.set("v.Error", true);
                component.set("v.Errormessage", 'Maximum 50 woorden toegelaten, gelieve jouw motivatie aan te passen.');
                helper.showNotification(component, event, 'Maximum 50 woorden toegelaten, gelieve jouw motivatie aan te passen.');      
            }
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
    
    termsChangedSC : function(cmp, event, helper){
        cmp.set("v.agree",document.getElementById("termsSC").checked);
    }, 
})