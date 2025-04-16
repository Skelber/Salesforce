({
    doInitHelper: function(cmp,evt){
        var self = this;
        
        self.loadData(cmp,evt)
        .then(function(result){
            self.loadOpportunity(cmp,evt);
        })
        .then(function(result){
            self.apexCallHandler(cmp,'getToday',{})
            .then(
                function(result){
                    cmp.set('v.toDate',result);
                }
            );
            cmp.set('v.isLoaded',true);
        })
    },
    
    getPlanning : function(cmp,evt,planId){
        var self = this;
        var params = {'recordId' : planId};
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getPlanningRecord',params)
                .then(
                    function(result){
                        cmp.set('v.newPlanning', result);
                        resolve(result);
                    }
                );
            }
        );
    },
    
    loadOpportunity : function (cmp, evt) {
        var self = this;
        var params = {'recordId' : cmp.get('v.recordId')};
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getOpportunityRecord',params)
                .then(
                    function(result){
                        cmp.set('v.Opportunity', result.opp);
                        resolve(result);
                    }
                );
            }
        );
    },
    
    loadData : function(cmp,evt){
        var self = this;
        var params = {'oppId' : cmp.get('v.recordId')};
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getPlannings',params)
                .then(
                    function(result){
                        var Plannings = [];
                        for ( var key in result ) {
                            Plannings.push({value:result[key], key:key});
                        }
                        cmp.set('v.Plannings', Plannings);
                        cmp.set('v.isDataLoaded',true);
                        
                        resolve(result);
                    }
                );
            }
        );
    },
    
    calendarHandler : function(cmp,evt){
        var self = this;
        self.fetchResources(cmp,evt)
        .then(function(result){
            self.loadCalendar(cmp,evt)
            .then(function(result){
                self.drawCalendar(cmp,evt,result)
            })
        })
        
    },
    
    fetchResources : function(cmp,evt){
        var self = this;
        var searchTerm = cmp.get('v.searchTerm');
        if(searchTerm==undefined || searchTerm==null || searchTerm=='')
            searchTerm = '';
        
        var params = {
            searchTerm : searchTerm
        };
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getResources',params)
                .then(
                    function(result){
                        cmp.set('v.resourceLst', result);
                        resolve(result);
                    }
                );
            }
        );
    },
    
    loadCalendar : function(cmp,evt) {
        var self = this;
        
        var oppId = cmp.get('v.recordId');
        var planningRec = cmp.get('v.newPlanning');
        
        var params = {'planning' : planningRec};
        
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getAssignedResources',params)
                .then(
                    function(result){
                        var isEditMode = false;
                        if(cmp.get('v.recordMode')=='edit')isEditMode=true;
                        
                        var data = [];
                        for(var i=0; i<result.length; i++){
                            var event = result[i];
                            var color = '#3788d8';
                            
                            if(event.KMSKA_Activity__r.StageName =='Geaccepteerd'){
                                color = '#ba0517';
                            }else if(event.KMSKA_Activity__r.StageName =='In Afwachting'){
                                color = '#fe9339';
                            }
                            if(isEditMode){
                                var selfRecord = cmp.get('v.newPlanning');
                                if(event.Id == selfRecord.Id){
                                    color = '#04844b';
                                }
                            }
                            
                            data.push({
                                id : event.Id,
                                title: event.Name + '( For : ' + event.KMSKA_Activity__r.Name+')',
                                resourceId : event.Room__c,
                                start : event.Start__c,
                                end:  event.End__c,
                                backgroundColor : color,
                                eventRec: event
                            });
                        }
                        resolve(data);
                    }
                );
            }
        );
    },
    
    drawCalendar: function(cmp,evt,data) {
        var self = this;
        var options = this.getHeaderAndView(cmp,evt);
        if(cmp.find("calendar")==undefined){
            //return;
        }else{
            var calendar = new FullCalendar.Calendar(cmp.find("calendar").getElement(), {
                plugins: [ "resourceTimeline", "bootstrapPlugin" ],
                themeSystem: 'bootstrap',
                schedulerLicenseKey: '0281781704-fcs-1652193159',
                locale : "nl",
                height: 400,
                timezone: 'local',
                header: options.header,
                views : options.views,
                defaultView: options.defaultView,
                visibleRange: options.visibleRange,  
                nowIndicator: true,
                eventTimeFormat : {hour: 'numeric',minute: '2-digit',meridiem: false},
                //slotLabelFormat: ['ddd DD/MM','H:mm'],
                slotLabelFormat: [
                    { day: 'numeric' , month: 'numeric', weekday: 'short' },
                    { hour: 'numeric' }
                ],
                resources: self.getResources(cmp,evt),            
                events: data,
                slotEventOverlap: false,
                displayEventEnd: true,
                eventOverlap: false,
                
                resourceRender: function(renderInfo) {
                    var haveEvent = false;
                    for(var i=0; i<data.length; i++){
                        var d = data[i];
                        if(d.resourceId==renderInfo.resource.id){
                            haveEvent = true;
                            break;
                        }
                    }
                    if(haveEvent){
                        renderInfo.el.style.color = 'gray';
                    }else{
                        renderInfo.el.style.color = 'black';
                    }
                    
                    renderInfo.el.style.cursor = 'pointer';
                    renderInfo.el.style.textdecoration = 'underline';
                    renderInfo.el.style.fontWeight = '500';
                    
                    
                    renderInfo.el.addEventListener("click", function() {
                        self.handleRoomSelect(cmp,evt,renderInfo.resource);
                    });
                },
                
                eventMouseEnter: function (info) {
                    cmp.set('v.showTooltip',true);
                    cmp.set('v.HoveredRec',info.event.extendedProps.eventRec);
                },
                
                eventMouseLeave: function (info) {
                    cmp.set('v.showTooltip',false);
                    cmp.set('v.HoveredRec',{});
                },
            });
            calendar.render();
            cmp.set('v.isCalenderLoaded',true);
            cmp.set('v.calendar',calendar);  
        }
        
    },
    
    handleResourcechange: function(cmp,evt){
        var calendar = cmp.get('v.calendar');
        var self = this;
        self.fetchResources(cmp,evt)
        .then(function(result){
            let exstResource = calendar.getResources();
            for(let i=0; i<exstResource.length; i++){
                let r = exstResource[i];
                r.remove();
            }
            
            var resources = self.getResources(cmp,evt);
            for(let i=0; i<resources.length; i++){
                calendar.addResource(resources[i]);
            }
            calendar.render();
        });
    },
    
    getHeaderAndView : function(cmp,evt){
        var result = {};
        var planing = cmp.get('v.newPlanning');
        
        if(planing.Start__c!=undefined && planing.Start__c!=null && planing.Start__c!=''
           && planing.End__c!=undefined && planing.End__c!=null && planing.End__c!='')
        {
            result.header = {left:   '',center: '',right:  ''};
            result.defaultView = 'resourceTimeline';
            result.views = {timeline:{timeFormat: 'H:mm'}};
            result.visibleRange = {start:  planing.Start__c,end:  planing.End__c};
        }else{
            result.header = {left:   '',center: 'prev,next,today',right:  ''};
            result.views = {timelineWeek :{timeFormat: 'H:mm'}};
            result.defaultView = 'resourceTimelineWeek';
            result.visibleRange = {};
        }
        result.isRange = true;
        return result;
    },
    
    getResources : function(cmp,evt){
        var resourceLst = cmp.get('v.resourceLst');
        
        var resources = [];
        for(var i=0; i<resourceLst.length; i++){
            var resource = resourceLst[i];
            resources.push({
                id : resource.Id,
                title: resource.Name
            });
        }
        return resources;
    },
    
    handleRoomSelect: function(cmp,evt,resourceInfo){
        var planning = cmp.get('v.newPlanning');
        planning.Room__c = resourceInfo.id;
        cmp.set('v.newPlanning',planning);
        
        var roomCmp = cmp.find('roomLookup');
        roomCmp.selectRecordMethod(resourceInfo.id); 
    },
    
    handleSaveHelper : function(cmp, evt){
        var planing = cmp.get('v.newPlanning');
        
        var self = this;
        var params = {
            'OppId' : cmp.get('v.recordId'),
            'planning' : planing
        };
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'savePlanning',params)
                .then(
                    function(result){
                        if(result.isSuccess){
                            cmp.set('v.editError',false);
                            cmp.set('v.errorMessage','');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "Planning saved successfully.",
                                "mode": "dismissible"
                            });
                            toastEvent.fire();
                            cmp.set('v.isNewPlanningModalOpen',false);
                            $A.get('e.force:refreshView').fire();
                            resolve(result);
                        }else{
                            cmp.set('v.editError',true);
                            cmp.set('v.errorMessage',result.message);
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": result.message,
                                "mode": "dismissible"
                            });
                            toastEvent.fire();
                            resolve(result);
                        }
                    }
                );
            }
        );
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
    
    cumulativeOffset : function(element) {
        let top = 0,
            left = 0;
        do {
            left += element.offsetLeft || 0;
            element = element.offsetParent;
        } while (element);
        
        return {
            top: top,
            left: left
        };
    },
    
})