({
    doInit : function(cmp, event, helper) {
        helper.doInitHelper(cmp, event,false);
    },
    
    handlefolderOpenEvent : function(cmp, event, helper) {
        helper.handlefolderOpenEventHelper(cmp, event);
    },
    
    goBack: function(cmp, event, helper){
        helper.goBackHanlder(cmp, event);
    },
    
    goHome : function(cmp, event, helper){
        cmp.set('v.currentFolderId',null);
        cmp.set('v.folderName','');
        helper.doInitHelper(cmp,event,false);
    },
    
    refreshFolder : function(cmp, event, helper){
        helper.refreshFolderHelper(cmp, event);
    },
    
})