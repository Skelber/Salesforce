({
    getRecTypeValue : function(cmp,evt){
        var self = this;
        var params = {};
        self.apexCallHandler(cmp,'getRecordTypes',params)
        .then(
            function(result){
                cmp.set("v.singleRecordTypeId", result.single);
                cmp.set("v.recurringRecordTypeId", result.recurring);
            }
        );
    },
    
    loadData : function(cmp,evt){
        var self = this;
        var params = {
            'selGuide' : cmp.get('v.guide'),
            'taal' : cmp.get('v.taal'),
            'doelgroep' : cmp.get('v.doelgroep')
        };
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getData',params)
                .then(
                    function(result){
                        cmp.set('v.dataLst', result.dataLst);
                        cmp.set('v.apDataLst', result.apDataLst);
                        cmp.set('v.isDataLoaded',true);
                        resolve(result);
                    }
                );
            }
        );
    },
    
    drawCalendar: function(cmp,evt) {
        const Wdays = ["zo","ma","di","wo","do","vr","za"];
        var self = this;
        var calendar = new FullCalendar.Calendar(cmp.find("calendar").getElement(), {
            plugins: ["dayGrid", "timeGrid", "list", "interaction", "moment"],
            locale : 'nl',
            weekNumbers: true,
            firstDay : 1,
            height: 'parent',
            expandRows : true,
            scrollTime : '09:00:00',
            views: {
                listDay: { buttonText: "List Day" },
                listWeek: { buttonText: "List Week" },
                listMonth: { buttonText: "List Month" },
                timeGridWeek: { buttonText: "Week time" , slotWidth : 300},
                timeGridDay: { buttonText: "Day Time" },
                dayGridMonth: { buttonText: "Month" },
                dayGridWeek: { buttonText: "Week" },
                dayGridDay: { buttonText: "Day" }
            },
            allDayText : "volledige dag",
            columnHeaderText: function(date) {
                if(this.duration.hasOwnProperty('months')){
                    return  (Wdays[date.getDay()]);
                }else{
                    return  (Wdays[date.getDay()]) +' ' + (date.getDate()) +'/'+ (date.getMonth()+1); 
                }
            },
            defaultView: 'timeGridWeek',
            slotEventOverlap: false,
            displayEventEnd: true,
            eventOverlap: false,
            eventRender: function (info) {
                if(info.event.extendedProps.data.recType=='AP')
                    info.el.querySelector('.fc-title').innerHTML = "<p>" + info.event.title + "</p><p><i>" + info.event.extendedProps.data.extraInfo + "</i></p>";
            },
            header: false,
            events: self.loadCalendarData(cmp,evt),
            selectable: true,
            
            select : function(selectionInfo){
                self.selectedEvents(cmp,evt,selectionInfo);
            },
            
            eventMouseEnter: function (info) {
                cmp.set('v.showTooltip',true);
                
                const startDate = self.formatTwoDigits(info.event.start.getDate())+"/"+self.formatTwoDigits(info.event.start.getMonth()+1)+"/"+info.event.start.getFullYear();
                const endDate = self.formatTwoDigits(info.event.end.getDate())+"/"+self.formatTwoDigits(info.event.end.getMonth()+1)+"/"+info.event.end.getFullYear();
                const startTime = info.event.start.getHours() + ":" + self.formatTwoDigits(info.event.start.getMinutes());
                const endTime = info.event.end.getHours() + ":" + self.formatTwoDigits(info.event.end.getMinutes());
                
                cmp.set('v.RecName',info.event.extendedProps.name);
                cmp.set('v.parentName',info.event.extendedProps.parent);
                cmp.set('v.start',startDate +" "+ startTime);
                cmp.set('v.end',endDate +" "+ endTime);
                cmp.set('v.Gids',info.event.extendedProps.data.guideName);
                cmp.set('v.Extrainfogids',info.event.extendedProps.data.extraInfo);
                if(info.event.extendedProps.data.recType=='AP'){
                    cmp.set('v.isGuideAP',true);
                }else{
                    cmp.set('v.isGuideAP',false);
                }
                
                const calendarHome =  cmp.find("calendar").getElement();
                const eleRect = info.el.getBoundingClientRect();
                const targetRect = calendarHome.getBoundingClientRect();
                
                var positioning = self.cumulativeOffset(info.el);
                positioning.top = eleRect.top - targetRect.top;
                
                setTimeout(() => 
                           {
                               if(cmp.find("calendar-event-tooltip")!=undefined){
                               var calendarHeaderHeight = cmp.find("calendarHeader").getElement().offsetHeight;
                               var calendarHeaderWidth = cmp.find("calendarHeader").getElement().offsetWidth;
                               var cmpTarget = cmp.find('calendar-event-tooltip');
                               const tooltip = cmpTarget.getElement();
                               let tooltipStyle = "position:absolute;";
                               tooltipStyle += "top:" + (positioning.top - (tooltip.offsetHeight - calendarHeaderHeight)) + "px;";
                               
                               if(calendarHeaderWidth < (tooltip.offsetWidth + positioning.left)) tooltipStyle += "left:" + ( (positioning.left + 32) - tooltip.offsetWidth) + "px;";
                               if(calendarHeaderWidth < (tooltip.offsetWidth + positioning.left)) $A.util.removeClass(cmpTarget, 'slds-nubbin_bottom-left');
                               if(calendarHeaderWidth < (tooltip.offsetWidth + positioning.left)) $A.util.addClass(cmpTarget, 'slds-nubbin_bottom-right');
                               
                               
                               if(calendarHeaderWidth > (tooltip.offsetWidth + positioning.left)) tooltipStyle += "left:" + (positioning.left - 12) + "px;";
                               if(calendarHeaderWidth > (tooltip.offsetWidth + positioning.left)) $A.util.removeClass(cmpTarget, 'slds-nubbin_bottom-right');
                               if(calendarHeaderWidth > (tooltip.offsetWidth + positioning.left)) $A.util.addClass(cmpTarget, 'slds-nubbin_bottom-left');
                               
                               cmp.set('v.tooltipStyle',tooltipStyle);
                           }}, 1);
            },
            
            eventMouseLeave: function (info) {
                cmp.set('v.showTooltip',false);
            },
            
            eventClick: function(info) {
                if(info.event.extendedProps.data.recType=='AV'){
                    self.getRecord(cmp,evt,info.event.id)
                    .then(function(result){
                        cmp.set('v.isUpdateRecord',true);
                    }); 
                }else{
                    if(!cmp.get('v.isCommunity')){
                        self.navigateToRecord(cmp,evt,info.event.id);
                    }
                }
            }
            
        });
        calendar.render();
        
        cmp.set('v.isCalenderLoaded',true);
        cmp.set('v.calendar',calendar);
        
        self.setCalendarLabel(cmp,calendar);
    },
    
    navigateToRecord : function(cmp,evt,recId){
        window.open('/' + recId);  
    },
    
    
    selectedEvents : function(cmp,evt,selectionInfo){
        var availability = cmp.get('v.availability');
        availability.Start__c = selectionInfo.start.toISOString();
        availability.End__c = selectionInfo.end.toISOString();
        if(cmp.get('v.isLUGuide')){
            availability.Guide__c = $A.get("$SObjectType.CurrentUser.Id");
        }
        
        cmp.set("v.availability",availability);
        cmp.set("v.isNewRecord",true);
    },
    
    loadCalendarData : function(cmp,evt) {
        var result = cmp.get('v.dataLst');
        var dataSet = [];
        for(var i=0; i<result.length; i++){
            var data = result[i];
            dataSet.push({
                id 				: data.recordId,
                title			: data.title,
                start 			: data.startDatetime,
                end				: data.endDatetime,
                name			: data.name,
                parent			: data.parent,
                backgroundColor : data.ebgColor,
                data			: data
            });
        }
        
        var apDataLst = cmp.get('v.apDataLst');
        for(var i=0; i<apDataLst.length; i++){
            var data = apDataLst[i];
            dataSet.push({
                id 				: data.recordId,
                title			: data.title,
                start 			: data.startDatetime,
                end				: data.endDatetime,
                name			: data.name,
                parent			: data.parent,
                backgroundColor : data.ebgColor,
                data			: data
            });
        }
        
        return dataSet;
    },
    
    setCalendarLabel : function(cmp,calendar){
        cmp.set('v.calendarLabel',calendar.view.title);
    },
    
    getGuideValue : function(cmp,evt){
        var self = this;
        var params = {};
        self.apexCallHandler(cmp,'getAllGuides',params)
        .then(
            function(result){
                var allValues = result;
                var ValMap = [];
                ValMap.push({key: 'Alle Gidsen', value:'all'});
                for(var key in allValues){
                    ValMap.push({key: allValues[key], value:key});
                }
                cmp.set("v.guideMap", ValMap);
            }
        );
    },
    
    getDoelgroepValue : function(cmp,evt){
        var self = this;
        var params = {};
        self.apexCallHandler(cmp,'getTargetAudienceMap',params)
        .then(
            function(result){
                var allValues = result;
                var ValMap = [];
                ValMap.push({key: 'none', value:''});
                for(var key in allValues){
                    ValMap.push({key: allValues[key], value:key});
                }
                cmp.set("v.doelgroepMap", ValMap);
            }
        );
    },
    
    getTaalValue : function(cmp,evt){
        var self = this;
        var params = {};
        self.apexCallHandler(cmp,'getLanguageMap',params)
        .then(
            function(result){
                var allValues = result;
                var ValMap = [];
                ValMap.push({key: 'none', value:''});
                for(var key in allValues){
                    ValMap.push({key: allValues[key], value:key});
                }
                cmp.set("v.taalMap", ValMap);
            }
        );
    },
    
    formatTwoDigits : function(n) {
        return n < 10 ? "0" + n : n;
    },
    
    cumulativeOffset : function(element) {
        let top = 0,
            left = 0;
        do {
            //top += element.offsetTop  || 0;
            left += element.offsetLeft || 0;
            element = element.offsetParent;
        } while (element);
        
        return {
            top: top,
            left: left
        };
    },
    
    handleDatachange: function(cmp,evt){
        var self = this;
        var calendar = cmp.get('v.calendar');
        self.loadData(cmp,evt)
        .then(function(result){
            calendar.removeAllEvents();
            calendar.addEventSource(self.loadCalendarData(cmp,evt));
            calendar.render();
            self.setCalendarLabel(cmp,calendar);
        });
    },
    
    handleCalFunction: function(cmp,fName){
        var calendar = cmp.get('v.calendar');
        calendar[fName]();
        calendar.render();
        this.setCalendarLabel(cmp,calendar);
    },
    
    handleViewChangeFunction: function(cmp,viewName){
        var calendar = cmp.get('v.calendar');
        calendar.changeView(viewName);
        calendar.render();
        this.setCalendarLabel(cmp,calendar);
    },
    
    formateDate : function(date){
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        today = mm + '/' + dd + '/' + yyyy;
        document.write(today);
    },
    
    saveRecord: function(cmp,evt){
        var self = this;
        var action = cmp.get("c.saveAvailability");
        var availability = JSON.parse(JSON.stringify(cmp.get('v.availability')));
        
        action.setParams({
            'availability' : availability
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.isSuccess){
                    cmp.set('v.editError',false);
                    cmp.set('v.errorMessage','');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Availability has been noted successfully.",
                        "mode": "dismissible"
                    });
                    toastEvent.fire();
                    cmp.set('v.isNewRecord',false);
                    cmp.set('v.availability',{});
                    cmp.set('v.isRecurring', false);
                    self.handleDatachange(cmp,evt);
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
                }
                //$A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    getRecord : function(cmp,evt,recId){
        var self = this;
        var params = {'recId' : recId};
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getAvailability',params)
                .then(
                    function(result){
                        cmp.set('v.EditAvailability', result);
                        if(result.RecordType.Name=='Recurring'){
                            cmp.set('v.isRecurring',true);
                        }else{
                            cmp.set('v.isRecurring',false);
                        }
                        resolve(result);
                    }
                );
            }
        );
    },
    
    updateRecord: function(cmp,evt){
        var self = this;
        var action = cmp.get("c.updateAvailability");
        var availability = JSON.parse(JSON.stringify(cmp.get('v.EditAvailability')));
        
        action.setParams({
            'availability' : availability
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.isSuccess){
                    cmp.set('v.editError',false);
                    cmp.set('v.errorMessage','');
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Availability has been updated successfully.",
                        "mode": "dismissible"
                    });
                    toastEvent.fire();
                    cmp.set('v.isUpdateRecord',false);
                    self.handleDatachange(cmp,evt);
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
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    deleteRecord: function(cmp,evt){
        var self = this;
        var action = cmp.get("c.deleteAvailability");
        var availability = JSON.parse(JSON.stringify(cmp.get('v.EditAvailability')));
        
        action.setParams({
            'availability' : availability
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.isSuccess){
                    cmp.set('v.editError',false);
                    cmp.set('v.errorMessage','');
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Beschikbaarheid is succesvol verwijderd.",
                        "mode": "dismissible"
                    });
                    toastEvent.fire();
                    cmp.set('v.isUpdateRecord',false);
                    self.handleDatachange(cmp,evt);
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
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    deleteRecurring: function(cmp,evt,type){
        var self = this;
        var action = cmp.get("c.deleteRecurringAvailability");
        var availability = JSON.parse(JSON.stringify(cmp.get('v.EditAvailability')));
        
        action.setParams({
            'availability' : availability,
            'actionType' : type
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.isSuccess){
                    cmp.set('v.editError',false);
                    cmp.set('v.errorMessage','');
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Beschikbaarheid is succesvol verwijderd.",
                        "mode": "dismissible"
                    });
                    toastEvent.fire();
                    cmp.set('v.isUpdateRecord',false);
                    cmp.set('v.isParentRecurring',false);
                    cmp.set('v.isDeleteRecurring',false);
                    self.handleDatachange(cmp,evt);
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
                }
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