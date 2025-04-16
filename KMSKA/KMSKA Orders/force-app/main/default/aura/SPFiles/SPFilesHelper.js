({
    previewHelper: function(cmp,evt){
        let action = cmp.get('c.previewFile');
        action.setParams({
            'itemId' : cmp.get('v.fileId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                window.open(result, '_blank');
            }
        });
        $A.enqueueAction(action);
    },
    
    downloadHelper: function(cmp,evt){
        let action = cmp.get('c.downloadFile');
        action.setParams({
            'itemId' : cmp.get('v.fileId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                window.open(result, '_blank');
            }
        });
        $A.enqueueAction(action);
    },
})