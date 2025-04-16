({
    doInit: function(cmp, evt,helper){
        helper.doInitHelper(cmp,evt);
    },
    
    handleKeyUp: function (cmp, evt,helper) {
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            helper.handleResourcechange(cmp,evt);
        }
    },
    
    refreshCmp: function(cmp, evt,helper){
        cmp.set('v.newPlanning', {'sobjectType' : 'Planning__c'});
        cmp.set('v.current','1');
        cmp.set('v.hasError',false);
        cmp.set('v.isCalenderLoaded',false);
        cmp.set('v.recordMode','new');
        
        helper.doInitHelper(cmp,evt);   
    },
    
    editRecord: function(cmp, evt,helper){
        var recordId = evt.getSource().get('v.value');
        cmp.set('v.recordMode','edit');
        helper.getPlanning(cmp,evt,recordId)
        .then(function(result){
            cmp.set('v.isNewPlanningModalOpen',true);
        });
        
    },
    
    deleteRecord: function(cmp, evt,helper){
        var recordId = evt.getSource().get('v.value');
        var params = {'recordId' : recordId};
        return new Promise(
            function( resolve , reject ) {
                helper.apexCallHandler(cmp,'getPlanningRecord',params)
                .then(
                    function(result){
                        cmp.set('v.PlanToDelete', result);
                        cmp.set('v.isDeleteModelOpen',true);
                        resolve(result);
                    }
                );
            }
        );
    },
    
    handleDelete: function(cmp, evt,helper){
        var planRecord = cmp.get('v.PlanToDelete');
        var params = {'Planning' : planRecord};
        return new Promise(
            function( resolve , reject ) {
                helper.apexCallHandler(cmp,'deletePlanningRecord',params)
                .then(
                    function(result){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Planning Deleted successfully.",
                            "mode": "dismissible"
                        });
                        toastEvent.fire();
                        cmp.set('v.isDeleteModelOpen',false);
                        $A.get('e.force:refreshView').fire();
                        resolve(result);
                    }
                );
            }
        );
    },
    
    newRecord: function(cmp, evt,helper){
        var opp = cmp.get('v.Opportunity');
        var np = cmp.get('v.newPlanning');
        np.KMSKA_Activity__c  = cmp.get('v.recordId');
        if(opp.hasOwnProperty('Start_Time__c') && opp.Start_Time__c){
            np.Start__c = opp.Start_Time__c;
            np.End__c = opp.Start_Time__c;
        }else{
            np.Start__c = cmp.get('v.toDate');
            np.End__c = cmp.get('v.toDate');
        }
        
        cmp.set('v.newPlanning',np);
        cmp.set('v.isNewPlanningModalOpen',true);
    },
    
    nextStep: function(cmp, evt, helper) {
        var current = cmp.get('v.current');
        var next = current;
        if(current=='1'){
            var allValid = cmp.find('field').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if(allValid){
                var planningRecord = cmp.get('v.newPlanning');
                if(planningRecord.End__c!=undefined && planningRecord.End__c!=null){
                    cmp.set('v.roomSelectDisabled',false);
                    helper.calendarHandler(cmp,evt);
                }else{
                    cmp.set('v.roomSelectDisabled',true);
                }
                next = '2';
            }
        }
        cmp.set("v.current", next);
    },
    
    backStep: function(cmp, evt, helper) {
        var current = cmp.get('v.current');
        var next;
        if(current=='2'){
            next = '1';
        }
        cmp.set("v.current", next);
    },
    
    handleSave: function(cmp,evt,helper){
        helper.handleSaveHelper(cmp,evt);
    },
    
    closePModel: function(cmp, evt,helper){
        cmp.set('v.isNewPlanningModalOpen',false);
        $A.get('e.force:refreshView').fire();
    },
    
    closeDModel: function(cmp, evt,helper){
        cmp.set('v.isDeleteModelOpen',false);
        $A.get('e.force:refreshView').fire();
    }, 
})