public class OpportunityLineItemsController {
    
    @auraEnabled
    public Product2 product {get; set;}
    
    @auraEnabled
    public static Id opportunityId {get; set;}
       
    @auraEnabled
    public static List<OppLineItem_Contract_Bid> getOppLineItemsById(Id lineItemId) {
        system.debug('getOppLineItemsById: ' + lineItemId);
        List<OppLineItem_Contract_Bid> ocbs = new List<OppLineItem_Contract_Bid>();
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>([SELECT Id, Name, ProductCode, Description, UnitPrice, Product2Id, Bidding__c, Bid__c, Contract__c,
                                                                               Manual_Price_Reason__c, Manual_Price__c, Quantity, OpportunityId, Opportunity.CurrencyISOCode,
                                                                               Opportunity.Account.name, Opportunity.Account.Id, Opportunity.StageName, Opportunity.RFQ_Received_date__c, 
                                                                               Product2.Name, Prototype__c, TF_Prototype__c, Buyer__c, Buyer__r.Id, Buyer__r.Name, 
                                                                               Product2.ProductCode, Product2.Dimension__c, Product2.Coating__c, Product2.Weight__c, 
                                                                               Product2.Washer__c, Product2.Patch__c, Product2.Patch_length__c, Product2.Extra_Feature_1000__c,
                                                                               Product2.Alias__c, Product2.Drawing_Portal_URL__c
                                                                        FROM OpportunityLineItem
                                                                       WHERE Id = :lineItemId
                                                                     ORDER BY Id ASC]);
        system.debug('olis: ' + olis);
        Id oppId = olis[0].OpportunityId;
        
        Set<Id> productIds = new Set<Id>();
        Set<Id> biddingIds = new Set<Id>();
        Set<String> productCodes = new Set<String>();
        for(OpportunityLineItem oli : olis) {
            productIds.add(oli.Product2Id);
            biddingIds.add(oli.Bidding__c);
            if (oli.ProductCode != '' && oli.ProductCode != null){
                productCodes.add(oli.ProductCode);
            }
            if (oli.Product2.Alias__c != '' && oli.Product2.Alias__c != null){
                productCodes.add(oli.Product2.Alias__c);
            }
        }
        
        List<Contract> contracts = new List<Contract>([SELECT Id, Name, ContractNumber, AccountId, Account.Name, StartDate, Contract_End_Date__c, Status, Unit_Price__c, 
                                                              Part__c, Sales_Price__c, Purchase_Price__c, Naked_Sales_Price__c, Customer_Plant__c, CurrencyIsoCode, 
                                                              RecordType.Name, Quantity__c, Unit_of_measure__c, ProductCode__c, Part__r.Alias__c, Is_Selectable__c,
                                                              Purchase_Price_Show__c, Sales_Price_Show__c, Naked_Price_Show__c
                                                         FROM Contract
                                                        WHERE (ProductCode__c IN :productCodes OR Part__r.Alias__c IN :productCodes) AND Show_on_table__c = true
                                                     ORDER BY Purchase_Price__c DESC NULLS LAST, RecordType.Name DESC, Customer_Plant__c ASC, Quantity__c DESC]);
        
        List<Bid__c> bids = new List<Bid__c>([SELECT Id, Name, Supplier__c, Supplier__r.Name, Unit_Price__c, Bidding__c, Supplier_Score__c, Status__c, 
                                                     CurrencyISOCode, MOQ__c, PPAP_LT__c, Proto_LT__c,
                                                     Serial_LT__c, Tooling_Cost__c, Weekly_Capacity_Norm__c, According_to_drawing__c
                                                         FROM Bid__c    
                                                        WHERE Bidding__c IN :biddingIds]);
        
        List<OpportunityLineItem> linkedOlis = new List<OpportunityLineItem>([SELECT Id, Name, ProductCode, Description, UnitPrice, Product2Id, Bidding__c, Bid__c, Contract__c,
                                                                                     Manual_Price_Reason__c, Manual_Price__c, Quantity, OpportunityId, Opportunity.Name,
                                                                                     Bid__r.Name, Contract__r.Name, Prototype__c, TF_Prototype__c, Buyer__c, Buyer__r.Id, 
                                                                                     Opportunity.Account.name, Opportunity.Account.Id, Opportunity.StageName, Opportunity.RFQ_Received_date__c, 
                                                                                     Product2.ProductCode, Product2.Dimension__c, Product2.Coating__c, Product2.Weight__c, 
                                                                                     Product2.Washer__c, Product2.Patch__c, Product2.Patch_length__c, Product2.Extra_Feature_1000__c,
                                                                                     Product2.Alias__c, Product2.Drawing_Portal_URL__c
                                                                                FROM OpportunityLineItem
                                                                               WHERE (ProductCode IN :productCodes OR Product2.Alias__c IN :productCodes) AND OpportunityId != :oppId]);
        
        OpportunityLineItem oli = olis[0];
        
            String selected = '';
            String selectedName = '';
            Boolean manual = false;
            List<Contract> linkedContracts = new List<Contract>();
            List<Bid__c> linkedBids = new List<Bid__c>();
            List<OpportunityLineItem> linkedOlis2 = new List<OpportunityLineItem>();
            for(Contract c : contracts) {
                if((c.ProductCode__c == oli.ProductCode && c.ProductCode__c <> null) || (c.Part__r.Alias__c <> null && c.Part__r.Alias__c == oli.ProductCode) || (c.ProductCode__c == oli.Product2.Alias__c && oli.Product2.Alias__c <> null)) {
                    linkedContracts.add(c);
                } 
                if(c.Id == oli.Contract__c) {
                    selected = c.Id;
                    selectedName = c.CurrencyISOCode + ' ' + (c.Purchase_Price__c <> null ? c.Purchase_Price__c : c.Naked_Sales_Price__c) + ' (' + c.Account.Name + ')';
                }
            }
            for(Bid__c b : bids) {
                if(b.Bidding__c == oli.Bidding__c) {
                    linkedBids.add(b);
                }
                if(b.Id == oli.Bid__c) {
                    selected = b.Id;
                    selectedName = b.CurrencyISOCode + ' ' + b.Unit_Price__c + ' (' + b.Supplier__r.Name + ')';
                }
            }
            for(OpportunityLineItem lo : linkedOlis) {
                if((lo.ProductCode == oli.ProductCode && lo.ProductCode <> null) || (lo.Product2.Alias__c == oli.ProductCode && lo.Product2.Alias__c <> null) || (lo.ProductCode == oli.Product2.Alias__c && lo.ProductCode <> null)) {
                    linkedOlis2.add(lo);
                }
            }
            system.debug('Manual_Price__c: ' + oli.Manual_Price__c);
            if(oli.Manual_Price__c <> null) {
//                selected = '';
                selectedName = oli.Opportunity.CurrencyISOCode + ' ' + oli.Manual_Price__c + ' (Manual)';
                manual = true;
            }
            
            List<Decimal> resultCost = CostModelBolts_Controller.getPart(oli);
            String missingFields = CostModelBolts_Controller.getMissingFields(oli);
            
            OppLineItem_Contract_Bid ocb = new OppLineItem_Contract_Bid();
            ocb.oppLineItem = oli;
            ocb.contracts = linkedContracts;
            ocb.bids = linkedBids;
            ocb.olis = linkedOlis2;
            ocb.selected = selected;
            ocb.currencyISOCodeOpp = oli.Opportunity.CurrencyISOCode;
            if(selectedName <> '') selectedName = ' - ' + selectedName;
//            String s = oli.Quantity + '';
//            s = s.left(s.length()-3).reverse().replaceAll('.{3}', '$0.').reverse();
//            if(s.startsWith('.')) s = s.right(s.length()-1);
            String s = oli.Quantity.format();
            ocb.selectedName = ' - VOL ' + s + (oli.Buyer__r.Name <> null ? ', ' + oli.Buyer__r.Name : '') + ')' + selectedName;
            ocb.manual = manual;
            ocb.missingFields = missingFields;
            ocb.cost = resultCost[0];
            ocb.TO = resultCost[1];
            ocb.MOQ = resultCost[2];
            ocb.TO_MOQ = resultCost[3];
            ocbs.add(ocb);
            return ocbs;
    }
        
