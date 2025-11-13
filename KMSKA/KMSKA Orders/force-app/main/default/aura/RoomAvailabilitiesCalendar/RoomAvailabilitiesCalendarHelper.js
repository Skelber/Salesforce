({
    /*loadData : function(cmp,evt){
        var self = this;
        var params = {'selRoom' : cmp.get('v.room')};
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getData',params)
                .then(
                    function(result){
                        cmp.set('v.dataLst', result);
                        cmp.set('v.isDataLoaded',true);
                        resolve(result);
                    }
                );
            }
        );
    }, */
    
    drawCalendar: function(cmp,evt) {
        const Wdays = ["zo","ma","di","wo","do","vr","za"];
        var self = this;
        var calendar = new FullCalendar.Calendar(cmp.find("calendar").getElement(), {
            plugins: ["dayGrid", "timeGrid", "list", "interaction", "moment"],
            locale : 'nl',
            weekNumbers: true,
            firstDay : 1,
            //minTime: "09:00:00",
            //maxTime: "23:00:00",
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
            allDayText : "volledige dag",
            columnHeaderText: function(date) {
                if(this.duration.hasOwnProperty('months')){
                    return  (Wdays[date.getDay()]);
                }else{
                    return  (Wdays[date.getDay()]) +' ' + (date.getDate()) +'/'+ (date.getMonth()+1); 
                }
            },
            defaultView: 'timeGridWeek',
            height: "parent",
            slotEventOverlap: false,
            displayEventEnd: true,
            eventOverlap: false,
            eventRender: function (info) {},
            header: false,
            events: self.loadCalendarData(cmp,evt),
            
            eventSources: [
                {
                    events: function(info,successCallback, failureCallback){
                        return self.eventSourceHandler(cmp,evt,info,successCallback, failureCallback);
                    },
                    id: "custom"
                }
            ],
            
            selectable: false,
            
            eventMouseEnter: function (info) {
                cmp.set('v.showTooltip',true);
                
                const startDate = self.formatTwoDigits(info.event.start.getDate())+"/"+self.formatTwoDigits(info.event.start.getMonth()+1)+"/"+info.event.start.getFullYear();
                const endDate = self.formatTwoDigits(info.event.end.getDate())+"/"+self.formatTwoDigits(info.event.end.getMonth()+1)+"/"+info.event.end.getFullYear();
                const startTime = info.event.start.getHours() + ":" + self.formatTwoDigits(info.event.start.getMinutes());
                const endTime = info.event.end.getHours() + ":" + self.formatTwoDigits(info.event.end.getMinutes());
                
                cmp.set('v.RecName',info.event.extendedProps.rec.name);
                cmp.set('v.oppName',info.event.extendedProps.rec.oppName);
                cmp.set('v.accName',info.event.extendedProps.rec.accName);
                cmp.set('v.conName',info.event.extendedProps.rec.conName);
                cmp.set('v.roomName',info.event.extendedProps.rec.roomName);
                cmp.set('v.participants',info.event.extendedProps.rec.Participants);
                cmp.set('v.start',startDate +" "+ startTime);
                cmp.set('v.end',endDate +" "+ endTime);
                
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
            },
            
            eventMouseLeave: function (info) {
                cmp.set('v.showTooltip',false);
            },
            
            eventClick: function(info) {
                window.open('/' + info.event.id);
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
        var params = {'selRoom' : cmp.get('v.room'),'startDate' : info.start,'endDate' : info.end};
        
        this.apexCallHandler(cmp,'getData',params)
        .then(result =>{
            cmp.set('v.dataLst', result);
            successCallback(self.loadCalendarData(cmp,evt));
        }).catch(error =>{
            cmp.set('v.isSpinner',false);
            failureCallback(error);
        });
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
                rec				: data,
                backgroundColor : data.ebgColor,
                textColor 		: data.eventTextColor
            });
        }
        cmp.set('v.isSpinner',false);
        return dataSet;
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
    
    setCalendarLabel : function(cmp,calendar){
        cmp.set('v.calendarLabel',calendar.view.title);
    },
    
    getZalenValue : function(cmp,evt){
        var self = this;
        var params = {};
        self.apexCallHandler(cmp,'getAllRooms',params)
        .then(
            function(result){
                var allValues = result;
                var ValMap = [];
                ValMap.push({key: 'Alle Zalen', value:'all'});
                for(var key in allValues){
                    ValMap.push({key: allValues[key], value:key});
                }
                cmp.set("v.roomMap", ValMap);
            }
        );
    },
    
    getColorsMap : function(cmp,evt){
        var self = this;
        var params = {};
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
    
    handleDatachange: function(cmp,evt){
        var self = this;
        var calendar = cmp.get('v.calendar');
        calendar.refetchEvents();
        /*
        self.loadData(cmp,evt)
        .then(function(result){
            calendar.removeAllEvents();
            calendar.addEventSource(self.loadCalendarData(cmp,evt));
            calendar.render();
            self.setCalendarLabel(cmp,calendar);
        });
        */
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