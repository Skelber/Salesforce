@isTest
public class IOrdersTest {
    
    @isTest
    public static void getTestRequest(){
        Opportunity opp = new Opportunity();
        opp.GT_Unique_ID__c = '123';
        
        Account act = new Account();
        //act.GT_Unique_ID__c = '123';
        
        Contact con = new Contact();
        //con.GT_Unique_ID__c = '123';
        
        Order_Line__c ol = new Order_Line__c();
        //ol.GT_Unique_ID__c = '123';
        
        IOrders.Order_cls orderCls = new IOrders.Order_cls();
        orderCls.Organisation = act;
        orderCls.Contact = con;
        orderCls.Order = opp;
        orderCls.OrderLines = new List<Order_Line__c>();
        orderCls.OrderLines.add(ol);
        
        IOrders order = new IOrders();
        order.Orders = new List<IOrders.Order_cls>();
        order.Orders.add(orderCls);
        
        String req = JSON.serialize(order);
        IOrders Orders = IOrders.parseJson(req);
        
        System.debug(Orders.Orders);
        System.debug(Orders.Orders[0].Organisation);
        
    }
}