    @auraEnabled
    public static List<OppLineItem_Contract_Bid> getOppLineItems(Id oppId) {
        
        List<OppLineItem_Contract_Bid> ocbs = new List<OppLineItem_Contract_Bid>();
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>([SELECT Id, Name, ProductCode, Description, UnitPrice, Product2Id, Bidding__c, Bid__c, Contract__c,
                                                                               Manual_Price_Reason__c, Manual_Price__c, Quantity, OpportunityId, Opportunity.CurrencyISOCode,
                                                                               Opportunity.Account.name, Opportunity.Account.Id, Opportunity.StageName, Opportunity.RFQ_Received_date__c, 
                                                                               Product2.Name, Prototype__c, TF_Prototype__c, Buyer__c, Buyer__r.Id, Buyer__r.Name, 
                                                                               Product2.ProductCode, Product2.Dimension__c, Product2.Coating__c, Product2.Weight__c, 
                                                                               Product2.Washer__c, Product2.Patch__c, Product2.Patch_length__c, Product2.Extra_Feature_1000__c,
                                                                               Product2.Alias__c, Product2.Drawing_Portal_URL__c,
                                                                               Contract__r.CurrencyISOCode, Contract__r.Purchase_Price__c, Contract__r.Naked_Sales_Price__c, Contract__r.Account.Name,
                                                                               Bid__r.CurrencyISOCode, Bid__r.Unit_Price__c, Bid__r.Supplier__r.Name
                                                                        FROM OpportunityLineItem
                                                                       WHERE OpportunityId = :oppId
                                                                     ORDER BY Id ASC]);
        
        /*
        Set<Id> productIds = new Set<Id>();
        Set<Id> biddingIds = new Set<Id>();
        Set<String> productCodes = new Set<String>();
        for(OpportunityLineItem oli : olis) {
            productIds.add(oli.Product2Id);
            biddingIds.add(oli.Bidding__c);
            productCodes.add(oli.ProductCode);
            productCodes.add(oli.Product2.Alias__c);
        }
        
        List<Contract> contracts = new List<Contract>([SELECT Id, Name, ContractNumber, AccountId, Account.Name, StartDate, Contract_End_Date__c, Status, Unit_Price__c, 
                                                              Part__c, Sales_Price__c, Purchase_Price__c, Naked_Sales_Price__c, Customer_Plant__c, CurrencyIsoCode, 
                                                              RecordType.Name, Quantity__c, Unit_of_measure__c, ProductCode__c, Part__r.Alias__c
                                                         FROM Contract
                                                        WHERE (ProductCode__c IN :productCodes OR (Part__r.Alias__c != null AND Part__r.Alias__c IN :productCodes))
                                                     ORDER BY Purchase_Price__c DESC NULLS LAST, RecordType.Name DESC, Customer_Plant__c ASC, Quantity__c DESC]);
        
        List<Bid__c> bids = new List<Bid__c>([SELECT Id, Name, Supplier__c, Supplier__r.Name, Unit_Price__c, Bidding__c, Supplier_Score__c, Status__c, 
                                                     CurrencyISOCode, MOQ__c, PPAP_LT__c, Proto_LT__c,
                                                     Serial_LT__c, Tooling_Cost__c, Weekly_Capacity_Norm__c, According_to_drawing__c
                                                         FROM Bid__c    
                                                        WHERE Bidding__c IN :biddingIds]);
        
        List<OpportunityLineItem> linkedOlis = new List<OpportunityLineItem>([SELECT Id, Name, ProductCode, Description, UnitPrice, Product2Id, Bidding__c, Bid__c, Contract__c,
                                                                                     Manual_Price_Reason__c, Manual_Price__c, Quantity, OpportunityId, Opportunity.Name,
                                                                                     Bid__r.Name, Contract__r.Name, Prototype__c, TF_Prototype__c, Buyer__c, Buyer__r.Id, 
                                                                                     Opportunity.Account.name, Opportunity.Account.Id, Opportunity.StageName, Opportunity.RFQ_Received_date__c, 
                                                                                     Product2.ProductCode, Product2.Dimension__c, Product2.Coating__c, Product2.Weight__c, 
                                                                                     Product2.Washer__c, Product2.Patch__c, Product2.Patch_length__c, Product2.Extra_Feature_1000__c,
                                                                                     Product2.Alias__c, Product2.Drawing_Portal_URL__c
                                                                                FROM OpportunityLineItem
                                                                               WHERE (ProductCode IN :productCodes OR (Product2.Alias__c != null AND Product2.Alias__c IN :productCodes)) AND OpportunityId != :oppId]);
        
        
        for(OpportunityLineItem oli : olis) {
            String selected = '';
            String selectedName = '';
            Boolean manual = false;
            List<Contract> linkedContracts = new List<Contract>();
            List<Bid__c> linkedBids = new List<Bid__c>();
            List<OpportunityLineItem> linkedOlis2 = new List<OpportunityLineItem>();
            for(Contract c : contracts) {
                if((c.ProductCode__c == oli.ProductCode && c.ProductCode__c <> null) || (c.Part__r.Alias__c <> null && c.Part__r.Alias__c == oli.ProductCode) || (c.ProductCode__c == oli.Product2.Alias__c && oli.Product2.Alias__c <> null)) {
                    linkedContracts.add(c);
                } 
                if(c.Id == oli.Contract__c) {
                    selected = c.Id;
                    selectedName = c.CurrencyISOCode + ' ' + (c.Purchase_Price__c <> null ? c.Purchase_Price__c : c.Naked_Sales_Price__c) + ' (' + c.Account.Name + ')';
                }
            }
            for(Bid__c b : bids) {
                if(b.Bidding__c == oli.Bidding__c) {
                    linkedBids.add(b);
                }
                if(b.Id == oli.Bid__c) {
                    selected = b.Id;
                    selectedName = b.CurrencyISOCode + ' ' + b.Unit_Price__c + ' (' + b.Supplier__r.Name + ')';
                }
            }
            for(OpportunityLineItem lo : linkedOlis) {
                if((lo.ProductCode == oli.ProductCode && lo.ProductCode <> null) || (lo.Product2.Alias__c == oli.ProductCode && lo.Product2.Alias__c <> null) || (lo.ProductCode == oli.Product2.Alias__c && lo.ProductCode <> null)) {
                    linkedOlis2.add(lo);
                }
            }
            if(oli.Manual_Price__c <> null) {
//                selected = '';
                selectedName = oli.Opportunity.CurrencyISOCode + ' ' + oli.Manual_Price__c + ' (Manual)';
                manual = true;
            }
            
            List<Decimal> resultCost = CostModelBolts_Controller.getPart(oli);
            String missingFields = CostModelBolts_Controller.getMissingFields(oli);
            
            OppLineItem_Contract_Bid ocb = new OppLineItem_Contract_Bid();
            ocb.oppLineItem = oli;
            ocb.contracts = linkedContracts;
            ocb.bids = linkedBids;
            ocb.olis = linkedOlis2;
            ocb.selected = selected;
            ocb.currencyISOCodeOpp = oli.Opportunity.CurrencyISOCode;
            if(selectedName <> '') selectedName = ' - ' + selectedName;
//            String s = oli.Quantity + '';
//            s = s.left(s.length()-3).reverse().replaceAll('.{3}', '$0.').reverse();
//            if(s.startsWith('.')) s = s.right(s.length()-1);
            String s = oli.Quantity.format();
            ocb.selectedName = ' - VOL ' + s + (oli.Buyer__r.Name <> null ? ', ' + oli.Buyer__r.Name : '') + ')' + selectedName;
            ocb.manual = manual;
            ocb.missingFields = missingFields;
            ocb.cost = resultCost[0];
            ocb.TO = resultCost[1];
            ocb.MOQ = resultCost[2];
            ocb.TO_MOQ = resultCost[3];
            ocbs.add(ocb);
        }
        
        */
        
        for(OpportunityLineItem oli : olis) {
            String selected = '';
            String selectedName = '';
            Boolean manual = false;
            OppLineItem_Contract_Bid ocb = new OppLineItem_Contract_Bid();
            if(oli.Contract__c != null) {
                selected = oli.Contract__c;
                selectedName = oli.Contract__r.CurrencyISOCode + ' ' + (oli.Contract__r.Purchase_Price__c <> null ? oli.Contract__r.Purchase_Price__c : oli.Contract__r.Naked_Sales_Price__c) + ' (' + oli.Contract__r.Account.Name + ')';
            }
            if(oli.Bid__c != null) {
                selected = oli.Bid__c;
                selectedName = oli.Bid__r.CurrencyISOCode + ' ' + oli.Bid__r.Unit_Price__c + ' (' + oli.Bid__r.Supplier__r.Name + ')';
            }
            if(oli.Manual_Price__c <> null) {
                selectedName = oli.Opportunity.CurrencyISOCode + ' ' + oli.Manual_Price__c + ' (Manual)';
                manual = true;
            }
            List<Decimal> resultCost = CostModelBolts_Controller.getPart(oli);
            String missingFields = CostModelBolts_Controller.getMissingFields(oli);
            ocb.oppLineItem = oli;
            //ocb.contracts = linkedContracts;
            //ocb.bids = linkedBids;
            //ocb.olis = linkedOlis2;
            ocb.selected = selected;
            ocb.currencyISOCodeOpp = oli.Opportunity.CurrencyISOCode;
            if(selectedName <> '') selectedName = ' - ' + selectedName;
            String s = oli.Quantity.format();
            ocb.selectedName = ' - VOL ' + s + (oli.Buyer__r.Name <> null ? ', ' + oli.Buyer__r.Name : '') + ')' + selectedName;
            ocb.manual = manual;
            ocb.missingFields = missingFields;
            ocb.cost = resultCost[0];
            ocb.TO = resultCost[1];
            ocb.MOQ = resultCost[2];
            ocb.TO_MOQ = resultCost[3];
            ocbs.add(ocb);
        }
        
        System.debug('OCBS: ' + ocbs);
        return ocbs;
    }
        
