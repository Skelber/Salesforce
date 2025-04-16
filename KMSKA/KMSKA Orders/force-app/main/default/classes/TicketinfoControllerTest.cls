@isTest (SeeAllData = true)
public class TicketinfoControllerTest {
   

    @isTest
    static void testAddTicketinfo(){
 
       KMSKA_Product__c prod = new KMSKA_Product__c(
        Name = 'testprod',
        Duration_in_min__c = 120
       );
       insert prod;

       String prodId = prod.Id;
   
    TicketinfoController.addTicketinfo('test Ticket', '21', 20.0, 10.0, prodId, 1);
    TicketinfoController.getTicketinfos(prod.Id);

    List <Ticket_info__c> Ticket = [SELECT Id FROM Ticket_info__c WHERE KMSKA_Product__c = :prod.Id];

    System.assertEquals(1, Ticket.size());

    TicketinfoController.deleteTickets(new List<String>{prod.Id});
    
    List <Ticket_info__c> TicketDeleted = [SELECT Id FROM Ticket_info__c WHERE KMSKA_Product__c = :prod.Id];

}

}