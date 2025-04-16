@RestResource(urlMapping='/Order/*')
global without sharing class OrderAPI {
    public static final Id OrderRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
    public static final Id ActivityRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('KMSKA_Activities').getRecordTypeId();
    public static final Id DonationRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
    public static final Id MembershipRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId();
    public static final Id OrganizationRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
    public static String activityTaal;
    @HttpPost
    global static void InsertOrders() {
        Integration_Log__c IL = new Integration_Log__c();
        IL.Request_Date_Time__c = System.now();
        
        RestRequest request = RestContext.request;
        String targetMethod = (request.params.get('target') != null) ? request.params.get('target') : '';
        String requestBody = request.requestBody.toString();
        
        IL.Request_URL__c = request.requestURI;
        if(request.params!=null && request.params.size()>0)
            IL.Request_URL__c = IL.Request_URL__c+'?'+getQueryString(request.params);
        
        IL.Request__c = requestBody;
        IL.Request_Method__c = request.httpMethod;
        IL.Request_Header__c = JSON.serialize(request.headers);
        
        
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        
        Savepoint sp = Database.setSavepoint();
        String Res;
        try{
            Map<String,Boolean> isProcessReq = validateProcessing(requestBody);
            if(isProcessReq.get('isToIgnore')){
                APIResponse APIRes = new APIResponse();
                Res = JSON.serialize(APIRes);
                response.responseBody = Blob.valueOf(Res);
            }else{
                Res = methodHandler(targetMethod,requestBody);
                response.responseBody = Blob.valueOf(Res);
            }
            response.statusCode = 201;
        }catch(Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            
            Res = '{"isSuccess" : false, "result" : "'+ex.getMessage()+'"}';
            
            response.responseBody = Blob.valueOf(Res);
            response.statusCode = 400;
            Database.rollback(sp);
        }
        
        IL.Response__c = response.responseBody.toString();
        IL.Response_Header__c = JSON.serialize(response.headers);
        IL.Response_Code__c = String.valueOf(response.statusCode);
        IL.Response_Date_Time__c = System.now();
        insert IL;
    }
    
    global static void reprocessIntegrationLog(Integration_Log__c IL){
        IL.Request_Date_Time_Last__c = System.now();
        String targetMethod = '';
        String requestBody = IL.Request__c;
        
        Savepoint sp = Database.setSavepoint();
        String Res; Integer statusCode;
        try{
            Map<String,Boolean> isProcessReq = validateProcessing(requestBody);
            if(isProcessReq.get('isToIgnore')){
                APIResponse APIRes = new APIResponse();
                Res = JSON.serialize(APIRes);
            }else{
                Res = methodHandler(targetMethod,requestBody);
            }
            statusCode = 201;
        }catch(Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            
            Res = '{"isSuccess" : false, "result" : "'+ex.getMessage()+'"}';
            
            statusCode = 400;
            Database.rollback(sp);
        }
        
        IL.Response_Last__c = Res;
        IL.Response_Code_Last__c = String.valueOf(statusCode);
        IL.Response_Date_Time_Last__c = System.now();
        update IL;
    }
    
    global static Map<String,Boolean> validateProcessing(String requestBody){
        Boolean isToIgnore = false;
        Map<String,Boolean> isProcessMap = new Map<String,Boolean>();
        Map<String, Object> m =  (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        if(m.containsKey('Orders')){
            List<Object> orders = (List<Object>)m.get('Orders');
            Map<String, Object> order =  (Map<String, Object>)orders[0];
            System.debug(order);
            if(order.containsKey('Order')){
                Map<String, Object> opp = (Map<String, Object>)order.get('Order');
                if(opp.containsKey('url')){
                    System.debug(opp.get('url'));
                    if(opp.get('url')=='hbo-wo')
                        isToIgnore = true;
                }
            }
            
            if(order.containsKey('Activity')){
                Map<String, Object> activity = (Map<String, Object>)order.get('Activity');
                if(activity.containsKey('Taal__c')){
                    activityTaal = (String)activity.get('Taal__c');
                }
            }
        }
        System.debug(isToIgnore);
        
        isProcessMap.put('isToIgnore',isToIgnore); 
        return isProcessMap;
    }
    
    global static String methodHandler(String methodName, String requestBody){
        String Response = '';
        
        IOrders Orders = (IOrders)JSON.deserialize(requestBody, IOrders.Class);
        
        Map<String,Object> validRes = validateReq(Orders);
        if(!(Boolean)validRes.get('isValid')){
            throw new APIException((String)validRes.get('ErrorMsg'));
        }
        
        APIResponse Res = HandleOrders(Orders);
        
        if(!Res.isSuccess){
            throw new APIException(Res.result);
        }
        
        Response = JSON.serialize(Res);
        
        return Response;
    }
    
    public static Map<String,Object> validateReq(IOrders OrderLst){
        Boolean isValid = true;
        String ErrorMsg = '';
        
        List<IOrders.Order_cls> Orders = OrderLst.Orders;
        if(Orders==null){
            isValid = false;
            ErrorMsg = 'Please provide Orders';
        }
        
        for(IOrders.Order_cls order : Orders){
            System.debug(order.Order);
            if(order.Order.GT_Unique_ID__c==null || order.Order.GT_Unique_ID__c ==''){
                isValid = false;
                ErrorMsg = 'Some Order missing [GT_Unique_ID__c]';
            }
            
            if(order.Activity!=null && (order.Activity.GT_ID__c==null || order.Activity.GT_ID__c =='')){
                isValid = false;
                ErrorMsg = 'Some Activities missing [GT_ID__c]';
            }
        }
        
        Map<String,Object> response = new Map<String,Object>();
        response.put('isValid',isValid);
        response.put('ErrorMsg',ErrorMsg);
        return response;
    }
    
    public static APIResponse HandleOrders(IOrders OrderLst){
        Boolean isValid = true;
        String ErrorMsg = '';
        
        APIResponse Response = new APIResponse();
        
        List<IOrders.Order_cls> Orders = OrderLst.Orders;
        
        List<Opportunity> OpportunityLst = new List<Opportunity>();
        List<Opportunity> DonationOrderOppLst = new List<Opportunity>();
        List<Order_Line__c> OrdersLines = new List<Order_Line__c>();
        Map<String,Activity_Product__c> ActivityMap = new Map<String,Activity_Product__c>();
        List<Activity_Product__c> ActivityLst = new List<Activity_Product__c>();
        
        Map<Id,Opportunity> ExistingOpportunityLst = new Map<Id,Opportunity>();
        Set<String> existingOpp = new Set<String>();
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        
        for(IOrders.Order_cls order : Orders){
            Boolean isDSOrder = false;
            Account oAct = null;
            contact oCon = null;
            if(order.Contact!=null && order.Contact.LastName !=null && order.Contact.FirstName!=null && order.Contact.Email!=null
               && order.Contact.LastName !='' && order.Contact.FirstName!='' && order.Contact.Email!='')
            {
                oCon = order.Contact;
            }else
            {
                Response = handleDirectSalesOrder(order);
                return Response;
            }
            
            if(order.Organisation!=null){
                oAct = order.Organisation;
            }
            
            if(order.Order!=null){
                if(oCon!=null){
                    if((oCon.LastName).toLowerCase() =='dummy'){
                        oCon = new Contact(Id = Label.Dummy_Contact);
                    }else {
                        List<contact> contacts = [SELECT Id, FirstName, LastName, Email,Digital_Newsletter__c 
                                                  FROM Contact 
                                                  WHERE FirstName =: oCon.FirstName AND LastName =: oCon.LastName AND Email =: oCon.Email
                                                 ];
                        if(!contacts.isEmpty()){
                            Contact extCont = contacts[0];
                            
                            Boolean isUpdate = false;
                            if(oCon.Digital_Newsletter__c!=extCont.Digital_Newsletter__c){extCont.Digital_Newsletter__c = oCon.Digital_Newsletter__c; isUpdate = true;}
                            if(oCon.MailingStreet!=null){extCont.MailingStreet =  oCon.MailingStreet; isUpdate = true;}
                            if(oCon.MailingPostalCode!=null){extCont.MailingPostalCode  =  oCon.MailingPostalCode; isUpdate = true;}
                            if(oCon.MailingCity!=null){extCont.MailingCity  =  oCon.MailingCity; isUpdate = true;}
                            if(oCon.MailingCountry!=null){extCont.MailingCountry  =  oCon.MailingCountry; isUpdate = true;}
                            
                            oCon = extCont;
                            if(isUpdate){
                                Database.SaveResult results = Database.update(oCon, dml);
                            }
                        }else{
                            oCon.Preferred_Language__c = order.Order.Taal__c;
                            Database.SaveResult results = Database.insert(oCon, dml);
                            //insert oCon;
                        }
                    }
                }
                
                if((order.Order.Rec_Type__c).toLowerCase() == 'kmska activity' && oAct!=null){
                    List<Account> accounts = [SELECT Id, Name 
                                              FROM Account 
                                              WHERE Name =: oAct.Name AND VAT__c =: oAct.VAT__c];
                    if(!accounts.isEmpty()){
                        oAct = accounts[0];
                    }else{
                        Database.SaveResult results = Database.insert(oAct, dml);
                        //insert oAct;
                    }
                }
                
                Opportunity opp = order.Order;
                
                opp.Start_Time__c = opp.Start_Time__c!= null?convertToCEST(opp.Start_Time__c):null;
                opp.CloseDate = opp.GT_Order_Date_Time__c!=null?convertToCEST(opp.GT_Order_Date_Time__c).date(): date.today();
                opp.GT_Order_Date_Time__c = opp.GT_Order_Date_Time__c!=null?convertToCEST(opp.GT_Order_Date_Time__c): null;
                opp.Taal__c = order.Order.Taal__c;
                opp.Timezone_Corrected__c = true;
                
                opp.StageName = opp.StageName!=null?(opp.StageName):'Geaccepteerd';
                opp.Amount = opp.Amount!=null?(opp.Amount):0;
                opp.Doelgroep__c = (opp.Doelgroep__c!=null && opp.Doelgroep__c!='')?(opp.Doelgroep__c):' Volwassenen';
                
                if(oCon!=null && oCon.Id!=null){
                    opp.npsp__Primary_Contact__c = oCon.Id;
                }
                
                if((opp.Rec_Type__c).toLowerCase() == 'order'){
                    opp.RecordTypeId = OrderRecId;
                    opp.Name = 'Tickets';
                }else if((opp.Rec_Type__c).toLowerCase() == 'kmska activity'){
                    opp.RecordTypeId = ActivityRecId;
                    opp.Name = 'KMSKA Activity';
                    
                    if(oAct!=null && oAct.Id!=null)
                        opp.AccountId = oAct.Id;
                    
                    if(order.Activity!=null && order.Activity.GT_ID__c!=null && order.Activity.GT_ID__c !=''){
                        Datetime latestEndDate;
                        Map<String,KMSKA_Product__c> activityProdMap = getKMSKAProduct(order.Activity);
                        if(!activityProdMap.containsKey(order.Activity.GT_ID__c)){
                            isValid = false;
                            Response.isSuccess = false;
                            Response.result = 'KMSKA Product Not found with GT_ID__c = \''+order.Activity.GT_ID__c+'\'';
                            return Response;
                        }
                        KMSKA_Product__c prod = activityProdMap.get(order.Activity.GT_ID__c);
                        Activity_Product__c ap = new Activity_Product__c();
                        ap.Opportunity__r = new Opportunity(GT_Unique_ID__c = opp.GT_Unique_ID__c);
                        ap.KMSKA_Product__c = prod.Id;
                        
                        ap.Start_Time__c =order.Activity.Start_Time__c!=null?convertToCEST(order.Activity.Start_Time__c):null;
                        ap.Timezone_Corrected__c = true;
                        ap.Taal__c = activityTaal;
                        ap.Status__c = 'Aangevraagd';
                        ap.Doelgroep__c = (opp.Doelgroep__c!=null && opp.Doelgroep__c!='')?(opp.Doelgroep__c):' Volwassenen';
                        ap.End_Time__c = (ap.Start_Time__c).addMinutes(Integer.valueof(prod.Duration_in_min__c));
                        
                        opp.End_Time__c = (ap.Start_Time__c).addMinutes(Integer.valueof(prod.Duration_in_min__c));
                        opp.Type = prod.Type__c;
                        opp.Name = prod.Name;
                        
                        ActivityMap.put(order.Activity.GT_ID__c+ap.Start_Time__c, ap);
                    }
                }else if((opp.Rec_Type__c).toLowerCase() == 'donation'){
                    opp.RecordTypeId = DonationRecId;
                    opp.Name = 'Donatie';
                }else if((opp.Rec_Type__c).toLowerCase() == 'membership'){
                    opp.RecordTypeId = MembershipRecId;
                    opp.Name = 'Lidmaatschap';
                }
                
                Integer noOfOT = 0;
                Decimal sumOfOT = 0;
                Integer noOfAOT = 0;
                Decimal sumOfAOT = 0;
                if(order.OrderLines!=null){
                    for(Order_Line__c orderline : order.OrderLines){
                        if(opp.RecordTypeId==OrderRecId){
                            if(orderline.Type__c=='Ticket' || orderline.Type__c=='Product'){
                                orderline.Order__r = new Opportunity(GT_Unique_ID__c = opp.GT_Unique_ID__c);
                                orderline.Quantity__c = (orderline.Quantity__c!=null)?orderline.Quantity__c:0;
                                OrdersLines.add(orderline);
                                if(orderline.Type__c=='Ticket'){
                                    noOfOT++;
                                    sumOfOT = sumOfOT + orderline.Quantity__c;
                                }
                            }
                        }else if(opp.RecordTypeId==ActivityRecId){
                            if(orderline.Type__c=='Ticket' || orderline.Type__c=='Product'){
                                orderline.Order__r = new Opportunity(GT_Unique_ID__c = opp.GT_Unique_ID__c);
                                orderline.Quantity__c = (orderline.Quantity__c!=null)?orderline.Quantity__c:0;
                                OrdersLines.add(orderline);
                                if(orderline.Type__c=='Ticket'){
                                    noOfAOT++;
                                    sumOfAOT = sumOfAOT + orderline.Quantity__c;
                                }
                            }
                        }else if(opp.RecordTypeId==DonationRecId){
                            Opportunity donationOppt;
                            donationOppt = opp;
                            donationOppt.Amount = orderline.Bruto_Price__c;
                            OpportunityLst.add(donationOppt);
                        }else if(opp.RecordTypeId==MembershipRecId){
                            Opportunity memberShipOpp;
                            memberShipOpp = opp;
                            memberShipOpp.Amount = orderline.Bruto_Price__c;
                            memberShipOpp.Description = orderline.Description__c;
                            memberShipOpp.npe01__Member_Level__c = orderline.Sub_Type__c;
                            memberShipOpp.npe01__Membership_Start_Date__c  = orderline.Membership_Start_Date__c;
                            memberShipOpp.npe01__Membership_End_Date__c  = orderline.Membership_End_Date__c;
                            OpportunityLst.add(memberShipOpp);
                        }
                        
                        if( (opp.RecordTypeId==OrderRecId || opp.RecordTypeId==ActivityRecId) && orderline.Type__c=='Donation'){
                            Opportunity donationOrderOppt;
                            donationOrderOppt = opp.clone(false,false);
                            donationOrderOppt.RecordTypeId = DonationRecId;
                            donationOrderOppt.Amount = orderline.Bruto_Price__c;
                            donationOrderOppt.GT_Unique_ID__c = opp.GT_Unique_ID__c+'-don';
                            DonationOrderOppLst.add(donationOrderOppt);
                            System.debug('Id ' + donationOrderOppt.Id);
                        }
                    }
                }
                
                
                if((opp.Rec_Type__c).toLowerCase() == 'order' && noOfOT>0){
                    OpportunityLst.add(opp);    
                }
                
                if((opp.Rec_Type__c).toLowerCase() == 'kmska activity'){
                    OpportunityLst.add(opp);    
                }
            }
        }
        
        if(isValid && OpportunityLst.size()>0){
            Database.UpsertResult[] results = Database.upsert(OpportunityLst, Opportunity.GT_Unique_ID__c,true);
            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(!results[index].isSuccess()) {
                    isValid = false;
                    ErrorMsg += 'Order: ' + OpportunityLst[index].Name + ' failed!';
                    for (Database.Error er : results[index].getErrors()) {
                        ErrorMsg += 'Error (' + er.getStatusCode() + '):' + er.getMessage();
                        ErrorMsg += '\r\n';
                    }
                    break;
                }else{
                    Boolean isCreated = results[index].isCreated();
                    if(!isCreated){
                        Opportunity opp = OpportunityLst[index];
                        ExistingOpportunityLst.put(opp.Id,opp);
                        existingOpp.add(opp.GT_Unique_ID__c);
                    }
                }
            }
        }
        
        if(isValid && DonationOrderOppLst.size()>0){
            List<Opportunity> DonOppToInsert = new List<Opportunity>();
            for(Opportunity dOpp: DonationOrderOppLst){
                String gtUniqueId = (dOpp.GT_Unique_ID__c).subString(0,(dOpp.GT_Unique_ID__c.length()-4));
                if(!existingOpp.contains(gtUniqueId)){
                    DonOppToInsert.add(dOpp);
                }
            }
            
            if(DonOppToInsert.size()>0){
                Database.SaveResult[] results = Database.insert(DonOppToInsert, dml);
                for(Integer index = 0, size = results.size(); index < size; index++) {
                    if(!results[index].isSuccess()) {
                        isValid = false;
                        ErrorMsg += 'Opportunity : ' + DonOppToInsert[index].Name + ' failed!';
                        for (Database.Error er : results[index].getErrors()) {
                            ErrorMsg += 'Error (' + er.getStatusCode() + '):' + er.getMessage();
                            ErrorMsg += '\r\n';
                        }
                        break;
                    }
                }
            }
            OpportunityLst.addAll(DonOppToInsert);
        }
        
        if(isValid && OrdersLines.size()>0){
            List<Order_Line__c> OrdersLinesToInsert = new List<Order_Line__c>();
            for(Order_Line__c OL: OrdersLines){
                if(!existingOpp.contains(OL.Order__r.GT_Unique_ID__c)){
                    OrdersLinesToInsert.add(OL);
                }
            }
            
            if(OrdersLinesToInsert.size()>0){
                Database.SaveResult[] results = Database.insert(OrdersLinesToInsert, dml);
                for(Integer index = 0, size = results.size(); index < size; index++) {
                    if(!results[index].isSuccess()) {
                        isValid = false;
                        ErrorMsg += 'OrderLines: ' + OrdersLinesToInsert[index].Name + ' failed!';
                        for (Database.Error er : results[index].getErrors()) {
                            ErrorMsg += 'Error (' + er.getStatusCode() + '):' + er.getMessage();
                            ErrorMsg += '\r\n';
                        }
                        break;
                    }
                }
            }
            OrdersLines = OrdersLinesToInsert;
        }
        
        if(isValid && ActivityMap.size()>0){
            List<Activity_Product__c> ActivityToInsert = new List<Activity_Product__c>();
            List<Activity_Product__c> ActivityToUpdate = new List<Activity_Product__c>();
            
            Map<String,Activity_Product__c> activitiesToUpdate = new Map<String,Activity_Product__c>();
            Set<String> oppGTId = new set<String>();
            for(String key: ActivityMap.keySet()){
                Activity_Product__c AP = ActivityMap.get(key);
                if(!existingOpp.contains(AP.Opportunity__r.GT_Unique_ID__c)){
                    ActivityToInsert.add(AP);
                }else{
                    activitiesToUpdate.put(key, AP);
                    oppGTId.add(AP.Opportunity__r.GT_Unique_ID__c);
                }
            }
            
            Map<String,List<Activity_Product__c>> resProducts = handleKMSKAProductUpdate(activitiesToUpdate,oppGTId);
            ActivityToInsert.addAll(resProducts.get('insert'));
            ActivityToUpdate.addAll(resProducts.get('update'));
            
            if(ActivityToInsert.size()>0){
                Database.SaveResult[] results = Database.insert(ActivityToInsert, dml);
                for(Integer index = 0, size = results.size(); index < size; index++) {
                    if(!results[index].isSuccess()) {
                        isValid = false;
                        ErrorMsg += 'Activities: ' + ActivityToInsert[index].Opportunity__r.GT_Unique_ID__c + ' failed!';
                        for (Database.Error er : results[index].getErrors()) {
                            ErrorMsg += 'Error (' + er.getStatusCode() + '):' + er.getMessage();
                            ErrorMsg += '\r\n';
                        }
                        break;
                    }
                }
            }
            
            if(ActivityToUpdate.size()>0){
                Database.SaveResult[] results = Database.update(ActivityToUpdate, dml);
                for(Integer index = 0, size = results.size(); index < size; index++) {
                    if(!results[index].isSuccess()) {
                        isValid = false;
                        ErrorMsg += 'Activities: ' + ActivityToUpdate[index].Opportunity__r.GT_Unique_ID__c + ' failed!';
                        for (Database.Error er : results[index].getErrors()) {
                            ErrorMsg += 'Error (' + er.getStatusCode() + '):' + er.getMessage();
                            ErrorMsg += '\r\n';
                        }
                        break;
                    }
                }
            }
            ActivityLst = ActivityToInsert;
        }
        
        if(isValid){
            Response.isSuccess 		= true;
            Response.result 		= 'Order and Order Line items upserted Successfully.';
            Response.Orders 		= getOrders(OpportunityLst,ExistingOpportunityLst);
            Response.OrderLines 	= getOrderLines(OrdersLines);
            Response.Activities 	= getActivities(ActivityLst);
            //Response.Contact		= getContacts(ContactLst,ExistingContact);
        }else{
            Response.isSuccess = false;
            Response.result = ErrorMsg;
        }
        
        return Response;
    }
    
    // Description : 	We are getting time in GMT formate but it's CEST. 
    // For Ex: 			We are getting '2022-04-15T13:27:37.000Z' which is 15 Apr 22 1:27 PM In GMT but actually it's 15 Apr 22 1:27 PM In CEST. 
    // 					That's why we need to write this method to fix the time.. 
    // Logic: 			First find the diffrence, Generally in Apr it's 2 hr of diffrence and in Dec it's 1 hr of diffrence. So we need to remove
    // 					diffrence from the time we got. And then it's correct time. 
    // For Ex: 			2022-04-15T13:27:37.000Z in real case it will be 15 Apr 22 3:27 CEST .. but we need 15 Apr 22 1:27 CEST so we need to remove 2 hr
    // 					from the GMT date time.
    
    public static DateTime convertToCEST(DateTime dttime)
    {
        TimeZone tz = Timezone.getTimeZone('GMT');
        Integer offset=tz.getOffset(dttime);
        TimeZone targetTZ = Timezone.getTimeZone('Europe/Paris');
        integer offsetTotargetTZ = targetTZ.getOffset(dttime);
        integer correction = offsetTotargetTZ - offset;
        
        DateTime targetDT = dttime.addMinutes(-(correction / (1000 * 60)));
        
        return targetDT;
    }
    
    
    public static APIResponse handleDirectSalesOrder(IOrders.Order_cls order){
        APIResponse Response = new APIResponse();
        try{
            Boolean isValid = true;
            String ErrorMsg = '';
            
            List<Opportunity> OpportunityLst = new List<Opportunity>();
            Map<Id,Opportunity> ExistingOpportunityLst = new Map<Id,Opportunity>();
            
            Opportunity opp = order.Order;
            // logic for find difference between UTC time zone and closedate
            Date orderDateTime = opp.GT_Order_Date_Time__c!=null?convertToCEST(opp.GT_Order_Date_Time__c).date(): date.today();
            String oppName = 'Tickets - ' + orderDateTime.day()+'/'+orderDateTime.month()+'/'+orderDateTime.year();
            
            List<Opportunity> opps = [SELECT Id,GT_Unique_ID__c 
                                      FROM Opportunity 
                                      WHERE Name =:oppName AND CloseDate =:orderDateTime
                                     ];
            
            Opportunity DSOpp;
            if(opps.size()>0){
                DSOpp = opps[0];
                ExistingOpportunityLst.put(DSOpp.Id, DSOpp);
            }else{
                DSOpp = new Opportunity(Name = oppName , AccountId = System.Label.Direct_Sales_Account, CloseDate = orderDateTime, RecordTypeId = OrderRecId);
                DSOpp.StageName = opp.StageName!=null?(opp.StageName):'Geaccepteerd';
                DSOpp.GT_Unique_ID__c = opp.GT_Unique_ID__c;
                DSOpp.Amount = opp.Amount!=null?(opp.Amount):0;
                DSOpp.Timezone_Corrected__c = true; // checked Timezone Corected if new opportunity will be created
                DSOpp.GT_Event_Date__c = Date.today(); //orderDateTime
                DSOpp.GT_Order_Date_Time__c = opp.GT_Order_Date_Time__c!=null?convertToCEST(opp.GT_Order_Date_Time__c): null;
                DSOpp.Start_Time__c = opp.Start_Time__c!= null? (Datetime.newInstance((opp.Start_Time__c).year(),(opp.Start_Time__c).month(),(opp.Start_Time__c).day(),0,0,0)):null;
                DSOpp.Taal__c = opp.Taal__c;
                DSOpp.LeadSource = 'Kiosk';
                insert DSOpp;
            }
            OpportunityLst.add(DSOpp);
            
            List<Order_Line__c> OrdersLines = new List<Order_Line__c>();
            Map<Id,Order_Line__c> ExistingOLLst = new Map<Id,Order_Line__c>();
            
            if(order.OrderLines!=null){
                List<String> subTypeLst = new List<String>();
                Map<String,KMSKA_Product__c> productNameMap = new Map<String,KMSKA_Product__c>();
                Map<String,KMSKA_Product__c> productEngNameMap = new Map<String,KMSKA_Product__c>();
                
                for(Order_Line__c orderline : order.OrderLines){
                    if(orderline.Sub_Type__c!=null){
                        subTypeLst.add(orderline.Sub_Type__c);
                    }
                }
                List<KMSKA_Product__c> ProductNameLst = [SELECT Id, Name FROM KMSKA_Product__c WHERE Name IN: subTypeLst];
                List<KMSKA_Product__c> ProductsEngNameLst = [SELECT Id,English_Name__c FROM KMSKA_Product__c WHERE English_Name__c IN: subTypeLst];
                for(KMSKA_Product__c KP: ProductNameLst){productNameMap.put(KP.Name, KP);}
                for(KMSKA_Product__c KP: ProductsEngNameLst){productEngNameMap.put(KP.English_Name__c, KP);}
                
                for(Order_Line__c orderline : order.OrderLines){
                    orderline.Quantity__c = (orderline.Quantity__c!=null)?orderline.Quantity__c:0; 
                    orderline.Order__c = DSOpp.Id;
                    orderline.GT_Unique_ID__c = orderline.Sub_Type__c + opp.GT_Unique_ID__c;
                    if(orderline.Sub_Type__c!=null && ( productNameMap.containsKey(orderline.Sub_Type__c) || productEngNameMap.containsKey(orderline.Sub_Type__c) ) ){
                        orderline.Type__c = 'Product';
                    }
                    OrdersLines.add(orderline);
                }
            }
            
            if(OrdersLines.size()>0){
                Database.UpsertResult[] results = Database.upsert(OrdersLines, Order_Line__c.GT_Unique_ID__c,true);
                for(Integer index = 0, size = results.size(); index < size; index++) {
                    if(!results[index].isSuccess()) {
                        isValid = false;
                        ErrorMsg += 'Order Line: ' + OrdersLines[index].GT_Unique_ID__c + ' failed!';
                        for (Database.Error er : results[index].getErrors()) {
                            ErrorMsg += 'Error (' + er.getStatusCode() + '):' + er.getMessage();
                            ErrorMsg += '\r\n';
                        }
                        break;
                    }else{
                        Boolean isCreated = results[index].isCreated();
                        if(!isCreated){
                            Order_Line__c OL = OrdersLines[index];
                            ExistingOLLst.put(OL.Id,OL);
                        }
                    }
                }
            }
            
            List<Result> OLRecords = new List<Result>();
            for(Order_Line__c ol : OrdersLines){
                Result OLines = new Result();
                OLines.ExternalId = ol.GT_Unique_ID__c;
                OLines.SFId = ol.Id;
                if(ExistingOLLst.size()>0 && ExistingOLLst.containsKey(ol.Id)){
                    OLines.isExisting = true;
                }else{
                    OLines.isExisting = false;
                }
                OLRecords.add(OLines);
            }
            
            if(isValid){
                Response.isSuccess 		= true;
                Response.result 		= 'Order and Order Line items upserted Successfully.';
                Response.Orders 		= getOrders(OpportunityLst,ExistingOpportunityLst);
                Response.OrderLines 	= OLRecords;
            }else{
                Response.isSuccess = false;
                Response.result = ErrorMsg;
            }            
        }catch(Exception ex){
            Response.isSuccess = false;
            Response.result = ex.getMessage();
        }
        return Response;
    }
    
    public static Map<String,List<Activity_Product__c>> handleKMSKAProductUpdate(Map<String,Activity_Product__c> activitiesToUpdate, Set<String> oppGTId){
        Map<String,List<Activity_Product__c>> response = new Map<String,List<Activity_Product__c>>();
        
        List<Activity_Product__c> existingProducts = [SELECT Id, Opportunity__c,Opportunity__r.GT_Unique_ID__c, KMSKA_Product__c, KMSKA_Product__r.GT_ID__c, Start_Time__c, Status__c 
                                                      FROM Activity_Product__c
                                                      WHERE Opportunity__r.GT_Unique_ID__c IN:oppGTId
                                                      AND (Status__c = 'Aangevraagd' OR Status__c='Ingepland')];
        
        Map<String,Map<String,Activity_Product__c>> activityProductMap = new Map<String,Map<String,Activity_Product__c>>();
        for(Activity_Product__c AP: existingProducts){
            if(!activityProductMap.containsKey(AP.Opportunity__r.GT_Unique_ID__c)){
                activityProductMap.put(AP.Opportunity__r.GT_Unique_ID__c, new Map<String,Activity_Product__c>());
            }
            activityProductMap.get(AP.Opportunity__r.GT_Unique_ID__c)
                .put(AP.KMSKA_Product__r.GT_ID__c+AP.Start_Time__c, AP);
        }
        
        Map<String,Activity_Product__c> apToInsert = new Map<String,Activity_Product__c>();
        List<String> apToIngnore = new List<String>();
        List<Activity_Product__c> apToUpdate = new List<Activity_Product__c>();
        
        for(String key : activitiesToUpdate.keySet()){
            Activity_Product__c AP = activitiesToUpdate.get(key);
            if(!activityProductMap.containsKey(AP.Opportunity__r.GT_Unique_ID__c)){
                apToInsert.put(key,AP);
            }else if(!activityProductMap.get(AP.Opportunity__r.GT_Unique_ID__c).containsKey(key)){
                apToInsert.put(key,AP);
            }
            apToIngnore.add(key);
        }
        
        for(String key : activityProductMap.keySet()){
            for(String k : activityProductMap.get(key).keySet()){
                if(!apToIngnore.contains(k)){
                    Activity_Product__c AP = activityProductMap.get(key).get(k);
                    AP.Status__c = 'Annulatie';
                    apToUpdate.add(AP);
                }
            }
        }
        
        if(!apToInsert.isEmpty()){
            response.put('insert',apToInsert.values());
        }else{
            response.put('insert',new List<Activity_Product__c>());
        }
        response.put('update',apToUpdate);
        return response;
    }
    
    public static Map<String,KMSKA_Product__c> getKMSKAProduct(KMSKA_Product__c Activity){
        Map<String,KMSKA_Product__c> activityProdMap = new Map<String,KMSKA_Product__c>();
        List<KMSKA_Product__c> products = [SELECT Id, Name, GT_ID__c, Duration_in_min__c,Type__c
                                           FROM KMSKA_Product__c 
                                           WHERE GT_ID__c =: Activity.GT_ID__c
                                          ];
        for(KMSKA_Product__c pro : products){
            activityProdMap.put(pro.GT_ID__c, pro);
        }
        return activityProdMap;
    }
    
    public static List<Result> getOrders(List<Opportunity> OpportunityLst,Map<Id,Opportunity> ExistingOpportunityLst){
        List<Result> Records = new List<Result>();
        
        for(Opportunity opp : OpportunityLst){
            Result Order = new Result();
            Order.ExternalId = opp.GT_Unique_ID__c;
            Order.SFId = opp.Id;
            if(ExistingOpportunityLst.size()>0 && ExistingOpportunityLst.containsKey(opp.Id)){
                Order.isExisting = true;
            }else{
                Order.isExisting = false;
            }
            Records.add(Order);
        }
        return Records;
    }
    
    public static List<Result> getOrderLines(List<Order_Line__c> OrdersLines){
        List<Result> Records = new List<Result>();
        
        for(Order_Line__c OL : OrdersLines){
            Result OrderLine = new Result();
            OrderLine.ExternalId = OL.GT_Unique_ID__c;
            OrderLine.SFId = OL.Id;
            OrderLine.isExisting = false;
            Records.add(OrderLine);
        }
        return Records;
    }
    
    public static List<Result> getActivities(List<Activity_Product__c> ActivityLst){
        List<Result> Records = new List<Result>();
        
        for(Activity_Product__c AP : ActivityLst){
            Result Activity = new Result();
            Activity.ExternalId = AP.KMSKA_Product__r.GT_Id__c;
            Activity.SFId = AP.Id;
            Activity.isExisting = false;
            Records.add(Activity);
        }
        return Records;
    }
    
    public static String getQueryString(Map<String,String> params){
        String query = '';
        for(String key: params.keySet()){
            if(query!='')query+='&';
            query+= key+'='+params.get(key);
        }
        return query;
    }
    
    Global class APIResponse{
        public String result;
        public Boolean isSuccess;
        public List<Result> Orders;
        public List<Result> Contact;
        public List<Result> Organisation;
        public List<Result> OrderLines;
        public List<Result> Activities;
    }
    
    Global class Result{
        public String ExternalId;
        public String SFId;
        public Boolean isExisting;
    }
    
    public class APIException extends Exception {}
}