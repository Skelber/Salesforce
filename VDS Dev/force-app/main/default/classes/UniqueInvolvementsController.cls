/**
 * Created by Tom Vanhouche on 29/07/2024.
 */

public with sharing class UniqueInvolvementsController {

	@AuraEnabled(Cacheable = true)
	public static RelatedListController.TableWrapper getUniqueInvolvements(Id recordId, String involvementType) {
		try {
			if (involvementType.equalsIgnoreCase('Case')) {
				return getUniqueCases(recordId);
			}
			else if(involvementType.equalsIgnoreCase('Project')) {
				return getUniqueProjects(recordId);
			} else if (involvementType.equalsIgnoreCase('VisitReport')) {
				return getUniqueVisitReports(recordId);
			}
			return new RelatedListController.TableWrapper('');
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	private static RelatedListController.TableWrapper getUniqueCases(Id accountId) {
		RelatedListController.TableWrapper tableWrapper = new RelatedListController.TableWrapper('Case');
		tableWrapper.icon = 'standard:case';
		tableWrapper.showNewButton = true;

		// create the columns
		tableWrapper.columns.add(RelatedListController.createLookupColumn('Case', 'CaseNumber', 'CaseNumber', 'CaseURL'));
		tableWrapper.columns.add(RelatedListController.createColumn('Case', 'Subject'));
		tableWrapper.columns.add(RelatedListController.createColumn('Case', 'Legacy_Date_Time_Created__c'));
		RelatedListController.Column recordTypeColumn = RelatedListController.createColumn('Case', 'RecordTypeId');
		recordTypeColumn.fieldName = 'RecordType';
		recordTypeColumn.type = 'text';
		tableWrapper.columns.add(recordTypeColumn);
		tableWrapper.columns.add(RelatedListController.createLookupColumn('Case', 'Projects__c', 'ProjectName', 'ProjectURL'));
		tableWrapper.columns.add(RelatedListController.createColumn('Case', 'Status'));

		// filters
		List<Schema.PicklistEntry> statusValues = Utils.getPicklistValues('Case', 'Status');
		List<String> closedStatusses = new List<String>{'Closed', 'Not treater further', 'Informative', 'Internal Admin', 'Carried out', 'Site Report'};
		RelatedListController.Filter statusFilter = new RelatedListController.Filter('Status', Utils.retrieveLabelForField('Case', 'Status'));

		// standard selected should be al open statusses
		for(Schema.PicklistEntry statusValue : statusValues) {
			if(statusValue.active && !closedStatusses.contains(statusValue.getValue())) {
				statusFilter.selectedValues.add(statusValue.getLabel());
			}
		}

		Map<Id, Map<String, Object>> recordsMap = new Map<Id, Map<String, Object>>();
		for(Case caseRecord : [SELECT Id, CaseNumber, Subject, Legacy_Date_Time_Created__c, RecordTypeId, RecordType.Name, Projects__c, Projects__r.Name, toLabel(Status) 
						FROM Case WHERE Id IN (SELECT Case_Ref__c FROM Project_Relation__c WHERE Account_Ref__c = :accountId)]) {
			Map<String, Object> record = new Map<String,Object>();
			record.putAll(caseRecord.getPopulatedFieldsAsMap());

			// set custom fields
			record.put('RecordType', caseRecord.RecordType.Name);
			record.put('CaseURL', '/lightning/r/' + caseRecord.Id + '/view');

			if (caseRecord.Projects__c != null) {
				record.put('ProjectName', caseRecord.Projects__r.Name);
				record.put('ProjectURL', '/lightning/r/' + caseRecord.Projects__c + '/view');
			}

			// add options to filters
			statusFilter.addOption(caseRecord.Status, caseRecord.Status);

			tableWrapper.records.add(record);
		}

		// defaults
		tableWrapper.sortDirection = 'asc';
		tableWrapper.sortedBy = 'Legacy_Date_Time_Created__c';

		tableWrapper.filters.addAll(new List<RelatedListController.Filter>{statusFilter});

		return tableWrapper;
	}

	private static RelatedListController.TableWrapper getUniqueProjects(Id accountId) {
		RelatedListController.TableWrapper tableWrapper = new RelatedListController.TableWrapper('Opportunity');
		tableWrapper.icon = 'standard:opportunity';

		// create the columns
		tableWrapper.columns.add(RelatedListController.createLookupColumn('Opportunity', 'Name', 'Name', 'ProjectURL'));
		tableWrapper.columns.add(RelatedListController.createColumn('Opportunity', 'Project_Address__City__s'));
		tableWrapper.columns.add(RelatedListController.createColumn('Opportunity', 'Quantity__c'));
		tableWrapper.columns.add(RelatedListController.createColumn('Opportunity', 'Value_in_m2__c'));
		RelatedListController.Column statusColumn = RelatedListController.createColumn('Opportunity', 'Status__c');
		statusColumn.fieldName = 'StatusLabel';
		tableWrapper.columns.add(statusColumn);
		RelatedListController.Column stageColumn = RelatedListController.createColumn('Opportunity', 'StageName');
		stageColumn.fieldName = 'StageNameLabel';
		tableWrapper.columns.add(stageColumn);
		tableWrapper.columns.add(RelatedListController.createColumn('Opportunity', 'Follow_Up_Date__c'));
		tableWrapper.columns.add(RelatedListController.createLookupColumn('Opportunity', 'OwnerId', 'OwnerName', 'OwnerURL'));
		tableWrapper.columns.add(RelatedListController.createColumn('Opportunity', 'PMC__c'));
		tableWrapper.columns.add(RelatedListController.createColumn('Project_Relation__c', 'Main_Account__c'));
		tableWrapper.columns.add(RelatedListController.createColumn('Project_Relation__c', 'Winning_Partner__c'));
		tableWrapper.columns.add(RelatedListController.createColumn('Project_Relation__c', 'Lowest_Subscriber__c'));

		Map<Id, Map<String, Object>> recordsMap = new Map<Id, Map<String, Object>>();
		RelatedListController.Filter statusFilter = new RelatedListController.Filter('Status__c', Utils.retrieveLabelForField('Opportunity', 'Status__c'));
		RelatedListController.Filter recordTypeFilter = new RelatedListController.Filter('RecordType', Utils.retrieveLabelForField('Opportunity', 'RecordTypeId'));
		RelatedListController.Filter stageNameFilter = new RelatedListController.Filter('StageName', Utils.retrieveLabelForField('Opportunity', 'StageName'));
		RelatedListController.Filter pmcFilter = new RelatedListController.Filter('PMC__c', Utils.retrieveLabelForField('Opportunity', 'PMC__c'));
		RelatedListController.Filter ownerFilter = new RelatedListController.Filter('OwnerId', Utils.retrieveLabelForField('Opportunity', 'OwnerId'));
		RelatedListController.Filter roleFilter = new RelatedListController.Filter('Roles', Utils.retrieveLabelForField('Project_Relation__c', 'Role__c'));
		RelatedListController.Filter mainAccountFilter = new RelatedListController.Filter('MainAccount', Utils.retrieveLabelForField('Project_Relation__c', 'Main_Account__c'));
		mainAccountFilter.addOption('Yes', 'yes');
		mainAccountFilter.addOption('No', 'no');
		RelatedListController.Filter winningPartnerFilter = new RelatedListController.Filter('WinningPartner', Utils.retrieveLabelForField('Project_Relation__c', 'Winning_Partner__c'));
		winningPartnerFilter.addOption('Yes', 'yes');
		winningPartnerFilter.addOption('No', 'no');
		RelatedListController.Filter lowestSubscriberFilter = new RelatedListController.Filter('LowestSubscriber', Utils.retrieveLabelForField('Project_Relation__c', 'Lowest_Subscriber__c'));
		lowestSubscriberFilter.addOption('Yes', 'yes');
		lowestSubscriberFilter.addOption('No', 'no');

		// fetch the picklist entries for Status__c on Opportunity to create the correct filter options, the reason is that toLabel in a SOQL does not work
		// on a lookup record for some reason
		List<Schema.PicklistEntry> statusValues = Utils.getPicklistValues('Opportunity', 'Status__c');
		List<Schema.PicklistEntry> stageNameValues = Utils.getPicklistValues('Opportunity', 'StageName');

		for(Project_Relation__c projectRelation : [SELECT Id, Role__c, toLabel(Role__c) RoleLabel, Main_Account__c, Winning_Partner__c, Lowest_Subscriber__c, VDSProject_Ref__c, VDSProject_Ref__r.RecordType.DeveloperName, VDSProject_Ref__r.RecordType.Name, 
			VDSProject_Ref__r.Name,
			VDSProject_Ref__r.Status__c, VDSProject_Ref__r.StageName, VDSProject_Ref__r.Project_Address__City__s,
			VDSProject_Ref__r.Quantity__c, VDSProject_Ref__r.Value_in_m2__c, VDSProject_Ref__r.Follow_Up_Date__c,  VDSProject_Ref__r.OwnerId,
			VDSProject_Ref__r.Owner.Name, VDSProject_Ref__r.PMC__c FROM Project_Relation__c WHERE Account_Ref__c = :accountId AND VDSProject_Ref__c != NULL]) {
			if (!recordsMap.containsKey(projectRelation.VDSProject_Ref__c)) {
				// create the record from the soql record, use a map to add custom fields to it
				Map<String, Object> record = new Map<String,Object>();
				record.putAll(projectRelation.VDSProject_Ref__r.getPopulatedFieldsAsMap());

				// add custom fields
				record.put('RecordType', projectRelation.VDSProject_Ref__r.RecordType.DeveloperName);
				record.put('OwnerName', projectRelation.VDSProject_Ref__r.Owner.Name);
				record.put('OwnerURL', '/lightning/r/' + projectRelation.VDSProject_Ref__r.OwnerId + '/view');
				record.put('ProjectURL', '/lightning/r/' + projectRelation.VDSProject_Ref__c + '/view');
				String statusLabel = Utils.getPickListLabel(statusValues, projectRelation.VDSProject_Ref__r.Status__c);
				record.put('StatusLabel', statusLabel);
				String stageNameLabel = Utils.getPickListLabel(stageNameValues, projectRelation.VDSProject_Ref__r.StageName);
				record.put('StageNameLabel', stageNameLabel);
				record.put('Roles', new List<String>());
				record.put('MainAccount', 'no');
				record.put('WinningPartner', 'no');
				record.put('LowestSubscriber', 'no');

				// add options to the filters
				recordTypeFilter.addOption(projectRelation.VDSProject_Ref__r.RecordType.Name, projectRelation.VDSProject_Ref__r.RecordType.DeveloperName);
				statusFilter.addOption(statusLabel, projectRelation.VDSProject_Ref__r.Status__c);
				stageNameFilter.addOption(stageNameLabel, projectRelation.VDSProject_Ref__r.StageName);
				pmcFilter.addOption(projectRelation.VDSProject_Ref__r.PMC__c, projectRelation.VDSProject_Ref__r.PMC__c);
				ownerFilter.addOption(projectRelation.VDSProject_Ref__r.Owner.Name, projectRelation.VDSProject_Ref__r.OwnerId);

				recordsMap.put(projectRelation.VDSProject_Ref__c, record);
			}

			// add option to filter from relationship table
			roleFilter.addOption((String)projectRelation.get('RoleLabel'), projectRelation.Role__c);

			Map<String, Object> record = (Map<String, Object>)recordsMap.get(projectRelation.VDSProject_Ref__c);
			// set boolean fields
			if(projectRelation.Main_Account__c) {
				record.put('MainAccount', 'yes');
			}
			record.put('Main_Account__c', record.get('MainAccount') == 'yes');
			
			if(projectRelation.Winning_Partner__c) {
				record.put('WinningPartner', 'yes');
			}
			record.put('Winning_Partner__c', record.get('WinningPartner') == 'yes');
			
			if(projectRelation.Lowest_Subscriber__c) {
				record.put('LowestSubscriber', 'yes');
			}
			record.put('Lowest_Subscriber__c', record.get('LowestSubscriber') == 'yes');
			
			// add role to the records custom field so we can filter on it
			List<String> roles = (List<String>) record.get('Roles');
			roles.add(projectRelation.Role__c);
		}

		// default filters
		recordTypeFilter.selectedValues.add('VDS_Project');
		statusFilter.selectedValues.add('10');

		tableWrapper.records.addAll(recordsMap.values());
		tableWrapper.filters.addAll(new List<RelatedListController.Filter>{recordTypeFilter, statusFilter, stageNameFilter, pmcFilter, ownerFilter, roleFilter, mainAccountFilter, winningPartnerFilter, lowestSubscriberFilter});

		return tableWrapper;
	}

	private static RelatedListController.TableWrapper getUniqueVisitReports(Id accountId) {
		RelatedListController.TableWrapper tableWrapper = new RelatedListController.TableWrapper('Visit_Report__c');
		tableWrapper.icon = 'standard:custom';

		// create the columns
		tableWrapper.columns.add(RelatedListController.createColumn('Visit_Report__c', 'Visit_Purpose__c'));
		tableWrapper.columns.add(RelatedListController.createLookupColumn('Visit_Report__c', 'Name', 'Name', 'VisitReportURL'));
		tableWrapper.columns.add(RelatedListController.createLookupColumn('Visit_Report__c', 'OwnerId', 'OwnerName', 'OwnerURL'));
		tableWrapper.columns.add(RelatedListController.createColumn('Visit_Report__c', 'Visit_Date__c'));
		RelatedListController.Column recordTypeColumn = RelatedListController.createColumn('Visit_Report__c', 'RecordTypeId');
		recordTypeColumn.fieldName = 'RecordType';
		recordTypeColumn.type = 'text';
		tableWrapper.columns.add(recordTypeColumn);

		// fetch the data
		for(Visit_Report__c visitReport : [SELECT Id, Name, Visit_Purpose__c, OwnerId, Owner.Name, Visit_Date__c, RecordType.Name FROM Visit_Report__c WHERE Id IN (SELECT Visit_Report__c FROM Project_Relation__c WHERE Account_Ref__c = :accountId) WITH USER_MODE]) {
			Map<String, Object> record = new Map<String,Object>();
			record.putAll(visitReport.getPopulatedFieldsAsMap());

			// set custom fields
			record.put('RecordType', visitReport.RecordType.Name);
			record.put('OwnerName', visitReport.Owner.Name);
			record.put('OwnerURL', '/lightning/r/' + visitReport.OwnerId + '/view');
			record.put('VisitReportURL', '/lightning/r/' + visitReport.Id + '/view');

			tableWrapper.records.add(record);
		}

		// defaults
		tableWrapper.sortDirection = 'desc';
		tableWrapper.sortedBy = 'Visit_Date__c';

		return tableWrapper;
	}
}