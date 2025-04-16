trigger EventbriteOLI on EventbriteSync__OrderLineItem__c (after insert) {
    try{
        
        //We Have to create Contact for Each OrderLineItem record and Opportunity for each record as well 
        //Then we need to attach Contact to related Campaign as Campaign Memebr.
        
        List<Id> OrderLineItemsIDs = new list<Id>();
        List<Id> CampaignIDs = new list<Id>();
        for(EventbriteSync__OrderLineItem__c OLI : Trigger.New){
            OrderLineItemsIDs.add(OLI.Id);
            CampaignIDs.add(OLI.EventbriteSync__Campaign__c);
        }
        if(OrderLineItemsIDs.size()>0 && CampaignIDs.size()>0){
            
            EventbriteConvert ec = new EventbriteConvert(OrderLineItemsIDs,CampaignIDs);
            
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute() + 1); 
            String ss = String.valueOf(Datetime.now().second());
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            
            try{
                String Name = 'Merge Job '+String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
                String jobID = system.schedule(Name, nextFireTime, ec); 
            }catch(Exception ex){
                //Bcoz Already Job Submitted
            }
            
        }
    }catch(Exception ex){
 		System.debug('Exception :: ' +ex.getMessage());       
    }
}