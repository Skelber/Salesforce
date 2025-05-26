public class WorktypeSelection {
    
    public WorktypeSelection () { }
    
    @AuraEnabled(cacheable=true) 
    public static String getJSON() {
        
        List<WorkTypeGroup> typologies = new List<WorkTypeGroup>([
            SELECT Id, IsActive, Name, Business_Unit_Lookup__c, Appointment_Type_Lookup__c, Product_Group_Lookup__c, Product_Sub_Group_Lookup__c
              FROM WorkTypeGroup 
             WHERE IsActive = TRUE AND Visible_on_website__c = TRUE
        ]);
        
        List<Work_Type_Typology__c> typologyList = new List<Work_Type_Typology__c>([
            SELECT Id, Name, 
            	   Guiding_Text_EN__c, Guiding_Text_NL__c, Guiding_Text_FR__c, 
            	   Image_Link__c, Typology_Name_NL__c, Typology_Name_FR__c            
              FROM Work_Type_Typology__c 
        ]);        
        Map<Id, Work_Type_Typology__c> typologyMap = new Map<Id, Work_Type_Typology__c>();
        typologyMap.putAll(new List<Work_Type_Typology__c>([SELECT Id, Name, 
                                                                   Guiding_Text_EN__c, Guiding_Text_NL__c, Guiding_Text_FR__c, 
                                                                   Image_Link__c, Typology_Name_NL__c, Typology_Name_FR__c            
                                                              FROM Work_Type_Typology__c]));
      
        //Map BUSINESS UNIT + all worktypes
        Map<Id, List<WorkTypeGroup>> buMap = new Map<Id, List<WorkTypeGroup>>();
        List<BusinessUnit> buList = new List<BusinessUnit>();
        for(WorkTypeGroup wtg : typologies) {
            if(!buMap.containsKey(wtg.Business_Unit_Lookup__c)) {
                buMap.put(wtg.Business_Unit_Lookup__c, new List<WorkTypeGroup>());
            }
            buMap.get(wtg.Business_Unit_Lookup__c).add(wtg);
        }
        
        //Map BUSINESS UNIT + Map PRODUCT GROUP + all worktypes
        for(Id id2 : buMap.keySet()) {        
            
            Map<Id, List<WorkTypeGroup>> pgMap = new Map<Id, List<WorkTypeGroup>>();
        	List<ProductGroup> pgList = new List<ProductGroup>();
            for(WorkTypeGroup wtg2 : buMap.get(id2)) {
                if(!pgMap.containsKey(wtg2.Product_Group_Lookup__c)) {
                    pgMap.put(wtg2.Product_Group_Lookup__c, new List<WorkTypeGroup>());
                }
                pgMap.get(wtg2.Product_Group_Lookup__c).add(wtg2);
            }            
            
            //Map BUSINESS UNIT + Map PRODUCT GROUP + Map PRODUCT SUB-GROUP + all worktypes
            for(Id id3 : pgMap.keySet()) {            
                Map<Id, List<WorkTypeGroup>> psgMap = new Map<Id, List<WorkTypeGroup>>();
        		List<ProductSubGroup> psgList = new List<ProductSubGroup>();
                for(WorkTypeGroup wtg3 : pgMap.get(id3)) {
                    if(!psgMap.containsKey(wtg3.Product_Sub_Group_Lookup__c)) {
                        psgMap.put(wtg3.Product_Sub_Group_Lookup__c, new List<WorkTypeGroup>());
                    }
                    psgMap.get(wtg3.Product_Sub_Group_Lookup__c).add(wtg3);
                }
                
            	//Map BUSINESS UNIT + Map PRODUCT GROUP + Map PRODUCT SUB-GROUP + Map APPOINTMENT TYPE + all worktypes
                for(Id id4 : psgMap.keySet()) {
        			List<WorkType2> atList = new List<WorkType2>();
                    for(WorkTypeGroup wtg4 : psgMap.get(id4)) {

                        if(wtg4.Appointment_Type_Lookup__c <> null){
                            Work_Type_Typology__c typ = typologyMap.get(wtg4.Appointment_Type_Lookup__c);
                            WorkType2 at = new WorkType2(typ.Guiding_Text_EN__c, typ.Guiding_Text_FR__c, typ.Guiding_Text_NL__c, 
                                                       									   typ.Image_Link__c, typ.Name, typ.Typology_Name_FR__c, typ.Typology_Name_NL__c, typ.id);
                            atList.add(at); 
                        }
                        
                    }
                    
                    if(id4 <> null) {
                        Work_Type_Typology__c typ = typologyMap.get(id4);
                        WorkType2 psg = new WorkType2(typ.Guiding_Text_EN__c, typ.Guiding_Text_FR__c, typ.Guiding_Text_NL__c, 
                                                    									typ.Image_Link__c, typ.Name, typ.Typology_Name_FR__c, typ.Typology_Name_NL__c, typ.id);
                        ProductSubGroup item = new ProductSubGroup(psg, atList);
                        psgList.add(new ProductSubGroup (psg, atList)); 
                    }
                    
                }
                
                if(id3 <> null) {
                    Work_Type_Typology__c typ = typologyMap.get(id3);
                    WorkType2 pg = new WorkType2(typ.Guiding_Text_EN__c, typ.Guiding_Text_FR__c, typ.Guiding_Text_NL__c, 
                                               									   typ.Image_Link__c, typ.Name, typ.Typology_Name_FR__c, typ.Typology_Name_NL__c, typ.id);
                    pgList.add(new ProductGroup (pg, psgList));     
                }
                
            }
            
            if(id2 <> null) {
                Work_Type_Typology__c typ = typologyMap.get(id2);
                WorkType2 bu = new WorkType2(typ.Guiding_Text_EN__c, typ.Guiding_Text_FR__c, typ.Guiding_Text_NL__c, 
                                           									   typ.Image_Link__c, typ.Name, typ.Typology_Name_FR__c, typ.Typology_Name_NL__c, typ.id);
                buList.add(new BusinessUnit (bu, pgList));
            }
        }
        String JSONstring = JSON.serializePretty(buList);
        //System.debug(JSONstring);
        return JSONString;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getWorkType(Id BusinessUnitId, Id ProductGroupId, Id ProductSubGroupId, Id AppointmentId) {
        
        List<WorkTypeGroupMember> wtgroupmember = new List<WorkTypeGroupMember>([SELECT Id, WorkTypeId, WorkTypeGroupId, WorkTypeGroup.Bookable_on_website__c,
                                                                                 		WorkType.ApptStartTimeIntvlInMin, WorkType.EstimatedDuration, WorkType.Name
                                                                                   FROM WorkTypeGroupMember
                                                                                  WHERE WorkTypeGroup.Appointment_Type_Lookup__c = :AppointmentId
                                                                                        AND WorkTypeGroup.Business_Unit_Lookup__c = :BusinessUnitId
                                                                                        AND WorkTypeGroup.Product_Group_Lookup__c = :ProductGroupId
                                                                                        AND WorkTypeGroup.Product_Sub_Group_Lookup__c = :ProductSubGroupId
                                                                                        AND WorkTypeGroup.isActive = TRUE
                                                                                       AND WorkTypeGroup.Visible_on_website__c = TRUE]);
        FullWorkType fullwt;        
        if(wtGroupMember.size() > 0) 
            fullwt = new FullWorkType (wtgroupmember[0].WorkType.Name, wtgroupmember[0].WorkType.ApptStartTimeIntvlInMin, 
                                       wtgroupmember[0].WorkType.EstimatedDuration, wtgroupmember[0].WorkTypeId, wtgroupmember[0].WorkTypeGroup.Bookable_on_website__c);
        
        String JSONstring = JSON.serializePretty(fullwt);
        return JSONString;
    }
    
    
/*	########################################     INNER CLASSES	   ########################################*/
    private class BusinessUnit {
        
        private WorkType2 businessUnit {get; set;}
        private List<ProductGroup> productGroups {get; set;}
        
        private BusinessUnit (WorkType2 bu, List<ProductGroup> pgs) {
            businessUnit = bu;
            productGroups = pgs;
        }
        
    }
    
    private class ProductGroup {
        
        private WorkType2 productGroup {get; set;}
        private List<ProductSubGroup> productSubGroups {get; set;}
        
        private ProductGroup (WorkType2 pg, List<ProductSubGroup> psgs) {
            productGroup = pg;
            productSubGroups = psgs;
        }
        
    }
    
    private class ProductSubGroup {
        
        private WorkType2 productSubGroup {get; set;}
        private List<WorkType2> appointmentTypes {get; set;}
        
        private ProductSubGroup (WorkType2 psg, List<WorkType2> ats) {
            productSubGroup = psg;
            appointmentTypes = ats;
        }
        
    }
    
    private class WorkType2 {
        
        private String Guiding_Text_EN  {get; set;}
        private String Guiding_Text_FR  {get; set;}
        private String Guiding_Text_NL  {get; set;}
        private String Image_Link       {get; set;}
        private String Typology_Name_EN {get; set;}
        private String Typology_Name_FR {get; set;}
        private String Typology_Name_NL {get; set;}
        private String recordId			{get; set;}
        
        private WorkType2 (String gtEN, String gtFR, String gtNL, String image, String tnEN, String tnFR, String tnNL, String id) {
            Guiding_Text_EN = gtEN;
            Guiding_Text_FR = gtFR;
            Guiding_Text_NL = gtNL;
            Image_Link = image;
            Typology_Name_EN = tnEN;
            Typology_Name_FR = tnFR;
            Typology_Name_NL = tnNL;
            recordId = id;
        }
        
    }
    
    private class FullWorkType {
        
        private String WorkTypeName {get; set;}
        private Integer StartTimeInterval {get; set;}
        private Decimal EstimatedDuration {get; set;}
        private Id RecordId {get; set;}
        private Boolean Bookable {get; set;}
        
        private FullWorkType (String wtn, Integer sti, Decimal ed, Id ri, Boolean b) {
            WorkTypeName = wtn;
            StartTimeInterval = sti;
            EstimatedDuration = ed;
            RecordId = ri;
            Bookable = b;
        }
        
    }
}