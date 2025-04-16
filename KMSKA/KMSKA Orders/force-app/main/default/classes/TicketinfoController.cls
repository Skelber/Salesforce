public  without sharing class TicketinfoController {
    
    @AuraEnabled 
    public static void addTicketinfo(String TckName, String TckBTW, Decimal TckPrijs, Decimal TckKPrijs, String TckProduct, Integer beschikbarePlaatsen){
       
        Ticket_info__c tck = new Ticket_info__c();
        tck.Name = TckName;
        tck.BTW_Tarief__c = TckBTW;
        tck.Prijs__c = TckPrijs;
        tck.Prijs_Kansentarief__c = TckKPrijs;
        tck.KMSKA_Product__c = TckProduct;
        tck.Beschikbare_plaatsen__c = beschikbarePlaatsen;

        
        insert tck;
    }
    @AuraEnabled(cacheable = true)
    public static List<SObject> getTicketinfos(String recordId){
        return [SELECT Name, Prijs__c, Prijs_Kansentarief__c, BTW_Tarief__c, Beschikbare_plaatsen__c FROM Ticket_info__c WHERE KMSKA_Product__c = :recordId];
    }

    @AuraEnabled
    public static void deleteTickets(List<String> rowIds){
        List <Ticket_Info__c> ticketsToDelete = [SELECT Id FROM Ticket_Info__c WHERE Id in :rowIds];

        delete(ticketsToDelete);
        return;
    }


}