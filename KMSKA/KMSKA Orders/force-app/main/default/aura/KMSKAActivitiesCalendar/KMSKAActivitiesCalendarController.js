({
    afterScriptsLoaded : function(cmp, evt,helper) {
        if(cmp.get('v.isCommunity')){
            cmp.set('v.calType','Activity Product');
        }else{
            cmp.set('v.calType','Opportunity');
        }
        
        helper.loadData(cmp,evt)
        .then(function(result){
            helper.drawCalendar(cmp,evt);
            helper.getOppRecordTypeId(cmp,evt);
            helper.getOppTypeValue(cmp,evt);
            helper.getColorsMap(cmp,evt);
        });  
         
    },
    
    onCalTypeChange: function(cmp, evt,helper) {
        helper.getColorsMap(cmp,evt);
        helper.handleDatachange(cmp,evt);    
    },
    
    onOppTypeChange: function(cmp, evt,helper) {
        helper.handleDatachange(cmp,evt);    
    },
    
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