({
    doInitHelper: function(cmp, event, isRefresh){
        let action = cmp.get('c.getAllItems');
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                cmp.set('v.folderList',result.folders);
                cmp.set('v.fileList',result.files);
                cmp.set("v.allFolders", result.allFolders);
                cmp.set("v.parentFId",result.parentFolder.eTag);
                if(!isRefresh){
                    cmp.set('v.currentFolderId',result.parentFolder.eTag);
                    cmp.set('v.folderName',result.parentFolder.name);
                    cmp.set('v.folderPath',result.parentFolder.name+' / ');
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    handlefolderOpenEventHelper: function(cmp, event){
        var folderId = event.getParam("folderId"); 
        var folder = event.getParam("folder");
        
        if(folderId!=undefined && folderId!=null){
            cmp.set('v.currentFolderId',folder.eTag);
            this.OpenFolder(cmp,event,folder);
        }
    },
    
    OpenFolder : function(cmp, event,folder){
        cmp.set('v.folderName',folder.name);  
        cmp.set('v.folderPath',cmp.get('v.folderPath')+folder.name+' / ');  
    },
    
    goBackHanlder: function(cmp, event){
        var currentFolderId = cmp.get('v.currentFolderId');
        var cFolder = cmp.get('v.allFolders')[currentFolderId];
        var folderPath = cmp.get('v.folderPath');
        var cFolderPath = folderPath.substr(0, folderPath.indexOf(cFolder.name+' / '));
        
        cmp.set('v.currentFolderId',cFolder.pId);
        cmp.set('v.folderName',cFolder.name);
        cmp.set('v.folderPath',cFolderPath);
    },
    
    refreshFolderHelper :  function(cmp, event,folderId){
        this.doInitHelper(cmp,event,true);
    },
})