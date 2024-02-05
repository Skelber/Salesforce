public class Order_Triggerfunctions {
    
    public static Boolean firstcall = false;
    
    public static void sendOrders(List<Order> OrderList) {
        System.debug(!firstcall && !System.isFuture());
        if(!firstcall && !System.isFuture()) {
            firstcall = true;
            List<Id> readyList = new List<Id>();
            for(Order o : OrderList) {
                if(o.Integration_Status__c == 'Ready' || o.Status == 'Approved') {
                    readyList.add(o.Id);
                }
            }    
            if(readyList.size() > 0)   Callout.sendOrder2(readyList);
        }
        
    }
    
    public static void sendOrderItems(List<OrderItem> OrderItemList) {
        System.debug(!firstcall && !System.isFuture());
        if(!firstcall && !System.isFuture()) {
            firstcall = true;
            List<Id> readyList = new List<Id>();
            for(OrderItem o : OrderItemList) {
                if(o.Integration_Status__c == 'Ready') {
                    readyList.add(o.OrderId);
                }
            }    
            if(readyList.size() > 0)   Callout.sendOrder2(readyList);
        }
    }
    
}