    @auraEnabled
    public static void addBidding(Id oli, Id oppId, Boolean asia, Boolean europe, Boolean usa) {
        system.debug('addBidding: ' + oppId);
        system.debug('oli: ' + oli);
        system.debug('asia: ' + asia);
        system.debug('europe: ' + europe);
        system.debug('usa: ' + usa);
        
        List<OpportunityLineItem> oliNews = new List<OpportunityLineItem>([SELECT Id, Bidding__c, OpportunityId, Quantity, Bidding_Included__c, Count__c, ServiceDate, Buyer__c, Buyer__r.Id, 
                                             Discount, Drawing_Approval_Needed__c, Drawing_Approved__c, Description, ListPrice, Manual_Price__c,
                                             Manual_Price_Reason__c, Margin__c, Product2Id, ProductCode, Prototype__c, UnitPrice, Bid__c, 
                                             Contract__c, Subtotal, TF_Prototype__c, CurrencyIsoCode, PricebookEntryId, PricebookEntry.CurrencyIsoCode FROM OpportunityLineItem WHERE id = :oli]);
        system.debug('oliNews: ' + oliNews);
        OpportunityLineItem oliNew = (oliNews.size() > 0 ? oliNews[0] : null);
        system.debug('oliNew: ' + oliNew);
        List<Bidding__c> masterBiddings = new List<Bidding__c>([SELECT Id FROM Bidding__c WHERE Opportunity__c = :oliNew.OpportunityId AND Master_Bidding__c = true]);
        system.debug('masterBiddings: ' + masterBiddings);

        //Copy from Master Bidding
        if(masterBiddings.size() > 0) {
            system.debug('masterBiddings exists');
            Bidding__c b = masterBiddings[0].clone(false, true, true, true);
            b.Opportunity__c = oliNew.OpportunityId;
            b.Part__c = oliNew.Product2Id;
            b.Quantity__c = oliNew.Quantity;
            b.Prototype__c = oliNew.Prototype__c;
            b.Buyer__c = oliNew.Buyer__c;
            b.Master_Bidding__c = false;
            insert b;
            
            List<Bid__c> bi = new List<Bid__c>([SELECT Supplier__c, Supplier_Score__c, RFQ_by_Email__c FROM Bid__c WHERE Bidding__c = :masterBiddings[0].Id]);
            List<Bid__c> newBi = new List<Bid__c>();
            for(Bid__c bid : bi) {
                Bid__c bid1 = new Bid__c(Supplier__c = bid.Supplier__c,
                                         Supplier_Score__c = bid.Supplier_Score__c,
                                         RFQ_by_Email__c = bid.RFQ_by_Email__c,
                                         Bidding__c = b.Id);
                newBi.add(bid1);
            }
            System.debug(newBi);
            insert newbi;
            
            oliNew.Bidding__c = b.id;
            update oliNew;
        } else { 
            system.debug('no masterBidding');
            Bidding__c b = new Bidding__c();
            b.Asia__c = asia;
            b.Europe__c = europe;
            b.USA__c = usa;
            b.Opportunity__c = oliNew.OpportunityId;
            b.Part__c = oliNew.Product2Id;
            b.Quantity__c = oliNew.Quantity;
            b.Prototype__c = oliNew.Prototype__c;
            b.Buyer__c = oliNew.Buyer__c;
            insert b;
            
            Opportunity opp = [SELECT Id, DTNA__c, CurrencyIsoCode FROM Opportunity WHERE Id = :oppId];
            system.debug('opp: ' + opp);
            system.debug('opp DTNA__c: ' + opp.DTNA__c);
            system.debug('opp currency: ' + opp.CurrencyIsoCode);
            oliNew.Bidding__c = b.id;
            OpportunityLineItem oli1;
            OpportunityLineItem oli2;
            if(opp.DTNA__c) {
                system.debug('oliNew: ' + oliNew);
                system.debug('oliNew CurrencyIsoCode : ' + oliNew.CurrencyIsoCode);
                system.debug('oliNew PricebookEntryId: ' + oliNew.PricebookEntryId);
                system.debug('oliNew PricebookEntry CurrencyIsoCode: ' + oliNew.PricebookEntry.CurrencyIsoCode);
                oli1 = oliNew.clone(false, true, true, true);
                oli2 = oliNew.clone(false, true, true, true);
                system.debug('oli1: ' + oli1);
                system.debug('oli1 currency: ' + oli1.CurrencyIsoCode);
                system.debug('oli1 PricebookEntryId: ' + oli1.PricebookEntryId);
                system.debug('oli1 PricebookEntry CurrencyIsoCode: ' + oli1.PricebookEntry.CurrencyIsoCode);
                system.debug('oli2: ' + oli2);
                system.debug('oli2 currency: ' + oli2.CurrencyIsoCode);
                system.debug('oli2 PricebookEntryId: ' + oli1.PricebookEntryId);
                system.debug('oli2 PricebookEntry CurrencyIsoCode: ' + oli2.PricebookEntry.CurrencyIsoCode);
                insert new List<OpportunityLineItem>{oli1, oli2};
                oli1.Bidding__c = b.id;            
                oli2.Bidding__c = b.id;
            }
            
            update oliNew;
                    
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>(
                [SELECT Id, Bidding__c, Product2.Region__c, Product2.Commodity_L1__c, Product2.Commodity_L2__c, Product2.Commodity_L3__c, Product2.Commodity_L4__c
                   FROM OpportunityLineItem
                  WHERE Bidding__c = :b.id]);
            System.debug('oppLineItems: ' + oppLineItems);
            Map<Id, OpportunityLineItem> oppLineItemsMap = new Map<Id, OpportunityLineItem>();
            for(OpportunityLineItem oli3 : oppLineItems) {
                oppLineItemsMap.put(oli3.Bidding__c, oli3);
            }
            System.debug('oppLineItemsMap: ' + oppLineItemsMap);
            
            List<Commodity_Matrix__c> commMatrix = new List<Commodity_Matrix__c>(
                [SELECT Id, Account_Supplier__c, Own_Manufacturing__c, Region__c, Subcontractor__c, Supplier_Score__c,
                        Commodity_L1__c, Commodity_L2__c, Commodity_L3__c, Commodity_L4__c
                   FROM Commodity_Matrix__c
                  WHERE Supplier_Score__c = '1' OR Supplier_Score__c = '2']);
           
            List<Bid__c> toInsert = new List<Bid__c>();
            List<Id> suppliers = new List<Id>();
            
            for(Commodity_Matrix__c cm : commMatrix) {
                
            OpportunityLineItem oli3 = oppLineItemsMap.get(b.Id);
            if(oli3 != null) {
                if(((asia && cm.Region__c == 'Asia') || (europe && cm.Region__c == 'Europe') || (usa && cm.Region__c == 'USA') || cm.Region__c == 'Global')
               //     if((oli3.Product2.Region__c <> null && (oli3.Product2.Region__c.contains(cm.Region__c) || oli3.Product2.Region__c == 'Global')) 
                       && (oli3.Product2.Commodity_L1__c <> null && oli3.Product2.Commodity_L1__c.equals(cm.Commodity_L1__c)) 
                       && (oli3.Product2.Commodity_L2__c == null || cm.Commodity_L2__c == null || oli3.Product2.Commodity_L2__c.equals(cm.Commodity_L2__c)) 
                       && (oli3.Product2.Commodity_L3__c == null || cm.Commodity_L3__c == null || oli3.Product2.Commodity_L3__c.equals(cm.Commodity_L3__c)) 
                       && (oli3.Product2.Commodity_L4__c == null || cm.Commodity_L4__c == null || oli3.Product2.Commodity_L4__c.equals(cm.Commodity_L4__c)) 
                      ) {  
                          System.debug('Suppliers: ' + suppliers);
                          System.debug(cm.Account_Supplier__c);
                          if(!suppliers.contains(cm.Account_Supplier__c)) {
                              Bid__c b2 = new Bid__c(
                                  Bidding__c = b.Id,
                                  Supplier__c = cm.Account_Supplier__c,
                                  Supplier_Score__c = cm.Supplier_Score__c,
                                  Quantity__c = oliNew.Quantity);
                              toInsert.add(b2);
                              suppliers.add(cm.Account_Supplier__c);
                          }
                    }
                }
            }
            System.debug('toInsert: ' + toInsert);
            insert toInsert;
        }
    }
    
    @auraEnabled
    public static Id getMasterBiddingId(Id oppId) {        
        List<Bidding__c> masterBiddings = new List<Bidding__c>([SELECT Id FROM Bidding__c WHERE Opportunity__c = :oppId AND Master_Bidding__c = true]);
        if(masterBiddings.size() > 0) {
            return masterBiddings[0].Id;
        } else {
            return null;
        }
    }
    
    @auraEnabled
    public static Bidding__c getMasterBidding(Id oppId) {        
        List<Bidding__c> masterBiddings = new List<Bidding__c>([SELECT Id, Name FROM Bidding__c WHERE Opportunity__c = :oppId AND Master_Bidding__c = true]);
        if(masterBiddings.size() > 0) {
            return masterBiddings[0];
        } else {
            return null;
        }
    }
        
    @auraEnabled
    public static String selectContract(String ids) {
        Id cId = ids.substringBeforeLast('-');
        Id oliId = ids.substringAfterLast('-');
        System.debug('Select Contract: ' + cId + ' - ' + oliId);
        OpportunityLineItem oli = [SELECT Id, Bid__c, Contract__c, Quantity FROM OpportunityLineItem WHERE id = :oliId];
        oli.Bid__c = null;
        oli.Contract__c = cId;
        Decimal d1 = [SELECT Purchase_Price__c FROM Contract WHERE Id = :cId].Purchase_Price__c;
        Decimal d2 = [SELECT Naked_Sales_Price__c FROM Contract WHERE Id = :cId].Naked_Sales_Price__c;
//        oli.UnitPrice = d;
        Decimal d = (d1 <> null ? d1 : d2); 
        oli.TotalPrice = d * oli.Quantity / 1000;
        update oli;
        return oliId;
    }
        
    @auraEnabled
    public static String deselectContract(String ids) {
        Id cId = ids.substringBeforeLast('-');
        Id oliId = ids.substringAfterLast('-');
        System.debug('Deselect Contract: ' + cId + ' - ' + oliId);
        OpportunityLineItem oli = [SELECT Id, Bid__c, Contract__c, Quantity FROM OpportunityLineItem WHERE id = :oliId];
        oli.Bid__c = null;
        oli.Contract__c = null;
        oli.UnitPrice = 0;
//        oli.TotalPrice = 0;
        update oli;
        return oliId;
        
    }
        
    @auraEnabled
    public static String selectBid(String ids) {
        Id bId = ids.substringBeforeLast('-');
        Id oliId = ids.substringAfterLast('-');
        System.debug('Select Bid: ' + bId + ' - ' + oliId);
        OpportunityLineItem oli = [SELECT Id, Bid__c, Contract__c, Quantity, OpportunityId FROM OpportunityLineItem WHERE id = :oliId];
        
        Id oldBidId = oli.Bid__c;
        if (oldBidId != null && oldBidId != bId){
            Bid__c oldBid = [SELECT Opportunity_Part_Id__c FROM Bid__c WHERE Id = :oldBidId LIMIT 1];
            oldBid.Opportunity_Part_Id__c = '';
            update oldBid;
        }
        
        oli.Bid__c = bId;
        oli.Contract__c = null;
        
        Bid__c theBid = [SELECT Unit_Price__c FROM Bid__c WHERE Id = :bId LIMIT 1];
        //Decimal d = [SELECT Unit_Price__c FROM Bid__c WHERE Id = :bId].Unit_Price__c;
//        oli.UnitPrice = d;

        Decimal d = theBid.Unit_Price__c;
        oli.TotalPrice = d * oli.Quantity / 1000;
        update oli;
        
        theBid.Opportunity_Part_Id__c = oli.Id;
        update theBid;
        
        return oliId;
    }
        
    @auraEnabled
    public static String deselectBid(String ids) {
        Id bId = ids.substringBeforeLast('-');
        Id oliId = ids.substringAfterLast('-');
        System.debug('Deselect Bid: ' + bId + ' - ' + oliId);
        OpportunityLineItem oli = [SELECT Id, Bid__c, Contract__c FROM OpportunityLineItem WHERE id = :oliId];
        oli.Bid__c = null;
        oli.Contract__c = null;
        oli.UnitPrice = 0;
//        oli.TotalPrice = 0;
        update oli;
        
        Bid__c theBid = [SELECT Opportunity_Part_Id__c FROM Bid__c WHERE Id = :bId LIMIT 1];
        theBid.Opportunity_Part_Id__c = null;
        update theBid;
        
        return oliId;
        
    }
    
/*    @auraEnabled
    public static void deleteOppLineItem (Id oliId) {
        System.debug(oliId);
        OpportunityLineItem oli = [SELECT Id, Bid__c, Contract__c FROM OpportunityLineItem WHERE id = :oliId];
        System.debug(oli);
        delete oli;
    }
*/
    
    @auraEnabled
    public static void saveOppLineItem (OpportunityLineItem oli) {
        system.debug('Manual_Price__c: ' + oli.Manual_Price__c);
        system.debug('Quantity: ' + oli.Quantity);
        system.debug('TotalPrice: ' + oli.TotalPrice);
        oli.TotalPrice = (oli.Manual_Price__c <> null ? oli.Quantity * oli.Manual_Price__c / 1000 : 0);
        update oli;        
    }
    
    @auraEnabled
    public static void deleteManualPriceOppLineItem (OpportunityLineItem oli) {
        oli.Manual_Price__c = null;
        oli.Manual_Price_Reason__c = null;
        if(oli.Bid__c <> null) {
            oli.TotalPrice = oli.Quantity * [SELECT Unit_Price__c FROM Bid__c WHERE Id = :oli.Bid__c].Unit_Price__c / 1000;
        } else if(oli.Contract__c <> null) {
            Contract c = [SELECT Purchase_Price__c, Naked_Sales_Price__c FROM Contract WHERE Id = :oli.Contract__c];
            oli.TotalPrice = oli.Quantity * (c.Purchase_Price__c <> null ? c.Purchase_Price__c : c.Naked_Sales_Price__c) / 1000;
        } else {
            oli.TotalPrice = 0;
        }
        
        update oli;        
    }
    
    @auraEnabled
    public static void deleteOppLineItem (OpportunityLineItem oli) {
        System.debug(oli);
        delete oli;        
    }
    
