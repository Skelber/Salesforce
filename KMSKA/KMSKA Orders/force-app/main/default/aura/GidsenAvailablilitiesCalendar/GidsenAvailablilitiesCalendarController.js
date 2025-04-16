({
    afterScriptsLoaded : function(cmp, evt,helper) {
        cmp.set('v.filterCondition','Profile.Name=\'Gidsen\'');
        
        var params = {};
        helper.apexCallHandler(cmp,'isLoggedUserGuide',params)
        .then(
            function(result){
                cmp.set('v.isLUGuide',result);
                if(result==true){
                    cmp.set('v.availability.Guide__c', $A.get("$SObjectType.CurrentUser.Id"));
                    cmp.set('v.guide',$A.get("$SObjectType.CurrentUser.Id"));
                }
                
                helper.loadData(cmp,evt)
                .then(function(result){
                    helper.drawCalendar(cmp,evt);
                    helper.getGuideValue(cmp,evt);
                    helper.getDoelgroepValue(cmp,evt);
                    helper.getTaalValue(cmp,evt);
                    helper.getRecTypeValue(cmp,evt);
                }); 
            }
        );
    },
    
    onFilterChange: function(cmp, evt,helper) {
        helper.handleDatachange(cmp,evt);    
    },
    
    newAvailability: function(cmp, evt,helper) {
        if(cmp.get('v.isLUGuide')){
           cmp.set('v.availability.Guide__c', $A.get("$SObjectType.CurrentUser.Id")); 
        }
        cmp.set('v.isNewRecord',true);
        cmp.set('v.isRecurring',false);
    },
    
    closeModel: function(cmp, evt,helper) {
        cmp.set('v.availability',{});
        cmp.set('v.isNewRecord',false);
        cmp.set('v.isRecurring', false);
        cmp.set('v.editError', false);
        cmp.set('v.errorMessage', '');
    },
    
    closeEditModel: function(cmp, evt,helper) {
        cmp.set('v.isUpdateRecord',false);
        cmp.set('v.isRecurring', false);
        cmp.set('v.editError', false);
        cmp.set('v.errorMessage', '');
    },
    
    closeDeleteModel: function(cmp, evt,helper) {
        cmp.set('v.isDeleteRecurring',false);
        cmp.set('v.isRecurring', false);
        cmp.set('v.editError', false);
        cmp.set('v.errorMessage', '');
    },
    
    handleDelete :  function(cmp, evt,helper) {
        var record = cmp.get('v.EditAvailability');
        if(record.RecordType.Name=='Recurring'){
            if(record.Parent__c){
                cmp.set('v.isParentRecurring',true);
            }else{
                cmp.set('v.isParentRecurring',false);
            }
            cmp.set('v.isUpdateRecord',false);
            cmp.set('v.isDeleteRecurring',true);
        }else{
            helper.deleteRecord(cmp,evt);
        }
    },
    
    handleDeleteAllRecurring: function(cmp, evt,helper) {
        helper.deleteRecurring(cmp,evt,'all');
    },
    
    handleDeleteRecurring: function(cmp, evt,helper) {
        helper.deleteRecurring(cmp,evt,'single');
    },
    
    handleUpdate :  function(cmp, evt,helper) {
        var isRecurring = cmp.get('v.isRecurring');
        var allValid = true;
        if (cmp.find('reqField').length > 0) {
            allValid = cmp.find('reqField').reduce(function (validSoFar, inputCmp) {
                if(inputCmp.get('v.label')=='Einde Herhaling'){
                    var validDate = true;
                    if(!isRecurring){
                        return validSoFar && validDate;
                    }else{
                        if(inputCmp.get('v.value')==undefined || inputCmp.get('v.value') ==null || inputCmp.get('v.value') ==''){
                            validDate = false;
                        }
                        return validSoFar && validDate;
                    }
                }else{
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }
            }, true);
        }
        
        if (!allValid) {
            return;
        }else{
            helper.updateRecord(cmp,evt);
        }
    },
    
    handleSave: function(cmp, evt,helper) {
        var isRecurring = cmp.get('v.isRecurring');
        var allValid = true;
        if (cmp.find('reqField').length > 0) {
            allValid = cmp.find('reqField').reduce(function (validSoFar, inputCmp) {
                if(inputCmp.get('v.label')=='Einde Herhaling'){
                    var validDate = true;
                    if(!isRecurring){
                        return validSoFar && validDate;
                    }else{
                        if(inputCmp.get('v.value')==undefined || inputCmp.get('v.value') ==null || inputCmp.get('v.value') ==''){
                            validDate = false;
                        }
                        return validSoFar && validDate;
                    }
                }else{
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }
            }, true);
        }
        
        if (!allValid) {
            return;
        }else{
            var availability = cmp.get('v.availability');
            var isRecurring = cmp.get('v.isRecurring');
            if(isRecurring){
                availability.RecordTypeId = cmp.get('v.recurringRecordTypeId');
            }else{
                availability.RecordTypeId = cmp.get('v.singleRecordTypeId'); 
            }
            cmp.set('v.availability',availability);
            helper.saveRecord(cmp,evt);
        }
    },
    
    /*Calendar's function*/
    previousHandler : function(cmp, evt,helper) {
        helper.handleCalFunction(cmp,'prev');
    },
    nextHandler : function(cmp, evt,helper) {
        helper.handleCalFunction(cmp,'next');
    },
    today : function(cmp, evt,helper) {
        helper.handleCalFunction(cmp,'today');
    },
    listViewHandler : function(cmp, evt,helper) {
        helper.handleViewChangeFunction(cmp,'listWeek');
    },
    dailyViewHandler : function(cmp, evt,helper) {
        helper.handleViewChangeFunction(cmp,'timeGridDay');
    },
    weeklyViewHandler : function(cmp, evt,helper) {
        helper.handleViewChangeFunction(cmp,'timeGridWeek');
    },
    monthlyViewHandler : function(cmp, evt,helper) {
        helper.handleViewChangeFunction(cmp,'dayGridMonth');
    },
    refresh: function(cmp, evt,helper) {
        var calendar = cmp.get('v.calendar');
        helper.loadData(cmp,evt)
        .then(function(result){
            calendar.removeAllEvents();
            calendar.addEventSource(helper.loadCalendarData(cmp,evt));
            calendar.render();
            helper.setCalendarLabel(cmp,calendar);
        });
    },
})