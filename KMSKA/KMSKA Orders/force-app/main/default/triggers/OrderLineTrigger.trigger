trigger OrderLineTrigger on Order_Line__c (before insert, before update, after delete){
    set<Id> amountOppIds = new set<Id>();
    set<Id> participantsOppIds = new set<Id>();
    
    if(Trigger.isBefore){
        List<String> subTypeLst = new List<String>();
        
        for(Order_Line__c OL: Trigger.new){
            if(Trigger.isInsert 
               || 
               (Trigger.isUpdate && 
                (OL.Bruto_Price__c!= Trigger.oldMap.get(OL.Id).Bruto_Price__c || 
                 OL.Sub_Type__c!= Trigger.oldMap.get(OL.Id).Sub_Type__c ||
                 OL.Price__c != Trigger.oldMap.get(OL.Id).Price__c ||
                 OL.Quantity__c != Trigger.oldMap.get(OL.Id).Quantity__c
                )
               )
              )
            {
                if(OL.Sub_Type__c!=null){
                    subTypeLst.add(OL.Sub_Type__c);
                }
                
                if(OL.Type__c=='Ticket'){
                    participantsOppIds.add(OL.Id);
                }
            }
            
            if(OL.Sub_Type__c==null){
                OL.Price__c = OL.Bruto_Price__c;
                amountOppIds.add(OL.Order__c);
            } 
        }
        
        if(subTypeLst.size()>0){
            List<KMSKA_Product__c> ProductNameLst = [SELECT Id, Name 
                                                     FROM KMSKA_Product__c 
                                                     WHERE Name IN: subTypeLst
                                                    ];
            List<KMSKA_Product__c> ProductsEngNameLst = [SELECT Id,English_Name__c 
                                                         FROM KMSKA_Product__c 
                                                         WHERE English_Name__c IN: subTypeLst
                                                        ];
            Map<String,KMSKA_Product__c> productNameMap = new Map<String,KMSKA_Product__c>();
            Map<String,KMSKA_Product__c> productEngNameMap = new Map<String,KMSKA_Product__c>();
            for(KMSKA_Product__c KP: ProductNameLst){
                productNameMap.put(KP.Name, KP);
            }
            for(KMSKA_Product__c KP: ProductsEngNameLst){
                productEngNameMap.put(KP.English_Name__c, KP);
            }
            
            List<Bruto_Price_Configuration__c> BrutoPrices = [SELECT Id, Name,Price__c FROM Bruto_Price_Configuration__c 
                                                              WHERE Name IN: subTypeLst];
            Map<String,Bruto_Price_Configuration__c> configurationMap = new Map<String,Bruto_Price_Configuration__c>();
            for(Bruto_Price_Configuration__c BPC: BrutoPrices){
                configurationMap.put(BPC.Name, BPC);
            }
            
            for(Order_Line__c OL: Trigger.new){
                if(OL.Sub_Type__c!=null && ( productNameMap.containsKey(OL.Sub_Type__c) || productEngNameMap.containsKey(OL.Sub_Type__c) ) ){
                    OL.Type__c = 'Product';
                }
                
                if(OL.Sub_Type__c!=null && subTypeLst.contains(OL.Sub_Type__c))
                {
                    if(configurationMap.containsKey(OL.Sub_Type__c)){
                        OL.Price__c = configurationMap.get(OL.Sub_Type__c).Price__c;
                        amountOppIds.add(OL.Order__c);
                    }else{
                        OL.Price__c = OL.Bruto_Price__c;
                        amountOppIds.add(OL.Order__c);
                    }
                }
            }
        }
    }else if(Trigger.isAfter && Trigger.isDelete){
        for(Order_Line__c OL: Trigger.old){
            amountOppIds.add(OL.Order__c);
            if(OL.Type__c=='Ticket'){
                participantsOppIds.add(OL.Id);
            }            
        }
    }
    
    
    
    if(amountOppIds.size()>0 || participantsOppIds.size()>0){
        if(system.isBatch() ||system.isScheduled()){
            OrderLineTriggerHelper.handleOppParticipantsAndAmount(amountOppIds,participantsOppIds);
        }else{
            OrderLineTriggerHelper.handleOppParticipantsAndAmountFuture(amountOppIds,participantsOppIds);
        }
    }
}