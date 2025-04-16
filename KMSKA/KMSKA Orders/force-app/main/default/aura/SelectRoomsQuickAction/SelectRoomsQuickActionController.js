({
    doInit: function(cmp, evt,helper){
        cmp.set('v.filterCondition','Opportunity__c=\''+cmp.get('v.recordId')+'\'');
        setTimeout(function () {
            helper.doInitHelper(cmp,evt);
        }, 1000);
    },
    
    afterScriptsLoaded : function(cmp, evt,helper) {
        cmp.set('v.filterCondition','Opportunity__c=\''+cmp.get('v.recordId')+'\'');
        helper.doInitHelper(cmp,evt);
    },
    
    handleSave : function(cmp, evt, helper) {
        var allValid = true;
        if (cmp.find('reqField').length > 0) {
            allValid = cmp.find('reqField').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
        }
        
        if (!allValid) {
            return;
        }else{
            helper.saveRecord(cmp,evt);
        }
    },
    
    closeModel : function(cmp, evt, helper) {
        cmp.set('v.isModalOpen',false);
    },
    
    doRefresh : function(cmp,evt,helper){
        //Remove Events
        $(cmp.find('calendar').getElement()).fullCalendar('removeEvents');
        
        //Refetch the Events
        helper.apexCallHandler(cmp,'getAssignedResources',{})
        .then(
            function(result){
                var oppId = cmp.get('v.recordId');
                var data = [];
                for(var i=0; i<result.length; i++){
                    var event = result[i];
                    var color = (event.KMSKA_Opportunity__c==oppId)? '#008000' : '#3788d8';
                    data.push({
                        id : event.Id,
                        title: event.Name + (' For : ' + event.KMSKA_Opportunity__r.Name),
                        resourceId : event.Resource__c,
                        start : event.Start_Activity_Product__c,
                        end:  event.End_Activity_Product__c,
                        color: color,
                        eventRec: event
                    });
                }
                $(cmp.find('calendar').getElement()).fullCalendar('addEventSource',data);
            }
        );
    },
})