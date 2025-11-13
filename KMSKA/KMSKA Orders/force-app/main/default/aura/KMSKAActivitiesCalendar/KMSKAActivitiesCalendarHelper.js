({
    getOppRecordTypeId : function(cmp,evt){
        var self = this;
        var params = {};
        self.apexCallHandler(cmp,'getRecordTypeId',params)
        .then(
            function(result){
                cmp.set("v.RecordTypeId", result);
            }
        );
    },
    
    getOppTypeValue : function(cmp,evt){
        var self = this;
        var params = {};
        self.apexCallHandler(cmp,'getTypeValues',params)
        .then(
            function(result){
                var allValues = result;
                var ValMap = [];
                ValMap.push({key: 'all', value:'All'});
                for(var key in allValues){
                    ValMap.push({key: allValues[key], value:key});
                }
                cmp.set("v.OppTypeMap", ValMap);
            }
        );
    },
    
    loadData : function(cmp,evt){
        var self = this;
        var params = {};
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getVacations',params)
                .then(
                    function(result){
                        if(result.Vakantie){
                            cmp.set('v.HolidayVacations', result.Vakantie);
                        }else{
                            cmp.set('v.HolidayVacations', []);
                        }
                        
                        if(result.Uitzondering){
                            cmp.set('v.ExceptionVacations',result.Uitzondering);
                        }else{
                            cmp.set('v.ExceptionVacations', []);
                        }
                        resolve(result);
                    }
                );
            }
        );
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
                eType			: data.eType,
                participants	: data.participants,
                backgroundColor : data.ebgColor,
                textColor 		: data.eventTextColor,
                guide			: data.guide,
                product         : data.product,
                oppAccount		: data.oppAccount,
                allDay 			: data.isAllDay,
                createdBy		: data.createdBy,
                data			: data
            });
        }
        
        var holidays = cmp.get('v.HolidayVacations');
        for(var i=0; i<holidays.length; i++){
            var data = holidays[i];
            let sD = new Date(data.Start_date__c);
            let sDate = new Date(sD.getFullYear(), sD.getMonth(), sD.getDate(), 0, 0, 0, 0);
            let eD = new Date(data.End_date__c);
            let eDate = new Date(eD.getFullYear(), eD.getMonth(), eD.getDate(), 23, 59, 59, 0);
            dataSet.push({
                id 				: data.Id,
                title			: data.Name,
                start 			: sD.toISOString().split('T')[0],
                end				: (eD.setDate(eD.getDate()+1)), //.toISOString().split('T')[0],
                name			: data.Name,
                eType			: 'holidayevent',
                backgroundColor : '#a3a3a3',
                textColor 		: 'white',
                allDay 			: true,
                data			: data
            });
        }
        
        var exceptions = cmp.get('v.ExceptionVacations');
        for(var i=0; i<exceptions.length; i++){
            var data = exceptions[i];
            let sD = new Date(data.Start_date__c);
            let sDate = new Date(sD.getFullYear(), sD.getMonth(), sD.getDate(), 0, 0, 0, 0);
            let eD = new Date(data.End_date__c);
            let eDate = new Date(eD.getFullYear(), eD.getMonth(), eD.getDate(), 23, 59, 59, 0);
            
            dataSet.push({
                id 				: data.Id,
                title			: data.Name,
                start 			: sD.toISOString().split('T')[0],
                end				: (eD.setDate(eD.getDate()+1)), //.toISOString().split('T')[0],
                name			: data.Name,
                eType			: 'holidayevent',
                backgroundColor : '#a1b96a',
                textColor 		: 'white',
                allDay 			: true,
                data			: data
            });
        }
        cmp.set('v.isSpinner',false);
        return dataSet;
    },
    
    drawCalendar: function(cmp,evt) {
        var self = this;
        var HolidayVacationsLst = cmp.get('v.HolidayVacations');
        var ExceptionVacationsLst = cmp.get('v.ExceptionVacations');
        
        var calendar = new FullCalendar.Calendar(cmp.find("calendar").getElement(), {
            plugins: ["dayGrid", "timeGrid", "list", "interaction", "moment"],
            locale : 'nl',
            weekNumbers: true,
            firstDay : 1,
            scrollTime: "09:00:00",
            views: {
                listDay: { buttonText: "List Day" },
                listWeek: { buttonText: "List Week" },
                listMonth: { buttonText: "List Month" },
                timeGridWeek: { buttonText: "Week time" },
                timeGridDay: { buttonText: "Day Time" },
                dayGridMonth: { buttonText: "Month" },
                dayGridWeek: { buttonText: "Week" },
                dayGridDay: { buttonText: "Day" }
            },
            defaultView: 'timeGridWeek',
            height: "parent",
            slotEventOverlap: false,
            displayEventEnd: true,
            eventOverlap: false,
            eventRender: function (info) {},
            header: false,
            
            //events: self.loadCalendarData(cmp,evt),
            eventSources: [
                {
                    events: function(info,successCallback, failureCallback){
                        return self.eventSourceHandler(cmp,evt,info,successCallback, failureCallback);
                    },
                    id: "custom"
                }
            ],
            
            dayRender : function (info){
                let isupdated = false;
                if(info.date.getDay()==0 || info.date.getDay()==6){
                    info.el.bgColor = 'lightGrey';
                    isupdated = true;
                }
                if(!isupdated){
                    var HolidayVacationsLst = cmp.get('v.HolidayVacations');
                    var ExceptionVacationsLst = cmp.get('v.ExceptionVacations');
                    
                    for(let d = 0; d < HolidayVacationsLst.length; d++){
                        let v = HolidayVacationsLst[d];
                        
                        if(info.date >= new Date(v.Start_date__c).setHours(0,0,0,0) && info.date <= new Date(v.End_date__c).setHours(23,59,59,0)){
                            info.el.bgColor = v.Calendar_Color__c;
                        }
                    }
                    
                    for(let d = 0; d < ExceptionVacationsLst.length; d++){
                        let v = ExceptionVacationsLst[d];
                        
                        if(info.date >= new Date(v.Start_date__c).setHours(0,0,0,0) && info.date <= new Date(v.End_date__c).setHours(23,59,59,0)){
                            info.el.bgColor = v.Calendar_Color__c;
                        }
                    }
                }
            },
            
            eventMouseEnter: function (info) {
                if(info.event.extendedProps.eType!='holidayevent'){
                    cmp.set('v.showTooltip',true);
                    var evtData = info.event.extendedProps.data;
                    var Sdate = new Date(evtData.startDatetime);
                    //var Edate = new Date(evtData.endDatetime);
                    var Edate = new Date(evtData.actualEndDatetime);
                    
                    const startDate = self.formatTwoDigits(Sdate.getDate())+"/"+self.formatTwoDigits(Sdate.getMonth()+1)+"/"+Sdate.getFullYear();
                    const endDate = self.formatTwoDigits(Edate.getDate())+"/"+self.formatTwoDigits(Edate.getMonth()+1)+"/"+Edate.getFullYear();
                    const startTime = Sdate.getHours() + ":" + self.formatTwoDigits(Sdate.getMinutes());
                    const endTime = Edate.getHours() + ":" + self.formatTwoDigits(Edate.getMinutes());
                    
                    cmp.set('v.RecName',info.event.extendedProps.name);
                    cmp.set('v.parentName',info.event.extendedProps.parent);
                    cmp.set('v.eType',info.event.extendedProps.eType);
                    cmp.set('v.start',startDate +" "+ startTime);
                    cmp.set('v.end',endDate +" "+ endTime);
                    cmp.set('v.participants', info.event.extendedProps.participants);
                    cmp.set('v.guide', info.event.extendedProps.guide);
                    cmp.set('v.oppAccount', info.event.extendedProps.oppAccount);
                    cmp.set('v.createdBy', info.event.extendedProps.createdBy);
                    cmp.set('v.zaal', info.event.extendedProps.data.zaal);
                    cmp.set('v.product', info.event.extendedProps.product);
                    
                    const calendarHome =  cmp.find("calendar").getElement();
                    const eleRect = info.el.getBoundingClientRect();
                    const targetRect = calendarHome.getBoundingClientRect();
                    
                    var positioning = self.cumulativeOffset(info.el);
                    positioning.top = eleRect.top - targetRect.top;
                    
                    setTimeout(() => 
                               {
                                   if(cmp.find("calendar-event-tooltip")!=undefined){
                                   var calendarHeaderHeight = cmp.find("calendarHeader").getElement().offsetHeight;
                                   const tooltip = cmp.find("calendar-event-tooltip").getElement();
                                   let tooltipStyle = "position:absolute;";
                                   tooltipStyle += "top:" + (positioning.top - (tooltip.offsetHeight - calendarHeaderHeight)) + "px;";
                                   tooltipStyle += "left:" + positioning.left + "px;";
                                   cmp.set('v.tooltipStyle',tooltipStyle);
                               }}, 1
                              );        
                }
            },
            
            eventMouseLeave: function (info) {
                cmp.set('v.showTooltip',false);
            },
            
            eventClick: function(info) {
                if(!cmp.get('v.isCommunity')){
                    window.open('/' + info.event.id);
                }
            }
            
        });
        calendar.render();
        
        cmp.set('v.isCalenderLoaded',true);
        cmp.set('v.calendar',calendar);
        
        self.setCalendarLabel(cmp,calendar);
    },
    
    eventSourceHandler: function(cmp,evt,info, successCallback, failureCallback) {
        cmp.set('v.isSpinner',true);
        var self = this;
        var params = {
            'calType' : cmp.get('v.calType'),
            'oppType': cmp.get('v.oppType'),
            'isCommunity': cmp.get('v.isCommunity'),
            'APtype' : cmp.get('v.calTypeCommunity'),
            'startDate' : info.start,
            'endDate' : info.end,
        };
        
        this.apexCallHandler(cmp,'getData',params)
        .then(result =>{
            cmp.set('v.dataLst', result);
            successCallback(self.loadCalendarData(cmp,evt));
        }).catch(error =>{
            cmp.set('v.isSpinner',false);
            failureCallback(error);
        });
    },
    
    formatTwoDigits : function(n) {
        return n < 10 ? "0" + n : n;
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
    
    handleDatachange: function(cmp,evt){
        cmp.set('v.isSpinner',true);
        var self = this;
        var calendar = cmp.get('v.calendar');
        self.loadData(cmp,evt)
        .then(function(result){
            calendar.refetchEvents();
            /*
            calendar.removeAllEvents();
            calendar.addEventSource(self.loadCalendarData(cmp,evt));
            calendar.render();
            self.setCalendarLabel(cmp,calendar);
            */
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
    
    setCalendarLabel : function(cmp,calendar){
        cmp.set('v.calendarLabel',calendar.view.title);
    },
    
    formateDate : function(date){
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        today = mm + '/' + dd + '/' + yyyy;
        document.write(today);
    },
    
    getColorsMap : function(cmp,evt){
        var self = this;
        var params = {
            'calType' : cmp.get('v.calType')
        };
        self.apexCallHandler(cmp,'getCalendarColors',params)
        .then(
            function(result){
                var allValues = result;
                var ValMap = [];
                ValMap.push({key: 'Andere', value: $A.get("$Label.c.Default_Activity_Calendar_Color")});
                for(var key in allValues){
                    ValMap.push({key: key, value:allValues[key]});
                }
                cmp.set("v.calendarMap", ValMap);
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
})