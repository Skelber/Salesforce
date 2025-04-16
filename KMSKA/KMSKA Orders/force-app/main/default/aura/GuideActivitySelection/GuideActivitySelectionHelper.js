({
    loadMonth : function(cmp,evt,params,methodName){
        var self = this;
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,methodName,params)
                .then(
                    function(result){
                        cmp.set('v.MonthLabel', result.monthLabel);
                        cmp.set('v.fromDate', result.fromDate);
                        cmp.set('v.toDate', result.toDate);
                        resolve(result);
                    }
                );
            }
        );
    },
    
    getAssignedTours : function(cmp,evt){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var self = this;
        var params = {
            'userId' : userId,
            'fromDate' : cmp.get('v.fromDate'),
            'toDate' :  cmp.get('v.toDate'),
        };
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'AssignedActivityProducts',params)
                .then(
                    function(result){
                        cmp.set('v.assignedTourLst', result);
                        resolve(result);
                    }
                );
            }
        );
    },
    
    getUpcommingTours : function(cmp,evt){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var self = this;
        var params = {
            'userId' : userId,
            'fromDate' : cmp.get('v.fromDate'),
            'toDate' :  cmp.get('v.toDate'),
        };
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'UpCommingActivityProducts',params)
                .then(
                    function(result){
                        cmp.set('v.upcomingTourLst', result);
                        self.ReevaluateSaving(cmp,evt);
                        resolve(result);
                    }
                );
            }
        );
    },
    
    submitSelectedTour : function(cmp,evt){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var self = this;
        var params = {
            'tourSelection' : cmp.get('v.upcomingTourLst')
        };
        
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'saveActivitySelection',params)
                .then(
                    function(result){
                        if(result.isSuccess){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type" : "success",
                                "title": "Success!",
                                "message": "Tour successfully booked.",
                                "mode": "dismissible"
                            });
                            toastEvent.fire();
                            
                            $A.get('e.force:refreshView').fire();
                            
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type" : "error",
                                "title": "Error!",
                                "message": result.errorMessage,
                                "mode": "dismissible"
                            });
                            toastEvent.fire();
                            if(result.isReselect){
                                self.getAssignedTours(cmp,evt);
                                self.getUpcommingTours(cmp,evt);
                            }
                        }
                        resolve(result);
                    }
                );
            }
        );
    },
    
    ReevaluateSaving: function(cmp, evt){
        var isSaving = false;
        var tourSelection = cmp.get('v.upcomingTourLst');
        for (var i = 0; i < tourSelection.length; i++) {
            if(tourSelection[i].isSelected){
                isSaving = true;
                break;
            }
        }
        cmp.set('v.isSave',isSaving);
    },
    
    apexCallHandler : function(cmp,apexAction,params){
        return new Promise(
            $A.getCallback(
                function( resolve , reject ) {
                    var action = cmp.get("c."+apexAction+"");
                    action.setParams( params );
                    action.setCallback(this,function(callbackResult){
                        if(callbackResult.getState()=='SUCCESS') {
                            resolve(callbackResult.getReturnValue());
                        }
                        if(callbackResult.getState()=='ERROR') {
                            console.log('ERROR', callbackResult.getError() ); 
                            reject(callbackResult.getError());
                        }
                    });
                    $A.enqueueAction( action );
                }
            )
        );
    },
})