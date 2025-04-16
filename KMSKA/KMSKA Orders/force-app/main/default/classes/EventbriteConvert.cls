global class EventbriteConvert implements Schedulable {
    global list<Id> OrderLineItemsIDs;
    global list<Id> CampaignIds;
    public EventbriteConvert(list<Id> OrderLineItemsIDs,list<Id> CampaignIds){
        this.OrderLineItemsIDs = OrderLineItemsIDs;
        this.CampaignIds = CampaignIds;
    }
    global void execute(SchedulableContext sc) {
        Id batchInstanceId = Database.executeBatch(new EventbriteTickets(OrderLineItemsIDs,CampaignIds),100);
        
        System.abortJob(sc.getTriggerId());
    }
}