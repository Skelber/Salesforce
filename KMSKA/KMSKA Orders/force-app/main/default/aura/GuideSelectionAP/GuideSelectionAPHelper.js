({
    doInitHelper : function(cmp,evt){
        var self = this;
        cmp.set('v.loading',true);
        self.getRecord(cmp,evt)
        .then(function(result){
            self.getLanguage(cmp,evt)
        })
        .then(function(result){
            self.getTargetAudience(cmp,evt);
        })
        .then(function(result){
            self.getGuides(cmp,evt);
        })
        .then(function(result){
            cmp.set('v.loading',false);
        });
    },
    
    getRecord : function(cmp,evt){
        var self = this;
        var params = {
            'recordId' : cmp.get('v.recordId')
        };
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getActivityProduct',params)
                .then(
                    function(result){
                        cmp.set('v.ActivityProduct', result);
                        cmp.set('v.Language', result.Taal__c);
                        cmp.set('v.TargetAudience', result.Doelgroep__c);
                        if(result.Availablility__c!=undefined && result.Availablility__c!=null && result.Availablility__c!=''){
                            cmp.set('v.isError',true);
                            cmp.set('v.errorMessage',['Gids is al toegekend.']);
                        }else if(result.Opportunity__r.StageName =='Geannuleerd' || result.Opportunity__r.StageName=='Geweigerd'){
                            cmp.set('v.isError',true);
                            cmp.set('v.errorMessage',['Deze activiteit is geannuleerd of geweigerd.']);
                        }else if(result.Opportunity__r.Stuur_naar_gidsen_platform__c){
                            cmp.set('v.isError',true);
                            cmp.set('v.errorMessage',['Product is al naar het gidsen platform gestuurd.']);
                        }else if(!(result.Opportunity__r.StageName =='Geannuleerd'  || result.Opportunity__r.StageName =='Geweigerd') && result.Opportunity__r.Stuur_naar_gidsen_platform__c==false){
                            cmp.set('v.isError',false);
                            cmp.set('v.isProcess',true);
                        }
                        
                        resolve(result);
                    }
                );
            }
        );
    },
    
    getLanguage : function(cmp,evt){
        var self = this;
        var params = {};
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getLanguageMap',params)
                .then(
                    function(result){
                        var opts=[];
                        opts.push({class: "optionClass", value:'none', label:'', selected:false});
                        for ( var key in result ) {
                            opts.push({class: "optionClass", value:result[key], label:key, selected:false}); 
                        }                        
                        cmp.set('v.LanguageLst', opts);
                        resolve(result);
                    }
                );
            }
        );
    },
    
    getTargetAudience : function(cmp,evt){
        var self = this;
        var params = {};
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getTargetAudienceMap',params)
                .then(
                    function(result){
                        var opts=[];
                        opts.push({class: "optionClass", value:'none', label:'', selected:false});
                        for ( var key in result ) {
                            opts.push({class: "optionClass", value:result[key], label:key, selected:false}); 
                        }                        
                        cmp.set('v.TargetAudienceLst', opts);
                        resolve(result);
                    }
                );
            }
        );
    },
    
    getGuides : function(cmp,evt){
        var self = this;
        var params = {
            'recordId' : cmp.get('v.recordId'),
            'targetAud' : cmp.get('v.TargetAudience'),
            'lang' : cmp.get('v.Language')
        };
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'getAvailableGuide',params)
                .then(
                    function(result){
                        cmp.set('v.AvailableGuide', result);
                        resolve(result);
                    }
                );
            }
        );
    },
    
    handleSaveHelper: function(cmp,evt,selectedGuide){
        var self = this;
        var params = {
            'recordId' : cmp.get('v.recordId'),
            'selectedGuide' :JSON.stringify(selectedGuide)
        };
        return new Promise(
            function( resolve , reject ) {
                self.apexCallHandler(cmp,'assignGuide',params)
                .then(
                    function(result){
                        resolve(result);
                    }
                );
            }
        );
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
    
    showToast : function(cmp, evt, type,title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    },
})