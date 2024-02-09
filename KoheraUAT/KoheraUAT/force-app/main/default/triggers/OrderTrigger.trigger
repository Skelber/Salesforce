trigger OrderTrigger on Order (after insert, after update) {
    
    Order_Triggerfunctions.sendOrders(Trigger.New);
    
}