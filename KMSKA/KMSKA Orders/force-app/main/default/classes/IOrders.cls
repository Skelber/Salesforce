/*
Apex Wrapper class for the Request JSON for Order Webservice.
*/

public class IOrders{
    public List<Order_cls> Orders;
    
    public class Order_cls{
        public Opportunity Order;
        public Contact Contact;
        public Account Organisation;
        public KMSKA_Product__c Activity;
        public List<Order_Line__c> OrderLines;
    }
    
    public static Iorders parseJson(String body){
        IOrders Orders = (IOrders)JSON.deserialize(body, IOrders.Class);
        return Orders;
    }
}