    @auraEnabled
    public static OpportunityLineItem createNewPart (Id oppId) {
        opportunityId = oppId;
        return new OpportunityLineItem(OpportunityId = oppId);      
    }
    
    @auraEnabled
    public static String saveNewPart (OpportunityLineItem oli, Id oppId) {
//        oli.OpportunityId = opportunityId;
        Product2 part = [SELECT Id, Steering_committee_approval_needed__c, Steering_committee_approved__c FROM Product2 WHERE Id = :oli.Product2Id];
                System.debug('Buyer: ' + oli.Buyer__c);
        String error = '';
        oli.TotalPrice = 0;
        oli.OpportunityId = oppId;
        if(oli.Quantity == null) {
            error = 'Quantity is required.';
        } else if (part.Steering_committee_approval_needed__c && !part.Steering_committee_approved__c) {
            error = 'For this part Steering Committeee approval is needed.';
        } else {
            try {
                
                Pricebook2 pb = [SELECT Id FROM Pricebook2 LIMIT 1];
                System.debug(pb);
                Opportunity opp = [SELECT Id, CurrencyIsoCode FROM Opportunity WHERE Id = :oppId LIMIT 1];
                System.debug(pb.Id);
                System.debug(part.Id);
                System.debug(oli);
                List<PricebookEntry> pbEs = new List<PricebookEntry>([SELECT Id FROM PricebookEntry WHERE IsActive = true AND Pricebook2Id = :pb.Id AND Product2Id = :part.Id AND CurrencyIsoCode = :opp.CurrencyISOCode]);
                System.debug(pbEs);
                PricebookEntry pbE;
                    if(pbEs.size() == 0) {
                        pbE = new PricebookEntry(
                            IsActive = true,
                            Pricebook2Id = pb.Id,
                            Product2Id = part.Id,
                            UnitPrice = 0,
                            UseStandardPrice = false,
                            CurrencyIsoCode = opp.CurrencyISOCode
                        );
                        insert pbE; 
                    } else {
                        pbE = pbEs[0];
                    }
                oli.PricebookEntryId = pbE.Id;
                System.debug('******' + oli);
                insert oli;  
            } catch (Exception e) {
                error = e.getMessage();
            }
        }
        return error;
    }
    
    @auraEnabled
    public static void deletePart (OpportunityLineItem oli) {
        Deleted_Opportunity_Part__c dop = new Deleted_Opportunity_Part__c();
        dop.Opportunity__c = oli.OpportunityId;        
        dop.Part__c = oli.Product2Id;
        dop.Quantity__c = oli.Quantity;
        insert dop;
        delete oli;        
    }
    
