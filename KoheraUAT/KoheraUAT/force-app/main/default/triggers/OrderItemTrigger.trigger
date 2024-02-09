trigger OrderItemTrigger on OrderItem (after insert, after update) {
    
    Order_Triggerfunctions.sendOrderItems(Trigger.New);
    
}