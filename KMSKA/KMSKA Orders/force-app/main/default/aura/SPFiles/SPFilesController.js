({
    redirectToPreviewURl : function(component,event,helper){
        helper.previewHelper(component,event);
    },
    
    handleMenuSelect: function(cmp, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        if(selectedMenuItemValue=='Preview'){
            helper.previewHelper(cmp,event); 
        }else if(selectedMenuItemValue=='Download'){
            helper.downloadHelper(cmp,event); 
        }
    },
})