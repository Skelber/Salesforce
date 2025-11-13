({
    afterScriptsLoaded : function(cmp, evt,helper) {
        var params = {};
        helper.apexCallHandler(cmp,'isLoggedUserGuide',params)
        .then(
            function(result){
                cmp.set('v.isLUGuide',result);
                helper.drawCalendar(cmp,evt);
                helper.getZalenValue(cmp,evt);
                helper.getColorsMap(cmp,evt); 
            }
        );
    },
    
    onRoomChange: function(cmp, evt,helper) {
        helper.handleDatachange(cmp,evt);    
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
        calendar.refetchEvents();
        /*
        helper.loadData(cmp,evt)
        .then(function(result){
            calendar.removeAllEvents();
            calendar.addEventSource(helper.loadCalendarData(cmp,evt));
            calendar.render();
            helper.setCalendarLabel(cmp,calendar);
        });
        */
    },
})