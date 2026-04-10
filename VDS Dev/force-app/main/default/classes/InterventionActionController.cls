/**
 * Created by admin on 15/05/2025.
 */

public with sharing class InterventionActionController {

	@AuraEnabled(Cacheable = false)
	public static InterventionActionWrapper getAction(Id workStepId) {
		try {
			InterventionActionWrapper wrapper = new InterventionActionWrapper();
			WorkStep workStep = [SELECT Name, WorkOrderLineItemId, WorkOrderLineItem.RecordType.DeveloperName, WorkOrderLineItem.WorkOrder.Pricebook2Id FROM WorkStep WHERE Id = :workStepId];

			for(Intervention_Action__c interventionAction : [SELECT Id, Description__c, Problem_Location__c, Treated_Surface__c, Type__c, Combination_pigments_final__c  FROM Intervention_Action__c WHERE Type__c = :workStep.Name AND Work_Order_Line_Item__c = :workStep.WorkOrderLineItemId LIMIT 1]) {
				wrapper.interventionAction = interventionAction;
			}
			wrapper.isTestSurface = workStep.WorkOrderLineItem.RecordType.DeveloperName.equalsIgnoreCase('Test_Surface');
			wrapper.isIntervention = workStep.WorkOrderLineItem.RecordType.DeveloperName.equalsIgnoreCase('Intervention');
			wrapper.name = workStep.Name;

			List<ProductConsumed> productsConsumed = [SELECT Id, PricebookEntryId, Product2.Name, UnitPrice, QuantityConsumed FROM ProductConsumed WHERE WorkOrderLineItemId = :workStep.WorkOrderLineItemId AND Intervention_Action__c = :wrapper.interventionAction.Id ORDER BY Product2.Family, Product2.Name];
			for(PricebookEntry pricebookEntry : [SELECT Id, Product2.Name, Product2.Family, UnitPrice, Product2.Colour__c FROM PricebookEntry WHERE IsActive = TRUE AND Pricebook2Id = :workStep.WorkOrderLineItem.WorkOrder.Pricebook2Id AND Product2.Family != NULL AND Product2.Family != 'Travel' ORDER BY Product2.Family, Product2.Name]) {
				ProductWrapper productWrapper = new ProductWrapper(
						pricebookEntry.Id,
						pricebookEntry.Product2.Name,
						pricebookEntry.Product2.Family,
						0,
						pricebookEntry.Product2.Colour__c);
				for(ProductConsumed productConsumed : productsConsumed) {
					if(productConsumed.PricebookEntryId == pricebookEntry.Id) {
						productWrapper.quantity = productConsumed.QuantityConsumed;
						break;
					}
				}
				wrapper.productsConsumed.add(productWrapper);
			}

			return wrapper;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static void save(Id workStepId, InterventionActionWrapper wrapper, Datetime startTime, Datetime endTime) {

		try {
			WorkStep workStep = [SELECT Name, WorkOrderLineItemId, WorkOrderLineItem.WorkOrderId, workOrderLineItem.WorkTypeId FROM WorkStep WHERE Id = :workStepId];
			Intervention_Action__c interventionAction = wrapper.interventionAction;
			interventionAction.Type__c = workStep.Name;
			interventionAction.Work_Order_Line_Item__c = workStep.WorkOrderLineItemId;
			upsert interventionAction;

			List<ProductConsumed> productsConsumed = [SELECT Id FROM ProductConsumed WHERE WorkOrderLineItemId = :workStep.WorkOrderLineItemId AND Intervention_Action__c = :interventionAction.Id];
			delete productsConsumed;

			List<ProductConsumed> newProductsConsumed = new List<ProductConsumed>();
			for (ProductWrapper productConsumed : wrapper.productsConsumed) {
				if (productConsumed.quantity == 0) {
					continue;
				}
				newProductsConsumed.add(new ProductConsumed(
					WorkOrderLineItemId = workStep.WorkOrderLineItemId,
					WorkOrderId = workStep.WorkOrderLineItem.WorkOrderId,
					PricebookEntryId = productConsumed.pricebookEntryId,
					QuantityConsumed = productConsumed.quantity,
					Intervention_Action__c = interventionAction.Id
				));
			}
			insert newProductsConsumed;
			
			// Calculate total costs for intervention action and workorderlineitem
			interventionAction.Total_Cost__c = 0;

			WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(
				Id = workStep.WorkOrderLineItemId,
				Total_Cost__c = 0
			);
			for(ProductConsumed productConsumed : productsConsumed = [SELECT TotalPrice, Intervention_Action__c FROM ProductConsumed WHERE WorkOrderLineItemId = :workStep.WorkOrderLineItemId]) {
				workOrderLineItem.Total_Cost__c += productConsumed.TotalPrice;
				if (String.isNotBlank(productConsumed.Intervention_Action__c) && productConsumed.Intervention_Action__c == interventionAction.Id) {
					interventionAction.Total_Cost__c += productConsumed.TotalPrice;
				}
			}

			update workOrderLineItem;
			update interventionAction;
			
			ServiceResource sr = [
				SELECT Id
				FROM ServiceResource
				WHERE RelatedRecordId = :UserInfo.getUserId()
				LIMIT 1
			];

			Timesheet ts;

			List<Timesheet> existingTimesheets = [
				SELECT Id
				FROM Timesheet
				WHERE ServiceResourceId = :sr.Id
				AND StartDate <= :Date.today()
				AND EndDate >= :Date.today()
				LIMIT 1
			];

			if (!existingTimesheets.isEmpty()) {
				ts = existingTimesheets[0];
			} else {
				ts = new Timesheet(
					StartDate = Date.today(),
					EndDate = Date.today(),
					Status = 'Ingediend',
					ServiceResourceId = sr.Id
				);
				insert ts;
			}

			WorkType wt = [SELECT Id, Name FROM WorkType WHERE Id = :workStep.workOrderLineItem.WorkTypeId LIMIT 1];
			WorkOrder wo = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE Id = :workStep.WorkOrderLineItem.WorkOrderId LIMIT 1]; 
				
			TimeSheetEntry tse = new TimeSheetEntry(
				startTime = startTime,
				endTime = endTime,
				WorkOrderLineItemId = workOrderLineItem.Id,
				WorkOrderId = workStep.WorkOrderLineItem.WorkOrderId,
				TimeSheetId = ts.Id,
				Action__c = workStep.Name,
				Subject = wt.Name + ' - WO ' + wo.WorkOrderNumber
			);
			insert tse;

			workStep.Status = 'Voltooid';
			update workStep;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class InterventionActionWrapper {
		@AuraEnabled
		public String name {get; set;}
		@AuraEnabled
		public Boolean isTestSurface {get; set;}
		@AuraEnabled
		public Boolean isIntervention {get; set;}
		@AuraEnabled
		public Intervention_Action__c interventionAction {get; set;}
		@AuraEnabled
		public List<ProductWrapper> productsConsumed {get; set;}

		public InterventionActionWrapper() {
			this.interventionAction = new Intervention_Action__c();
			this.productsConsumed = new List<ProductWrapper>();
		}
	}

	public class ProductWrapper {
		@AuraEnabled
		public Id pricebookEntryId {get; set;}
		@AuraEnabled
		public String productName {get; set;}
		@AuraEnabled
		public String productFamily {get; set;}
		@AuraEnabled
		public Decimal quantity {get; set;}
		@AuraEnabled
		public String colour {get; set;}

		public ProductWrapper() {}

		public ProductWrapper(Id pricebookEntryId, String productName, String productFamily, Decimal quantity, String colour) {
			this.pricebookEntryId = pricebookEntryId;
			this.productName = productName;
			this.productFamily = productFamily;
			this.quantity = quantity;
			this.colour = colour;
		}
	}
}