    @auraEnabled
    public static void calculatePercentage (Id oppId, Decimal perc) {
        system.debug('oppId: ' + oppId);
        system.debug('perc: ' + perc);
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>([SELECT Id, Bid__r.Unit_Price__c, Buyer__c, Buyer__r.Id, 
                                                                        Contract__r.Purchase_Price__c, Manual_Price__c, Product2Id,
                                                                        Product2.Alias__c, ProductCode, Contract__c
                                                                        FROM OpportunityLineItem WHERE OpportunityId = :oppId]);
        system.debug('olis: ' + olis);
        Set<Id> productIds = new Set<Id>();
        Set<String> productCodes = new Set<String>();
        for(OpportunityLineItem oli : olis) {
            productIds.add(oli.Product2Id);
            if (oli.ProductCode != '' && oli.ProductCode != null){
                productCodes.add(oli.ProductCode);
            }
            if (oli.Product2.Alias__c != '' && oli.Product2.Alias__c != null){
                productCodes.add(oli.Product2.Alias__c);
            }
        }
        system.debug('productIds: ' + productIds);
        system.debug('productCodes: ' + productCodes);
        
        List<Contract> contracts = new List<Contract>([SELECT Id, Name, Purchase_Price__c, Part__c, ProductCode__c, Part__r.Alias__c
                                                         FROM Contract
                                                        WHERE
                                                        //Part__c IN :productIds
                                                        (ProductCode__c IN :productCodes OR Part__r.Alias__c IN :productCodes)
                                                        AND RecordType.DeveloperName = 'Supplier_Contract' AND (NOT Account.Name LIKE '%FACIL%')
                                                     ORDER BY Quantity__c ASC]);
        
        system.debug('contracts: ' + contracts);
        for(OpportunityLineItem oli : olis) {
            system.debug('one OLI');
            system.debug('oli.Bid__r.Unit_Price__c: ' + oli.Bid__r.Unit_Price__c);
            system.debug('oli.Manual_Price__c: ' + oli.Manual_Price__c);
            if(oli.Bid__r.Unit_Price__c <> null && oli.Manual_Price__c == null) {
                system.debug('case 1');
                oli.Manual_Price__c = oli.Bid__r.Unit_Price__c*(1 + perc/100);
                oli.UnitPrice = (oli.Bid__r.Unit_Price__c*(1 + perc/100))/1000;
                system.debug('oli.Manual_Price__c NEW: ' + oli.Manual_Price__c);
                system.debug('oli.UnitPrice NEW: ' + oli.UnitPrice);
            } else if (oli.Manual_Price__c == null) {
                system.debug('case 2');
                Contract contr = new Contract();
                Boolean foundContract = false;
                for (Contract c : contracts) {
                    if (!foundContract){
                        system.debug('one contract');
                        //if(c.Part__c == oli.Product2Id) {
                        if((c.ProductCode__c == oli.ProductCode && c.ProductCode__c <> null) || (c.Part__r.Alias__c <> null && c.Part__r.Alias__c == oli.ProductCode) || (c.ProductCode__c == oli.Product2.Alias__c && oli.Product2.Alias__c <> null)) {
                            if (c.Id == oli.Contract__c){
                                system.debug('the selected contract');
                                contr = c;
                                foundContract = true;
                            }
                        }
                    }
                }
                if (!foundContract){
                    for (Contract c : contracts) {
                        system.debug('one contract');
                        //if(c.Part__c == oli.Product2Id) {
                        if((c.ProductCode__c == oli.ProductCode && c.ProductCode__c <> null) || (c.Part__r.Alias__c <> null && c.Part__r.Alias__c == oli.ProductCode) || (c.ProductCode__c == oli.Product2.Alias__c && oli.Product2.Alias__c <> null)) {
                            contr = c;
                            foundContract = true;
                        }
                    }
                }
                system.debug('contr: ' + contr);
                if(foundContract) {
                    if (contr.Purchase_Price__c != null){
                        system.debug('contr.Purchase_Price__c: ' + contr.Purchase_Price__c);
                        oli.Manual_Price__c = contr.Purchase_Price__c*(1 + perc/100);
                        oli.UnitPrice = (contr.Purchase_Price__c*(1 + perc/100))/1000;
                        system.debug('oli.Manual_Price__c NEW: ' + oli.Manual_Price__c);
                        system.debug('oli.UnitPrice NEW: ' + oli.UnitPrice);
                    }
                }
            }
        }
        update olis;        
    }
    
    
    @auraEnabled
    public static String checkURLs (Id oppId) {
        String result = '';
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>([SELECT Id, Product2.Name, Product2.Drawing_Portal_URL__c 
                                                                          FROM OpportunityLineItem 
                                                                         WHERE OpportunityId = :oppId AND Opportunity.Require_part_drawings_for_all_parts__c = TRUE
                                                                                    AND (Product2.Drawing_Portal_URL__c = '' OR Product2.Drawing_Portal_URL__c = null)]);
        for(OpportunityLineItem oli : olis) {
            result = (result == '' ? oli.Product2.Name : result + ', ' + oli.Product2.Name);
        }
        
        return result;
    }
    
    
    /*
    @auraEnabled
    public static boolean sendAllRFQ (Id oppId) {
        Opportunity opp = [SELECT Id, Owner.Email, Owner.Name, RFQ_Contact__c FROM Opportunity WHERE Id = :oppId];
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>([SELECT Id, Product2Id, Quantity, Bidding__r.Id, Bidding__c, Prototype__c FROM OpportunityLineItem WHERE OpportunityId = :oppId]);
        System.debug('oppId: ' + oppId);
        System.debug('olis: ' + olis);
        List<Id> oliIds = new List<Id>();
        List<Id> partIds = new List<Id>();
        List<Id> biddingIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        for(OpportunityLineItem oli : olis) {
            oliIds.add(oli.Id);
            partIds.add(oli.Product2Id);
            biddingIds.add(oli.Bidding__r.Id);
        }
//Add criteria: RFQ has not be sent and it should by email        
        List<Bid__c> bids = new List<Bid__c>([SELECT Id, Bidding__c, Bidding__r.RFQ_due_date__c, RFQ_by_Email__c, RFQ_has_been_sent__c, Description__c, Supplier__r.Name, CurrencyISOCode
                                                FROM Bid__c 
                                               WHERE Bidding__c IN :biddingIds AND RFQ_by_Email__c = true AND RFQ_has_been_sent__c = false]);
        List<Product2> parts = new List<Product2>([SELECT Id, Name, Deviation__c, Dimension__c, Drawing_Number__c, Coating__c, COO__c, Drawing_Revision__c, 
                                                          ProductCode, EAV__c, Washer__c, MOQ__c, Weight__c, Customer__c, 
                                                          Extra_Feature_1000__c, Description, Drawing_Portal_URL__c
                                                   FROM Product2 WHERE Id IN :partIds]);
        
        Set<Bidding__c> biddingsToUpdate = new Set<Bidding__c>();
        Map<Id, List<Bid__c>> accountBidsMap = new Map<Id, List<Bid__c>>();
        Map<Id, Product2> partIdMap = new Map<Id, Product2>();
        for(Product2 part : parts) {
            partIdMap.put(part.Id, part);
        }
        Map<Id, List<Product2>> biddingpartMap = new Map<Id, List<Product2>>();
        Map<Id, Decimal> biddingQuantityMap = new Map<Id, Decimal>();
        Map<Id, Boolean> biddingProtoMap = new Map<Id, Boolean>();
        
        for(Bid__c bid : bids) {
            if(!accountBidsMap.containsKey(bid.Supplier__c)) {
                accountBidsMap.put(bid.Supplier__c, new List<Bid__c>());
            }
            List<Bid__c> newList = accountBidsMap.get(bid.Supplier__c);
            newList.add(bid);
            accountIds.add(bid.Supplier__c);
            accountBidsMap.put(bid.Supplier__c, newList);  
            bid.RFQ_has_been_sent__c = true;
            if(bid.Bidding__r.RFQ_due_date__c == null) {
                biddingsToUpdate.add(new Bidding__c(Id = bid.Bidding__c, RFQ_due_date__c = System.today().addDays(14)));
            }
        }
        
        System.debug('accountBidsMap: ' + accountBidsMap);
        
        for(OpportunityLineItem oli : olis) {
            if(!biddingpartMap.containsKey(oli.Bidding__c)) {
                biddingpartMap.put(oli.Bidding__c, new List<Product2>());
            }
            List<Product2> newList = biddingpartMap.get(oli.Bidding__c);
            newList.add(partIdMap.get(oli.Product2Id));
            biddingpartMap.put(oli.Bidding__c, newList); 
            biddingQuantityMap.put(oli.Product2Id, oli.Quantity);
            biddingProtoMap.put(oli.Product2Id, oli.Prototype__c);
        }
        
        System.debug('biddingpartMap: ' + biddingpartMap);

//Add contact fields               
//Only when RFQ Contact matches
        List<Contact> contacts = new List<Contact>([SELECT Id, AccountId, Active__c, Name, RFQ_Contact_Picklist__c, Email, Salutation, LastName, FirstName FROM Contact WHERE AccountId IN :accountIds]);
        Map<Id, List<Contact>> accountContactMap = new Map<Id, List<Contact>>();
         for(Contact con : contacts) {
             if(!accountContactMap.containsKey(con.AccountId)) {
                 accountContactMap.put(con.AccountId, new List<Contact>());
             }
             List<Contact> newList = accountContactMap.get(con.AccountId);
             newList.add(con);
             accountContactMap.put(con.AccountId, newList);
        }
        System.debug('accountContactMap: ' + accountContactMap);
        
        Integer count = 0;
        for(Id accId : accountBidsMap.keySet()) {
            List<Contact> contactList = accountContactMap.get(accId);
            if(contactList <> null) {
                count+= contactList.size();
            }
        }
        System.debug('Count emails: ' + count);
//        Messaging.reserveSingleEmailCapacity(count);
        System.debug(biddingsToUpdate);
        for(Id accId : accountBidsMap.keySet()) {
            String csvString = 'Facil Code,Facil Item,Description,Drawing nr,Volume,Currency,' 
                + 'Piece Price,Raw Material level,PPAP LT,Serial LT after PPAP approval,Deviation,MOQ,Weight (gr/pc),Coating,'
                + 'Job Coater,Tooling Cost,Tooling Description,Open Remark \n';
            List<Bid__c> bidList = accountBidsMap.get(accId);
            List<Contact> contactList = accountContactMap.get(accId);
                    
            String body = 'There are new biddings available for the next parts: <br/>';
            for(Bid__c bid : bidList) {
                List<Product2> prs = biddingpartMap.get(bid.Bidding__c);
                for(Product2 pr : prs) {
                    body += pr.Name + '(' + pr.Coating__c + ', ' + pr.Deviation__c + ', ' + pr.Dimension__c + ') x' + biddingQuantityMap.get(pr.Id) + '  --> Unique ID: ' + bid.Id + '<br/>';
                    csvString = csvString  + (bid.Id                       <> null ? '' + bid.Id                        : '')
                                     + ',' + (pr.ProductCode               <> null ? '' + pr.ProductCode                : '')
                                     + ',' + (pr.Description               <> null ? '' + pr.Description                : '')
                                     + ',' + (pr.Drawing_Number__c         <> null ? '' + pr.Drawing_Number__c          : '')
                                     + ',' + (biddingQuantityMap.get(pr.Id)<> null ? '' + biddingQuantityMap.get(pr.Id) : '')
                                     + ',' + (bid.CurrencyIsoCode          <> null ? '' + bid.CurrencyIsoCode           : '')
                                     + ',,,,,,,,,,,, \n';
                }
            }
            Attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf(csvString);
            attachment.Name = 'csvFile.csv';
            attachment.ParentId = accId; 
            insert attachment;
            
            body += '<br/><br/>Kind regards, <br/>' + opp.Owner.Name;
            
            if(contactList <> null) {
                for(Contact con : contactList) {   
                    System.debug('comp: ' + con.RFQ_Contact_Picklist__c + ' .. ' + opp.RFQ_Contact__c);
                    if(con.RFQ_Contact_Picklist__c == 'All' || con.RFQ_Contact_Picklist__c == opp.RFQ_Contact__c) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        List<String> toAddresses = new List<String>();
                        toAddresses.add(con.Email); 
                        mail.setToAddresses(toAddresses);
                        mail.setReplyTo(opp.Owner.Email);
                        mail.setSenderDisplayName('Facil - ' + opp.Owner.Name);
                        mail.setSubject('New biddings available');                    
                        mail.setBccSender(false);
                        mail.setUseSignature(false);
                        
                        System.debug('Dear ' + (con.Salutation <> null ? con.Salutation : '') + ' ' + con.LastName + '<br/><br/>' + body);                    
                        mail.setHtmlBody('Dear ' + (con.Salutation <> null ? con.Salutation : '') + ' ' + con.LastName + '<br/><br/>' + body);
                        
                        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                        blob csvBlob = Blob.valueOf(csvString);
                        string csvname= 'Parts.csv';
                        csvAttc.setFileName(csvname);
                        csvAttc.setBody(csvBlob);
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                        
                        try {
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                            System.debug(biddingsToUpdate);
                            update bids;
                            update new List<Bidding__c>(biddingsToUpdate);
                        } catch (Exception e) {
                            System.debug(e.getMessage());
                        }
                        
                    }
                }
            }
            
        }
        
        return true;
        
    }
    */
    @auraEnabled
    public static boolean sendAllRFQToMyself (Id oppId) {
        system.debug('sendAllRFQToMyself');
        Opportunity opp = [SELECT Id, Owner.Email, Owner.Name, RFQ_Contact__c, Bid_Remark__c, Due_Date__c, Opportunity_Number__c, Portal_URL__c FROM Opportunity WHERE Id = :oppId];
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>([SELECT Id, Product2Id, Quantity, Bidding__r.Id, Bidding__c, Prototype__c, Quantity__c, Buyer__c, Buyer__r.Name, Opportunity.Buyer__c, Opportunity.Buyer__r.Name FROM OpportunityLineItem WHERE OpportunityId = :oppId]);
        System.debug('oppId: ' + oppId);
        System.debug('olis: ' + olis);
        
        //Get logged in User
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email, Name From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        String activeUserName = activeUser.Name;
        
        List<Id> oliIds = new List<Id>();
        List<Id> partIds = new List<Id>();
        List<Id> biddingIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        
        for(OpportunityLineItem oli : olis) {
            oliIds.add(oli.Id);
            partIds.add(oli.Product2Id);
            biddingIds.add(oli.Bidding__r.Id);
        }
//Add criteria: RFQ has not be sent and it should by email        
        List<Bid__c> bids = new List<Bid__c>([SELECT Id, Name, Bidding__c, Bidding__r.RFQ_due_date__c, Bidding__r.Bidding_description__c, Bidding__r.Prototype__c, RFQ_by_Email__c, RFQ_has_been_sent__c, Description__c, Supplier__r.Name, CurrencyISOCode
                                                FROM Bid__c 
                                               WHERE Bidding__c IN :biddingIds AND RFQ_has_been_sent__c = false]);
        List<Product2> parts = new List<Product2>([SELECT Id, Name, Deviation__c, Dimension__c, Drawing_Number__c, Coating__c, COO__c, Drawing_Revision__c, 
                                                          ProductCode, EAV__c, Washer__c, MOQ__c, Weight__c, Customer__c, 
                                                          Extra_Feature_1000__c, Description, Drawing_Portal_URL__c
                                                   FROM Product2 WHERE Id IN :partIds]);
        System.debug('Bids: ' + bids);
        System.debug('Parts: ' + parts);
        
        Set<Bidding__c> biddingsToUpdate = new Set<Bidding__c>();
        Map<Id, Set<Bid__c>> accountBidsMap = new Map<Id, Set<Bid__c>>();
        Map<Id, Product2> partIdMap = new Map<Id, Product2>();
        for(Product2 part : parts) {
            partIdMap.put(part.Id, part);
        }
        Map<Id, Set<Product2>> biddingpartMap = new Map<Id, Set<Product2>>();
        Map<String, Decimal> biddingQuantityMap = new Map<String, Decimal>();
        Map<Id, Boolean> biddingProtoMap = new Map<Id, Boolean>();
        
        for(Bid__c bid : bids) {
            if(!accountBidsMap.containsKey(bid.Supplier__c)) {
                accountBidsMap.put(bid.Supplier__c, new Set<Bid__c>());
            }
            Set<Bid__c> newList = accountBidsMap.get(bid.Supplier__c);
            newList.add(bid);
            accountIds.add(bid.Supplier__c);
            accountBidsMap.put(bid.Supplier__c, newList);  
            bid.RFQ_has_been_sent__c = true;
            bid.RFQ_mail_to_myself__c = true;
            if(bid.Bidding__r.RFQ_due_date__c == null) {
                biddingsToUpdate.add(new Bidding__c(Id = bid.Bidding__c, RFQ_due_date__c = System.today().addDays(14)));
            }
        }
        
        System.debug('accountBidsMap: ' + accountBidsMap);
        
        Map<Id, Map<Id, String>> buyerMap = new Map<Id, Map <Id, String>>();
        for(OpportunityLineItem oli : olis) {
            if(!biddingpartMap.containsKey(oli.Bidding__c)) {
                biddingpartMap.put(oli.Bidding__c, new Set<Product2>());
            }
            Set<Product2> newList = biddingpartMap.get(oli.Bidding__c);
            newList.add(partIdMap.get(oli.Product2Id));
            biddingpartMap.put(oli.Bidding__c, newList); 
            biddingQuantityMap.put(oli.Product2Id + '-' + oli.Bidding__c, oli.Quantity);
            biddingProtoMap.put(oli.Product2Id, oli.Prototype__c);
            
            if (oli.Buyer__c != null){
                Map <Id, String> auxMap = new Map <Id, String>();
                if (!buyerMap.containsKey(oli.Bidding__c)){
                    auxMap.put(oli.Product2Id, oli.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
                else{
                    auxMap = buyerMap.get(oli.Bidding__c);
                    auxMap.put(oli.Product2Id, oli.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
            }
            else if (oli.Opportunity.Buyer__c != null){
                Map <Id, String> auxMap = new Map <Id, String>();
                if (!buyerMap.containsKey(oli.Bidding__c)){
                    auxMap.put(oli.Product2Id, oli.Opportunity.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
                else{
                    auxMap = buyerMap.get(oli.Bidding__c);
                    auxMap.put(oli.Product2Id, oli.Opportunity.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
            }
        }
        
        System.debug('biddingpartMap: ' + biddingpartMap);

//Add contact fields               
//Only when RFQ Contact matches
        List<Contact> contacts = new List<Contact>([SELECT Id, AccountId, Active__c, Name, RFQ_Contact_Picklist__c, Email, Salutation, LastName, FirstName FROM Contact WHERE AccountId IN :accountIds]);
        Map<Id, List<Contact>> accountContactMap = new Map<Id, List<Contact>>();
         for(Contact con : contacts) {
             if(!accountContactMap.containsKey(con.AccountId)) {
                 accountContactMap.put(con.AccountId, new List<Contact>());
             }
             List<Contact> newList = accountContactMap.get(con.AccountId);
             newList.add(con);
             accountContactMap.put(con.AccountId, newList);
        }
        System.debug('accountContactMap: ' + accountContactMap);
        
        Integer count = 0;
        for(Id accId : accountBidsMap.keySet()) {
            List<Contact> contactList = accountContactMap.get(accId);
            if(contactList <> null) {
                count+= contactList.size();
            }
        }
        System.debug('Count emails: ' + count);
//        Messaging.reserveSingleEmailCapacity(count);
        System.debug(biddingsToUpdate);
        
        Messaging.Email[] messages = new Messaging.Email[0];
        
        for(Id accId : accountBidsMap.keySet()) {
            String csvString = 'Facil Code,Facil Item,Description,Drawing nr,Volume,Currency,' 
                + 'Piece Price / 1000,Raw Material level,PPAP LT incl SST/ACT,Serial LT after PPAP approval,Deviation,MOQ,Weight (gr/pc),Coating,'
                + 'Job Coater,Tooling Cost,Tooling Description,Open Remark \n';
            Set<Bid__c> bidList = accountBidsMap.get(accId);
            List<Contact> contactList = accountContactMap.get(accId);
            
            String body = '<p style="font-family:Segoe UI;font-size:10pt;">'
                + 'Dear supplier, <br/><br/>'
                + 'Can you please send us your quotation according the conditions mentioned in this RFQ unless otherwise agreed between both parties. <br/><br/>'
                + 'Your quotation should include: <br/>'
                + '-    Piece price <br/>'
                + '-    Currency: please offer in your local currency and clearly indicate this in your offer <br/>'
                + '-    Raw Material Level (E.g. Q1 2018) <br/>'
                + '-    PPAP LT including SST/ACT <br/>'
                + '-    Serial LT after PPAP approval <br/>'
                + '-    Deviation in case your offer is not 100% according to drawing <br/>'
                + '-    MOQ <br/>'
                + '-    Part Weight <br/>'
                + '-    Tooling Cost and description (in case applicable) <br/><br/>'
                + '-    RFQ Number ' + opp.Portal_URL__c.substringAfterLast('=') + '<br/><br/>'
                + 'The parts to be quoted:<br/>'
                + '------------------------- <br/>';
                
            Integer i = 1;
            String RFQDate = '';
            System.debug('bidList: ' + bidList);
            for(Bid__c bid : bidList) {
                Set<Product2> prs = biddingpartMap.get(bid.Bidding__c);
                System.debug('Set: ' + prs);
                for(Product2 pr : prs) {
                    body += i  + '<br/>';
//                    body += 'Partnumber: '    + (pr.ProductCode               <> null ? '' + pr.ProductCode                : '') + '<br/>';
//                    body += 'Description: '   + (pr.Description               <> null ? '' + pr.Description                : '') + '<br/>';
                    body += 'Part Name: '   + (pr.Name <> null ? '' + pr.Name : '') + '<br/>';
//                    String s22 = (biddingQuantityMap.get(pr.Id + '-' + bid.Bidding__c)) + '';
//                  s22 = s22.left(s22.length()-3).reverse().replaceAll('.{3}', '$0.').reverse();
                    String s22 = (biddingQuantityMap.get(pr.Id + '-' + bid.Bidding__c)).format();
                    if(s22.startsWith('.')) s22 = s22.right(s22.length()-1);
                    body += 'Annual volume: ' + (s22 <> null ? '' + s22 : '') + '<br/>';
                    body += 'Drawing: '       + (pr.Drawing_Number__c         <> null ? '' + pr.Drawing_Number__c          : '') + '<br/>';
                    body += 'Description: '       + (bid.Bidding__r.Bidding_description__c         <> null ? '' + bid.Bidding__r.Bidding_description__c          : '') + '<br/>';
                    body += 'Prototype: '       + (bid.Bidding__r.Prototype__c ? 'Yes' : 'No') + '<br/>';
                    if (buyerMap.containsKey(bid.Bidding__c)){
                        if (buyerMap.get(bid.Bidding__c).containsKey(pr.Id)){
                            body += 'Part Buyer: ' + buyerMap.get(bid.Bidding__c).get(pr.Id) + '<br/>';
                        }
                    }
                    body += '<br/>';
                    i++;
                    body += 'The drawings can be found on the Facil website: https://portal.facil.be <br/><br/>';
                    
                    csvString = csvString  + (bid.Id                       <> null ? '' + bid.Id                        : '')
                                     + ',' + (pr.ProductCode               <> null ? '' + pr.ProductCode                : '')
                                     + ',' + (pr.Description               <> null ? '' + pr.Description                : '')
                                     + ',' + (pr.Drawing_Number__c         <> null ? '' + pr.Drawing_Number__c          : '')
                                     + ',' + (s22 <> null ? '' + s22 : '')
                                     + ',' + (bid.CurrencyIsoCode          <> null ? '' + bid.CurrencyIsoCode           : '')
                                     + ',,,,,,,,,,,, \n';
                }
                RFQDate = opp.Due_Date__c.format() + '';
            }
            
            body += 'Conditions (unless otherwise agreed between both parties) <br/>'
                + '---------- <br/>'
                + '- Payment conditions 90 days end of month <br/>'
                + '- Quality Expectations according general quality requirements: free of charge or included in the piece price <br/>'
                + '- PPAP level 3 <br/><br/>'
                + 'Deadline for quotation: ' + RFQDate + '<br/><br/>'
                + 'Unless otherwise stated, the Facil General Purchase Conditions are applicable. <br/><br/>'
                + 'Remarks: <br/>'
                + '-------- <br/>'
                + (opp.Bid_Remark__c <> null ? opp.Bid_Remark__c : '') + '<br/><br/>'
                + 'If you have any further questions concerning this RFQ, do not hesitate to contact us. <br/>'
                + 'Your contact for this RFQ is: <br/>'
                + activeUserName + '<br/><br/><br/><p>';
            
            System.debug(body); 

            Attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf(csvString);
            attachment.Name = 'csvFile.csv';
            attachment.ParentId = accId; 
            insert attachment;
            
            if(contactList <> null) {
                for(Contact con : contactList) {   
                    System.debug('comp: ' + con.RFQ_Contact_Picklist__c + ' .. ' + opp.RFQ_Contact__c);
                    if(con.RFQ_Contact_Picklist__c == 'All' || con.RFQ_Contact_Picklist__c == opp.RFQ_Contact__c) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        List<String> toAddresses = new List<String>();
//                        toAddresses.add(con.Email); 
//                        Mail to logged in user
                        if(userEmail <> null) {
                            toAddresses.add(userEmail);                         
                            mail.setToAddresses(toAddresses);
                            mail.setReplyTo(opp.Owner.Email);
                            mail.setSenderDisplayName('Facil - ' + opp.Owner.Name);
                            mail.setSubject('New RFQ available: RFQ number ' + opp.Portal_URL__c.substringAfterLast('='));                    
                            mail.setBccSender(false);
                            mail.setUseSignature(false);
                            
    //                        System.debug('Dear ' + (con.Salutation <> null ? con.Salutation : '') + ' ' + con.LastName + '<br/><br/>' + body);                    
                            mail.setHtmlBody(body);
                            
                            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                            blob csvBlob = Blob.valueOf(csvString);
                            string csvname= 'Parts.csv';
                            csvAttc.setFileName(csvname);
                            csvAttc.setBody(csvBlob);
                            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                            messages.add(mail);
                        }
                    }
                }
            }
        }
        
        try {
            System.debug('updating biddings: ' + biddingsToUpdate);
            System.debug('updating bids: ' + bids);
            if (!bids.isEmpty()){
                update bids;
            }
            if (!biddingsToUpdate.isEmpty()){
                update new List<Bidding__c>(biddingsToUpdate);
            }
        } catch (Exception e) {
            System.debug('ERROR UPDATING BID: ' + e.getMessage());
        }
        
        system.debug('messages: ' + messages);
        try{
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages);
            system.debug('results: ' + results);
        }
        catch(Exception ex){
            system.debug('error sending emails: ' + ex.getMessage());
        }
        //Messaging.sendEmail(messages);
        
        return true;
        
    }
    
    
    @auraEnabled
    public static boolean sendAllRFQToSupplierMail (Id oppId) {
        system.debug('sendAllRFQToSupplierMail');
        Opportunity opp = [SELECT Id, Owner.Email, Owner.Name, RFQ_Contact__c, Responsible_User__c, Bid_Remark__c, Due_Date__c, Opportunity_Number__c, Portal_URL__c FROM Opportunity WHERE Id = :oppId];
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>([SELECT Id, Product2Id, Quantity, Bidding__r.Id, Bidding__c, Prototype__c, Buyer__c, Buyer__r.Name, Opportunity.Buyer__c, Opportunity.Buyer__r.Name FROM OpportunityLineItem WHERE OpportunityId = :oppId]);
        System.debug('oppId: ' + oppId);
        System.debug('olis: ' + olis);
        
        //Get logged in User
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email, Name From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        String activeUserName = activeUser.Name;
        
        List<Id> oliIds = new List<Id>();
        List<Id> partIds = new List<Id>();
        List<Id> biddingIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        for(OpportunityLineItem oli : olis) {
            oliIds.add(oli.Id);
            partIds.add(oli.Product2Id);
            biddingIds.add(oli.Bidding__r.Id);
        }
//Add criteria: RFQ has not be sent and it should by email        
        List<Bid__c> bids = new List<Bid__c>([SELECT Id, Name, Bidding__c, Bidding__r.RFQ_due_date__c, RFQ_by_Email__c, Bidding__r.Bidding_description__c, Bidding__r.Prototype__c, RFQ_has_been_sent__c, Description__c, Supplier__r.Name, CurrencyISOCode
                                                FROM Bid__c 
                                               WHERE Bidding__c IN :biddingIds AND RFQ_by_Email__c = true AND RFQ_has_been_sent__c = false]);
        List<Product2> parts = new List<Product2>([SELECT Id, Name, Deviation__c, Dimension__c, Drawing_Number__c, Coating__c, COO__c, Drawing_Revision__c, 
                                                          ProductCode, EAV__c, Washer__c, MOQ__c, Weight__c, Customer__c, 
                                                          Extra_Feature_1000__c, Description, Drawing_Portal_URL__c
                                                   FROM Product2 WHERE Id IN :partIds]);
        
        Set<Bidding__c> biddingsToUpdate = new Set<Bidding__c>();
        Map<Id, Set<Bid__c>> accountBidsMap = new Map<Id, Set<Bid__c>>();
        Map<Id, Product2> partIdMap = new Map<Id, Product2>();
        for(Product2 part : parts) {
            partIdMap.put(part.Id, part);
        }
        Map<Id, Set<Product2>> biddingpartMap = new Map<Id, Set<Product2>>();
        Map<String, Decimal> biddingQuantityMap = new Map<String, Decimal>();
        Map<Id, Boolean> biddingProtoMap = new Map<Id, Boolean>();
        System.debug('BIDS: ' + bids);
        for(Bid__c bid : bids) {
            if(!accountBidsMap.containsKey(bid.Supplier__c)) {
                accountBidsMap.put(bid.Supplier__c, new Set<Bid__c>());
            }
            Set<Bid__c> newList = accountBidsMap.get(bid.Supplier__c);
            newList.add(bid);
            accountIds.add(bid.Supplier__c);
            accountBidsMap.put(bid.Supplier__c, newList);  
            bid.RFQ_has_been_sent__c = true;
            if(bid.Bidding__r.RFQ_due_date__c == null) {
                biddingsToUpdate.add(new Bidding__c(Id = bid.Bidding__c, RFQ_due_date__c = System.today().addDays(14)));
            }
        }
        
        System.debug('accountBidsMap: ' + accountBidsMap);
        
        Map<Id, Map<Id, String>> buyerMap = new Map<Id, Map <Id, String>>();
        for(OpportunityLineItem oli : olis) {
            if(!biddingpartMap.containsKey(oli.Bidding__c)) {
                biddingpartMap.put(oli.Bidding__c, new Set<Product2>());
            }
            Set<Product2> newList = biddingpartMap.get(oli.Bidding__c);
            newList.add(partIdMap.get(oli.Product2Id));
            biddingpartMap.put(oli.Bidding__c, newList); 
            biddingQuantityMap.put(oli.Product2Id + '-' + oli.Bidding__c, oli.Quantity);
            biddingProtoMap.put(oli.Product2Id, oli.Prototype__c);
            
            if (oli.Buyer__c != null){
                Map <Id, String> auxMap = new Map <Id, String>();
                if (!buyerMap.containsKey(oli.Bidding__c)){
                    auxMap.put(oli.Product2Id, oli.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
                else{
                    auxMap = buyerMap.get(oli.Bidding__c);
                    auxMap.put(oli.Product2Id, oli.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
            }
            else if (oli.Opportunity.Buyer__c != null){
                Map <Id, String> auxMap = new Map <Id, String>();
                if (!buyerMap.containsKey(oli.Bidding__c)){
                    auxMap.put(oli.Product2Id, oli.Opportunity.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
                else{
                    auxMap = buyerMap.get(oli.Bidding__c);
                    auxMap.put(oli.Product2Id, oli.Opportunity.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
            }
        }
        
        System.debug('biddingpartMap: ' + biddingpartMap);

//Add contact fields               
//Only when RFQ Contact matches
        List<Contact> contacts = new List<Contact>([SELECT Id, AccountId, Active__c, Name, RFQ_Contact_Picklist__c, Email, Salutation, LastName, FirstName FROM Contact WHERE AccountId IN :accountIds]);
        Map<Id, List<Contact>> accountContactMap = new Map<Id, List<Contact>>();
         for(Contact con : contacts) {
             if(!accountContactMap.containsKey(con.AccountId)) {
                 accountContactMap.put(con.AccountId, new List<Contact>());
             }
             List<Contact> newList = accountContactMap.get(con.AccountId);
             newList.add(con);
             accountContactMap.put(con.AccountId, newList);
        }
        System.debug('accountContactMap: ' + accountContactMap);
        
        Integer count = 0;
        for(Id accId : accountBidsMap.keySet()) {
            List<Contact> contactList = accountContactMap.get(accId);
            if(contactList <> null) {
                count+= contactList.size();
            }
        }
        System.debug('Count emails: ' + count);
//        Messaging.reserveSingleEmailCapacity(count);
        System.debug(biddingsToUpdate);
        
        Messaging.Email[] messages = new Messaging.Email[0];
        
        for(Id accId : accountBidsMap.keySet()) {
            Set<Bid__c> bidList = accountBidsMap.get(accId);
            List<Contact> contactList = accountContactMap.get(accId);
            String body = '<p style="font-family:Segoe UI;font-size:10pt;">'
                + 'Dear supplier, <br/><br/>'
                + 'Can you please send us your quotation according the conditions mentioned in this RFQ unless otherwise agreed between both parties. <br/><br/>'
                + 'Your quotation should include: <br/>'
                + '-    Piece price <br/>'
                + '-    Currency: please offer in your local currency and clearly indicate this in your offer <br/>'
                + '-    Raw Material Level (E.g. Q1 2018) <br/>'
                + '-    PPAP LT including SST/ACT <br/>'
                + '-    Serial LT after PPAP approval <br/>'
                + '-    Deviation in case your offer is not 100% according to drawing <br/>'
                + '-    MOQ <br/>'
                + '-    Part Weight <br/>'
                + '-    Tooling Cost and description (in case applicable) <br/><br/>'
                + '-	RFQ number ' + opp.Portal_URL__c.substringAfterLast('=') + '<br/><br/>'
                + 'The parts to be quoted: <br/>'
                + '------------------------- <br/>';
                
            Integer i = 1;
            String RFQDate = '';
            for(Bid__c bid : bidList) {
                Set<Product2> prs = biddingpartMap.get(bid.Bidding__c);
                System.debug('Set: ' + prs);
                for(Product2 pr : prs) {
                    body += i  + '<br/>';
//                    String s22 = (biddingQuantityMap.get(pr.Id + '-' + bid.Bidding__c)) + '';
//                  s22 = s22.left(s22.length()-3).reverse().replaceAll('.{3}', '$0.').reverse();
                    String s22 = (biddingQuantityMap.get(pr.Id + '-' + bid.Bidding__c)).format();
                    if(s22.startsWith('.')) s22 = s22.right(s22.length()-1);
//                    body += 'Partnumber: '    + (pr.ProductCode               <> null ? '' + pr.ProductCode                : '') + '<br/>';
//                    body += 'Description: '   + (pr.Description               <> null ? '' + pr.Description                : '') + '<br/>';
                    body += 'Part Name: '   + (pr.Name <> null ? '' + pr.Name : '') + '<br/>';
                    body += 'Annual volume: ' + (s22 <> null ? '' + s22 : '') + '<br/>';
                    body += 'Drawing: '       + (pr.Drawing_Number__c         <> null ? '' + pr.Drawing_Number__c          : '') + '<br/>';
                    body += 'Description: '       + (bid.Bidding__r.Bidding_description__c         <> null ? '' + bid.Bidding__r.Bidding_description__c          : '') + '<br/>';
                    body += 'Prototype: '       + (bid.Bidding__r.Prototype__c ? 'Yes' : 'No') + '<br/>';
                    if (buyerMap.containsKey(bid.Bidding__c)){
                        if (buyerMap.get(bid.Bidding__c).containsKey(pr.Id)){
                            body += 'Part Buyer: ' + buyerMap.get(bid.Bidding__c).get(pr.Id) + '<br/>';
                        }
                    }
                    body += '<br/>';
                    i++;
                    body += 'The drawings can be found on the Facil website: https://portal.facil.be <br/><br/>';
                }
                RFQDate = opp.Due_Date__c.format() + '';
            }
            
            body += 'Conditions (unless otherwise agreed between both parties) <br/>'
                + '---------- <br/>'
                + '- Payment conditions 90 days end of month <br/>'
                + '- Quality Expectations according general quality requirements: free of charge or included in the piece price <br/>'
                + '- PPAP level 3 <br/><br/>'
                + 'Deadline for quotation: ' + RFQDate + '<br/><br/>'
                + 'Unless otherwise stated, the Facil General Purchase Conditions are applicable. <br/><br/>'
                + 'Remarks: <br/>'
                + '-------- <br/>'
                + (opp.Bid_Remark__c <> null ? opp.Bid_Remark__c : '') + '<br/><br/>'
                + 'If you have any further questions concerning this RFQ, do not hesitate to contact us. <br/>'
                + 'Your contact for this RFQ is: <br/>'
                + activeUserName + '<br/><br/><br/><p>';
            System.debug(body); 
            
            if(contactList <> null) {
                for(Contact con : contactList) {   
                    System.debug('comp: ' + con.RFQ_Contact_Picklist__c + ' .. ' + opp.RFQ_Contact__c);
                    if(con.RFQ_Contact_Picklist__c == 'All' || con.RFQ_Contact_Picklist__c == opp.RFQ_Contact__c) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        List<String> toAddresses = new List<String>();
                        if(con.Email <> null) {
                            toAddresses.add(con.Email); 
                            mail.setToAddresses(toAddresses);
                            mail.setReplyTo(opp.Owner.Email);
                            mail.setSenderDisplayName('Facil - ' + opp.Owner.Name);
                            mail.setSubject('New RFQ available: RFQ number ' + opp.Portal_URL__c.substringAfterLast('='));                    
                            mail.setBccSender(false);
                            mail.setUseSignature(false);
                            System.debug(body);                    
                            mail.setHtmlBody(body);
                            messages.add(mail);
                        }
                    }
                }
            }
        }
        
        try {
            System.debug('biddingsToUpdate: ' + biddingsToUpdate);
            System.debug('bids: ' + bids);
            update bids;
            update new List<Bidding__c>(biddingsToUpdate);
        } catch (Exception e) {
            System.debug('ERROR UPDATING BIDS: ' + e.getMessage());
        }
        
        system.debug('messages: ' + messages);
        if (!messages.isEmpty()){
            try{
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages);
            }
            catch(Exception ex){
                system.debug('error sending emails: ' + ex.getMessage());
            }
        }
        
        return true;
        
    }
    

    @auraEnabled
    public static boolean sendAllRFQToSupplierPortal (Id oppId) {
        system.debug('sendAllRFQToSupplierPortal');
       Opportunity opp = [SELECT Id, Owner.Email, Owner.Name, RFQ_Contact__c, Responsible_User__c, Bid_Remark__c, Due_Date__c, Portal_URL__c, Opportunity_Number__c FROM Opportunity WHERE Id = :oppId];
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>([SELECT Id, Product2Id, Quantity, Bidding__r.Id, Bidding__c, Prototype__c, Buyer__c, Buyer__r.Name, Opportunity.Buyer__c, Opportunity.Buyer__r.Name FROM OpportunityLineItem WHERE OpportunityId = :oppId]);
        System.debug('oppId: ' + oppId);
        System.debug('olis: ' + olis);
        
        //Get logged in User
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email, Name From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        String activeUserName = activeUser.Name;
        
        List<Id> oliIds = new List<Id>();
        List<Id> partIds = new List<Id>();
        List<Id> biddingIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        for(OpportunityLineItem oli : olis) {
            oliIds.add(oli.Id);
            partIds.add(oli.Product2Id);
            biddingIds.add(oli.Bidding__r.Id);
        }
//Add criteria: RFQ has not be sent and it should NOT by email        
        List<Bid__c> bids = new List<Bid__c>([SELECT Id, Name, Bidding__c, Bidding__r.RFQ_due_date__c, RFQ_by_Email__c, RFQ_has_been_sent__c, Description__c, Supplier__r.Name, CurrencyISOCode
                                                FROM Bid__c 
                                               WHERE Bidding__c IN :biddingIds AND RFQ_by_Email__c = false AND RFQ_has_been_sent__c = false AND RFQ_PortalId__c <> '']);
        System.debug('bids: ' + bids);
        List<Product2> parts = new List<Product2>([SELECT Id, Name, Deviation__c, Dimension__c, Drawing_Number__c, Coating__c, COO__c, Drawing_Revision__c, 
                                                          ProductCode, EAV__c, Washer__c, MOQ__c, Weight__c, Customer__c, 
                                                          Extra_Feature_1000__c, Description, Drawing_Portal_URL__c
                                                   FROM Product2 WHERE Id IN :partIds]);
        
        Set<Bidding__c> biddingsToUpdate = new Set<Bidding__c>();
        Map<Id, Set<Bid__c>> accountBidsMap = new Map<Id, Set<Bid__c>>();
        Map<Id, Product2> partIdMap = new Map<Id, Product2>();
        for(Product2 part : parts) {
            partIdMap.put(part.Id, part);
        }
        Map<Id, Set<Product2>> biddingpartMap = new Map<Id, Set<Product2>>();
        Map<String, Decimal> biddingQuantityMap = new Map<String, Decimal>();
        Map<Id, Boolean> biddingProtoMap = new Map<Id, Boolean>();
        
        for(Bid__c bid : bids) {
            if(!accountBidsMap.containsKey(bid.Supplier__c)) {
                accountBidsMap.put(bid.Supplier__c, new Set<Bid__c>());
            }
            Set<Bid__c> newList = accountBidsMap.get(bid.Supplier__c);
            newList.add(bid);
            accountIds.add(bid.Supplier__c);
            accountBidsMap.put(bid.Supplier__c, newList);  
            bid.RFQ_has_been_sent__c = true;
            if(bid.Bidding__r.RFQ_due_date__c == null) {
                biddingsToUpdate.add(new Bidding__c(Id = bid.Bidding__c, RFQ_due_date__c = System.today().addDays(14)));
            }
        }
        
        System.debug('accountBidsMap: ' + accountBidsMap);
        
        Map<Id, Map<Id, String>> buyerMap = new Map<Id, Map <Id, String>>();
        for(OpportunityLineItem oli : olis) {
            if(!biddingpartMap.containsKey(oli.Bidding__c)) {
                biddingpartMap.put(oli.Bidding__c, new Set<Product2>());
            }
            Set<Product2> newList = biddingpartMap.get(oli.Bidding__c);
            newList.add(partIdMap.get(oli.Product2Id));
            biddingpartMap.put(oli.Bidding__c, newList); 
            biddingQuantityMap.put(oli.Product2Id + '-' + oli.Bidding__c, oli.Quantity);
            biddingProtoMap.put(oli.Product2Id, oli.Prototype__c);
            
            if (oli.Buyer__c != null){
                Map <Id, String> auxMap = new Map <Id, String>();
                if (!buyerMap.containsKey(oli.Bidding__c)){
                    auxMap.put(oli.Product2Id, oli.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
                else{
                    auxMap = buyerMap.get(oli.Bidding__c);
                    auxMap.put(oli.Product2Id, oli.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
            }
            else if (oli.Opportunity.Buyer__c != null){
                Map <Id, String> auxMap = new Map <Id, String>();
                if (!buyerMap.containsKey(oli.Bidding__c)){
                    auxMap.put(oli.Product2Id, oli.Opportunity.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
                else{
                    auxMap = buyerMap.get(oli.Bidding__c);
                    auxMap.put(oli.Product2Id, oli.Opportunity.Buyer__r.Name);
                    buyerMap.put(oli.Bidding__c, auxMap);
                }
            }
        }
        
        System.debug('biddingpartMap: ' + biddingpartMap);

//Add contact fields               
//Only when RFQ Contact matches
        List<Contact> contacts = new List<Contact>([SELECT Id, AccountId, Active__c, Name, RFQ_Contact_Picklist__c, Email, Salutation, LastName, FirstName FROM Contact WHERE AccountId IN :accountIds]);
        Map<Id, List<Contact>> accountContactMap = new Map<Id, List<Contact>>();
         for(Contact con : contacts) {
             if(!accountContactMap.containsKey(con.AccountId)) {
                 accountContactMap.put(con.AccountId, new List<Contact>());
             }
             List<Contact> newList = accountContactMap.get(con.AccountId);
             newList.add(con);
             accountContactMap.put(con.AccountId, newList);
        }
        System.debug('accountContactMap: ' + accountContactMap);
        
        Integer count = 0;
        for(Id accId : accountBidsMap.keySet()) {
            List<Contact> contactList = accountContactMap.get(accId);
            if(contactList <> null) {
                count+= contactList.size();
            }
        }
        System.debug('Count emails: ' + count);
//        Messaging.reserveSingleEmailCapacity(count);
        System.debug(biddingsToUpdate);
        
        
        Messaging.Email[] messages = new Messaging.Email[0];
        
        for(Id accId : accountBidsMap.keySet()) {
            Set<Bid__c> bidList = accountBidsMap.get(accId);
            List<Contact> contactList = accountContactMap.get(accId);
            String body = '<p style="font-family:Segoe UI;font-size:10pt;">'
                + 'Dear supplier, <br/><br/>' 
                + 'Can you please send us your quotation according the conditions mentioned in this RFQ unless otherwise agreed between both parties. <br/><br/>'
                + 'On the e-sourcing platform you will find all the necessary information. <br/><br/>'
                + 'https://portal.facil.be.<br/><br/>'
                + 'RFQ number '+ opp.Portal_URL__c.substringAfterLast('=') +'<br/><br/>'
                + 'The parts to be quoted: <br/>'
                + '------------------------- <br/>';
                            
            Integer i = 1;
            String RFQDate;
            for(Bid__c bid : bidList) {
                Set<Product2> prs = biddingpartMap.get(bid.Bidding__c);
                for(Product2 pr : prs) {
                    body += i  + '<br/>';
//                    String s22 = (biddingQuantityMap.get(pr.Id + '-' + bid.Bidding__c)) + '';
//                  s22 = s22.left(s22.length()-3).reverse().replaceAll('.{3}', '$0.').reverse();
                    String s22 = (biddingQuantityMap.get(pr.Id + '-' + bid.Bidding__c)).format();
                    if(s22.startsWith('.')) s22 = s22.right(s22.length()-1);
//                    body += 'Partnumber: '    + (pr.ProductCode               <> null ? '' + pr.ProductCode                : '') + '<br/>';
//                    body += 'Description: '   + (pr.Description               <> null ? '' + pr.Description                : '') + '<br/>';
                    body += 'Part Name: '   + (pr.Name <> null ? '' + pr.Name : '') + '<br/>';
                    body += 'Annual volume: ' + (s22 <> null ? '' + s22 : '') + '<br/>';
                    body += 'Drawing: '       + (pr.Drawing_Number__c         <> null ? '' + pr.Drawing_Number__c          : '') + '<br/>';
                    if (buyerMap.containsKey(bid.Bidding__c)){
                        if (buyerMap.get(bid.Bidding__c).containsKey(pr.Id)){
                            body += 'Part Buyer: ' + buyerMap.get(bid.Bidding__c).get(pr.Id) + '<br/>';
                        }
                    }
                    body += '<br/>';
                    i++;
                    body += 'The drawings can be found on the Facil website: https://portal.facil.be <br/><br/>';
                }
                RFQDate = opp.Due_Date__c.format() + '';
            }
            
            body += 'You can access this website using your log-in code and password. <br/>'
                + 'In case you do not have a log-in code you can request this at the Facil buyer. <br/><br/>'
                + 'Conditions (unless otherwise agreed between both parties) <br/>'
                + '---------- <br/>'
                + '- Payment conditions 90 days end of month <br/>'
                + '- Quality Expectations according general quality requirements: free of charge or included in the piece price <br/>'
                + '- PPAP level 3 <br/><br/>'
                + 'Your offer should also indicate your lead time for: <br/>'
                + '- PPAP including SST/ACT and samples <br/>'
                + '- Serial parts after PPAP approval <br/><br/>'
                + 'Deadline for quotation: ' + RFQDate + '<br/><br/>'
                + 'Unless otherwise stated, the Facil General Purchase Conditions are applicable. <br/><br/>'
                + 'Remarks: <br/>'
                + '-------- <br/>'
                + (opp.Bid_Remark__c <> null ? opp.Bid_Remark__c : '') + '<br/><br/>'
                + 'If you have any further questions concerning this RFQ, do not hesitate to contact us. <br/>'
                + 'Your contact for this RFQ is: <br/>'
                + activeUserName + '<br/><br/><br/><p>';
            
            if(contactList <> null) {
                for(Contact con : contactList) {   
                    System.debug('comp: ' + con.RFQ_Contact_Picklist__c + ' .. ' + opp.RFQ_Contact__c);
                    if(con.RFQ_Contact_Picklist__c == 'All' || con.RFQ_Contact_Picklist__c == opp.RFQ_Contact__c) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        List<String> toAddresses = new List<String>();
                        if(con.Email <> null) {
                            toAddresses.add(con.Email); 
                            mail.setToAddresses(toAddresses);
                            mail.setReplyTo(opp.Owner.Email);
                            mail.setSenderDisplayName('Facil - ' + opp.Owner.Name);
                            mail.setSubject('New RFQ available: RFQ number ' + opp.Portal_URL__c.substringAfterLast('='));                    
                            mail.setBccSender(false);
                            mail.setUseSignature(false);
                            System.debug(body);                    
                            mail.setHtmlBody(body);
                            messages.add(mail);
                        }
                    }
                }
            }
        }
        
        try {
            System.debug('biddingsToUpdate: ' + biddingsToUpdate);
            System.debug('bids: ' + bids);
            update bids;
            update new List<Bidding__c>(biddingsToUpdate);
        } catch (Exception e) {
            System.debug('ERROR UPDATING BIDS: ' + e.getMessage());
        }
        
        system.debug('messages: ' + messages);
        if (!messages.isEmpty()){
            try{
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages);
            }
            catch(Exception ex){
                system.debug('error sending emails: ' + ex.getMessage());
            }
        }
        
        return true;
        
    }


    @auraEnabled
    public static String lightCallOut2(String oppId, List<String> options) {
        return WS_RFQPortal.lightCallOut(oppId, options);
    }
    
    @auraEnabled
    public static Boolean checkManualPrice (OpportunityLineItem oli) {
        system.debug('checkManualPrice: ' + oli);
        system.debug('oli bid: ' + oli.Bid__c);
        system.debug('oli contract: ' + oli.Contract__c);
        if (oli.Bid__c != null || oli.Contract__c != null){
            return true;
        }
        else{
            return false;
        }       
    }

}