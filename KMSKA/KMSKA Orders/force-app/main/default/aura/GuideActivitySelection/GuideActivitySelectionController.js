({
    doInit : function(cmp, evt,helper) {
        cmp.set('v.loading',true);
        var params = {};
        helper.apexCallHandler(cmp,'isLoggedUserGuide',params)
        .then(
            function(result){
                cmp.set('v.isLUGuide',result);
                helper.loadMonth(cmp,evt,{},'getMonthLabel')
                .then(function(result){
                    helper.getAssignedTours(cmp,evt);
                })
                .then(function(result){
                    helper.getUpcommingTours(cmp,evt);
                    
                })
                .then(function(result){
                    cmp.set('v.loading',false);
                });
            }
        );
    },
    
    previousWeek : function(cmp, evt,helper) {
        cmp.set('v.loading',true);
        var params = {
            'fromDate' : cmp.get('v.fromDate')
        };
        helper.loadMonth(cmp,evt,params,'getPreviousMonth')
        .then(function(result){
            helper.getAssignedTours(cmp,evt);
        })
        .then(function(result){
            helper.getUpcommingTours(cmp,evt);
        })
        .then(function(result){
            cmp.set('v.loading',false);
        });
    },
    
    nextWeek : function(cmp, evt,helper) {
        cmp.set('v.loading',true);
        var params = {
            'toDate' : cmp.get('v.fromDate') //cmp.get('v.toDate')
        };
        helper.loadMonth(cmp,evt,params,'getNextMonth')
        .then(function(result){
            helper.getAssignedTours(cmp,evt);
        })
        .then(function(result){
            helper.getUpcommingTours(cmp,evt);
        })
        .then(function(result){
            cmp.set('v.loading',false);
        });
    },
    
    evaluateSaving: function(cmp, evt,helper){
        helper.ReevaluateSaving(cmp,evt);
    },
    
    handleSave : function(cmp, evt,helper) {
        helper.submitSelectedTour(cmp,evt);
    },
    
    refresh : function(cmp, evt,helper){
        cmp.set('v.loading',true);
        var params = {
            'fromDate' : cmp.get('v.fromDate')
        };
        helper.loadMonth(cmp,evt,params,'getMonthLabel')
        .then(function(result){
            helper.getAssignedTours(cmp,evt);
        })
        .then(function(result){
            helper.getUpcommingTours(cmp,evt);
        })
        .then(function(result){
            cmp.set('v.loading',false);
        });
    },
    
})