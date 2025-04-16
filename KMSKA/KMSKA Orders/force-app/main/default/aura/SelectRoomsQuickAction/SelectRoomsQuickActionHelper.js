({
    doInitHelper: function(cmp,evt){
        this.loadOpportunity(cmp,evt);
    },
    
    loadOpportunity : function (cmp, evt) {
        var action = cmp.get("c.getOpportunityRecord");
        action.setParams({
            'recordId' : cmp.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var result = response.getReturnValue();
                cmp.set('v.Opportunity', result.opp);
                cmp.set('v.isOppLoaded',true);
                this.fetchResources(cmp,evt);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchResources : function(cmp,evt){
        var action = cmp.get("c.getResources");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var result = response.getReturnValue();
                cmp.set('v.resourceLst', result);
                this.loadCalendar(cmp,evt);
            }
        });
        $A.enqueueAction(action);
    },
    
    loadCalendar : function(cmp,evt) {
        var oppId = cmp.get('v.recordId');
        var action = cmp.get("c.getAssignedResources");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var result = response.getReturnValue();
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
                this.drawCalendar(cmp,evt,data);
            }
        });
        $A.enqueueAction(action);
    },
    
    drawCalendar: function(cmp,evt,data) {
        var self = this;
        var options = this.getHeaderAndView(cmp,evt);
        var timezone = $A.get("$Locale.timezone");
        var ele = cmp.find('calendar').getElement();
        $(ele).fullCalendar({
            schedulerLicenseKey: 'CC-Attribution-NonCommercial-NoDerivatives',
            timezone: 'local',
            header: options.header,
            views : options.views,
            defaultView: options.defaultView,
            visibleRange: options.visibleRange,            
            editable: true,
            eventLimit: true,
            selectable: true,
            selectHelper: true,
            nowIndicator: true,
            minTime: '00:00:00',
            maxTime: '24:00:00',
            timeFormat: 'H:mm' ,
            slotDuration: '00:15:00',
            slotLabelFormat: [
                'ddd DD/MM', // top level of text
                'H:mm'        // lower level of text
            ],
            height: "auto",
            resources: self.getResources(cmp,evt),            
            events: data,
            select : function(start, end, jsEvent, view, resource){
                self.selectedEvents(cmp,evt,start, end, jsEvent, view, resource);
            },
            
            eventMouseover : function( event, jsEvent, view ){
                cmp.set('v.showTooltip',true);
                cmp.set('v.HoveredRec', event.eventRec);
            },
            
            eventMouseout : function (info) {
                cmp.set('v.showTooltip',false);
                cmp.set('v.HoveredRec', {});
            },
            
            eventClick: function(info) {
                window.open('/' + info.id);
            }
        });
    },
    
    getHeaderAndView : function(cmp,evt){
        var result = {};
        var opportunity = cmp.get('v.Opportunity');
        
        if(opportunity.Start_Time__c!=undefined && opportunity.Start_Time__c!=null && opportunity.Start_Time__c!=''
           && opportunity.End_Time__c!=undefined && opportunity.End_Time__c!=null && opportunity.End_Time__c!='')
        {
            result.header = {
                left:   '',
                center: '',
                right:  ''
            };
            result.defaultView = 'timeline';
            result.views = {
                timeline:{
                    timeFormat: 'H:mm'
                }
            };
            result.visibleRange = {
                start: opportunity.Start_Time__c,
                end: opportunity.End_Time__c
            };
        }else{
            result.header = {
                left:   'prev,next,today',
                center: '',
                right:  ''
            };
            result.views = {
                timelineWeek :{
                    timeFormat: 'H:mm'
                }
            };
            result.defaultView = 'timelineWeek';
            result.visibleRange = {};
        }
        
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
    
    selectedEvents : function(cmp,evt,start, end, jsEvent, view, resource){
        var ar = cmp.get('v.assignedResource');
        ar.Start_Activity_Product__c = start.utc().format();
        ar.End_Activity_Product__c = end.utc().format();
        ar.Resource__c = resource.id;
        ar.Quantity__c = 1;
        ar.KMSKA_Opportunity__c = cmp.get('v.recordId');
        ar.Activity_Product__c = null;
        
        cmp.set("v.assignedResource",ar);
        cmp.set("v.isModalOpen",true);
    },
    
    saveRecord: function(cmp,evt){
        var action = cmp.get("c.saveAssignedResource");
        var aresource = JSON.parse(JSON.stringify(cmp.get('v.assignedResource')));
        
        action.setParams({
            'aresource' : aresource
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                cmp.set("v.isModalOpen",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Resource has been assigned successfully.",
                    "mode": "dismissible"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
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