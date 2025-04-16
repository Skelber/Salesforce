({
    doInit : function(cmp, evt,helper) {
        cmp.set('v.loading',true);
        var params = {};
        helper.doInitHelper(cmp,evt);
    },
    
    filterChangeHandler: function(cmp,evt,helper){
        cmp.set('v.loading',true);
        helper.getGuides(cmp,evt)
        .then(function(result){
            cmp.set('v.loading',false);
        });
    },
    
    handleGuideSelection : function(cmp,evt,helper){
        var availableGuide = cmp.get('v.AvailableGuide');
        var index = evt.getSource().get("v.name");
        var updatedAGwrp = [];
        
        for(var i = 0; i < availableGuide.length; i++) {
            if(i!=index){
                availableGuide[i].Assign = false;
            }
            updatedAGwrp.push(availableGuide[i]);
        }
        cmp.set("v.AvailableGuide",updatedAGwrp);
    },
    
    
    
    handleSave : function(cmp, evt, helper) {
        var isSelected = false;
        var isAssigned = false;
        var selectedGuide = null;
        var availableGuide = cmp.get('v.AvailableGuide');
        for(var i = 0; i < availableGuide.length; i++) {
            if(availableGuide[i].Assign){
                isSelected = true;
                isAssigned = availableGuide[i].isAssigned;
                selectedGuide = availableGuide[i];
            }
        }
        
        if(isSelected){
            helper.handleSaveHelper(cmp,evt,selectedGuide)
            .then(function(result){
                if(result.isSuccess){
                    helper.showToast(cmp,evt,'Success','Success!','Gids succesvol toegekend.');
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": cmp.get('v.recordId')
                    });
                    navEvt.fire();
                    $A.get("e.force:refreshView");
                }else{
                    helper.showToast(cmp,evt,'Error','Error!',result.errorMsg);
                }
            });
        }else{
            helper.showToast(cmp,evt,'warning','Warning!','Selecteer een gids om toe te kennen.');
        }
    },
    
    handleExit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire()
    }
    
})