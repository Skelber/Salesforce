import { api, LightningElement, track, wire } from 'lwc';
import searchProjects from '@salesforce/apex/ShowroomVisitCreationHelper.searchProjects';
import ADDRESS_FIELD from '@salesforce/schema/Opportunity.Project_Address__c';
import PMC_FIELD from '@salesforce/schema/Opportunity.PMC__c';
import OWNER_FIELD from '@salesforce/schema/Opportunity.OwnerId';
import PRODUCT_GROUP_FIELD from '@salesforce/schema/Opportunity.Product_Group__c';
import PROJECT_TYPE_FIELD from '@salesforce/schema/Opportunity.Project_Type__c';
import ACCOUNT_FIELD from '@salesforce/schema/Opportunity.AccountId';
import START_DATE_FIELD from '@salesforce/schema/Opportunity.CloseDate';
import FOLLOW_UP_DATE_FIELD from '@salesforce/schema/Opportunity.Follow_Up_Date__c';
import VISIT_REPORT_ACCOUNT_FIELD from '@salesforce/schema/Visit_Report__c.Contact__r.Account.RecordType.DeveloperName';
import searchProducts from '@salesforce/apex/ShowroomVisitCreationHelper.searchProducts';
import getProjectVisits from '@salesforce/apex/ShowroomVisitCreationHelper.getProjectVisits';
import addProductToProject from '@salesforce/apex/ShowroomVisitCreationHelper.addProductToProject';
import updateLineItem from '@salesforce/apex/ShowroomVisitCreationHelper.updateLineItem';
import LightningConfirm from "lightning/confirm";
import { NavigationMixin } from 'lightning/navigation';
import getCountryOptions from '@salesforce/apex/ShowroomVisitCreationHelper.getCountryOptions';
import removeLineItem from '@salesforce/apex/ShowroomVisitCreationHelper.removeLineItem';
import {getFieldValue, getRecord, createRecord, updateRecord, deleteRecord} from "lightning/uiRecordApi";
import LINE_ITEM_ID_FIELD from '@salesforce/schema/OpportunityLineItem.Id';
import LINE_ITEM_AMOUNT_FIELD from '@salesforce/schema/OpportunityLineItem.Amount_m__c';
import LINE_ITEM_QUANTITY_FIELD from '@salesforce/schema/OpportunityLineItem.Quantity';
import LINE_ITEM_QUANTITY_WF_FIELD from '@salesforce/schema/OpportunityLineItem.Quantity_in_WF__c';
import { handleException, showInfoToast, showSuccessToast, notifyParent } from 'c/utils';
import getProjectDetails from '@salesforce/apex/ShowroomVisitCreationHelper.getProjectDetails';
import PROJECT_VISIT_PROJECT_ID from '@salesforce/schema/Project_Visit__c.Project__c';
import PROJECT_VISIT_VISIT_REPORT_ID from '@salesforce/schema/Project_Visit__c.Visit_Report__c';
import PROJECT_VISIT_OBJECT from '@salesforce/schema/Project_Visit__c';

export default class ShowroomProjectSelection extends NavigationMixin(LightningElement) {   
    @api
    visitReportId;
    projectVisits = [];
    projectFields = [
        ACCOUNT_FIELD,
        PMC_FIELD,
        OWNER_FIELD,
        PRODUCT_GROUP_FIELD,
        PROJECT_TYPE_FIELD,
        START_DATE_FIELD,
        FOLLOW_UP_DATE_FIELD,
        ADDRESS_FIELD
    ];
    loading = false;
    saving = false;
    @track products = [];
    selectedProjectVisitId;
    timer;
    lineItems = [];

    @wire(getRecord, { recordId: '$visitReportId', fields: [VISIT_REPORT_ACCOUNT_FIELD]})
    wiredVisitReport;

    @wire(getCountryOptions, {})
    wiredCountryOptions;

    async connectedCallback() {
        this.loading = true;
        this.projectVisits = await getProjectVisits({visitReportId: this.visitReportId});
        if (this.projectVisits.length) {
            this.selectedProjectVisitId = this.projectVisits[0].id;
            this.setSelectedTab();
        }
        this.loading = false;
    }

    get flowInput() {
        return [
            {
                name: 'visitReportId',
                type: 'String',
                value: this.visitReportId
            }
        ];
    }

    get showSpinner() {
        return this.saving || this.loading;
    }

    async handleProjectSearch(event) {
        const lookupElement = event.target;
        const { searchTerm, selectedIds } = event.detail;
        try {
            const results = await searchProjects({
                visitReportId: this.visitReportId,
                searchTerm,
                selectedIds
            });
            lookupElement.setSearchResults(results);
        } catch (error) {
            handleException.call(this, error);
        }
    }

    async handleProductSearch(event) {
        const lookupElement = event.target;
        const { searchTerm } = event.detail;
        try {
            const results = await searchProducts({
                searchTerm
            });
            lookupElement.setSearchResults(results);
        } catch (error) {
            handleException.call(this, error);
        }
    }

    async handleProjectSelectionChange(event) {
        const selection = event.target.getSelection();
        const project = selection[selection.length - 1];

        const existing = this.projectVisits.find(projectVisit => projectVisit.projectId === project.id);
        if (existing) {
            return;
        }

        await this.addProjectToVisitReport(project.id);
    }

