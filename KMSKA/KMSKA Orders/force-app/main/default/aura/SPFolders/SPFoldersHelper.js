({
    fireFolderOpenEvent : function(cmp, event) { 
        var cmpEvent = cmp.getEvent("folderOpenEvent"); 
        cmpEvent.setParams(
            {
                "folderId" : cmp.get('v.folderID'),
                "folder" : cmp.get('v.folder')
            }
        ); 
        cmpEvent.fire(); 
    },
    
})