    async handleSelectedProjectChange(event) {
        try {
            this.selectedProjectVisitId = event.target.value;
            this.lineItems = await getProjectDetails({ projectVisitId: this.selectedProjectVisitId});
        } catch (error) {
            handleException.call(this, error);
        }
    }

    handleNewProject() {
        this.selectedProjectVisitId = null;
        this.lineItems = [];
    }

    async handleProductSelectionChange(event) {
        const selection = event.target.getSelection();
        const product = selection[selection.length - 1];

        const existing = !!this.lineItems.find(li => li.productId === product.id);
        if (product && !existing) {
            this.saving = true;
            try {
                const newLineItem = await addProductToProject({
                    projectId: this.projectVisits.find(pv => pv.id === this.selectedProjectVisitId).projectId,
                    productId: product.id
                });

                this.lineItems = [...this.lineItems, newLineItem];
                this.saving = false;
                showSuccessToast.call(this, 'product added');
            } catch(e) {
                handleException.call(this, e);
                this.saving = false;
            }
        }
    }

    async removeProject(event) {
        const {id} = event.target.dataset;

        const confirmed = await LightningConfirm.open({
            theme: 'warning',
            message: 'Do you really want to remove this project from the visit report?',
            variant: 'header',
            label: 'Are you sure?',
        });

        if (!confirmed) {
            return;
        }

        try {
            this.saving = true;
            await deleteRecord(id);
            this.projectVisits = this.projectVisits.filter(projectVisit => projectVisit.id !== id);
            this.saving = false;
            showSuccessToast.call(this, 'Project removed from visit report');
        } catch(e) {
            handleException.call(this, e);
            this.saving = false;
        }
    }

    async removeLineItem(event) {
        const {id} = event.target.dataset;
        console.log('removeLineItem', id);

        const confirmed = await LightningConfirm.open({
            theme: 'warning',
            message: 'Do you really want to remove this product from the project?',
            variant: 'header',
            label: 'Are you sure?',
        });

        if (!confirmed) {
            return;
        }

        try {
            this.saving = true;
            await removeLineItem({lineItemId: id});
            this.lineItems = this.lineItems.filter(p => p.id !== id);
            this.saving = false;
            showSuccessToast.call(this, 'Product removed from visit report')
        } catch(e) {
            handleException.call(this, e);
            this.saving = false;
        }
    }

    async handleLineItemAmountM2Change(event) {
        clearTimeout(this.timer);

        const amountM2 = event.detail.value;
        const {id} = event.target.dataset;

        this.timer = setTimeout(async() => {
            try {
                this.saving = true;
                const fields = {};
                fields[LINE_ITEM_ID_FIELD.fieldApiName] = id;
                fields[LINE_ITEM_AMOUNT_FIELD.fieldApiName] = amountM2;
                fields[LINE_ITEM_QUANTITY_FIELD.fieldApiName] = 1;
                fields[LINE_ITEM_QUANTITY_WF_FIELD.fieldApiName] = 0;
                await updateRecord({ fields });
                this.saving = false;
                showSuccessToast.call(this, 'Amount m2 has been updated');
            } catch(e) {
                handleException.call(this, e);
                this.saving = false;
            }
        }, 300);
    }


    async handleLineItemSampleProvidedChange(event) {
        try {
            this.saving = true;
            const sampleProvided = event.detail.checked;
            const {id} = event.target.dataset;

            await updateLineItem({projectVisitId: this.selectedProjectVisitId, lineItemId: id, sampleProvided});
            this.saving = false;
            showSuccessToast.call(this, 'Product has been updated');
        } catch(e) {
            handleException.call(this, e);
            this.saving = false;
        }
    }

    async handleFlowStatusChange(event) {
        if (event.detail.status === "FINISHED") {
            const outputVariables = event.detail.outputVariables;
            for (let i = 0; i < outputVariables.length; i++) {
                const outputVar = outputVariables[i];
                console.log(outputVar);
                if(outputVar.name === 'varProjectVisit') {
                    this.selectedProjectVisitId = outputVar.value.Id;
                    this.projectVisits = await getProjectVisits({visitReportId: this.visitReportId});
                    this.setSelectedTab();
                }
            }
        }
    }

    async addProjectToVisitReport(projectId) {
        try {
            this.saving = true;

            const fields = {};
            fields[PROJECT_VISIT_PROJECT_ID.fieldApiName] = projectId;
            fields[PROJECT_VISIT_VISIT_REPORT_ID.fieldApiName] = this.visitReportId;
            const recordInput = { apiName: PROJECT_VISIT_OBJECT.objectApiName, fields};
            const projectVisit = await createRecord(recordInput);
            
            this.selectedProjectVisitId = projectVisit.id;
            this.projectVisits = await getProjectVisits({visitReportId: this.visitReportId});
            this.saving = false;

            showSuccessToast.call(this, 'Project added to visit report');
            this.setSelectedTab();
       } catch(e) {
            handleException.call(this, e);
            this.saving = false;
       }
    }

    setSelectedTab() {
        setTimeout(() => {
            this.template.querySelector('lightning-tabset').activeTabValue = this.selectedProjectVisitId;
        }, 250)
    }
}