import { api, LightningElement, wire } from 'lwc';
import searchContactAndLeads from '@salesforce/apex/ShowroomVisitCreationHelper.searchContactAndLeads';
import VISIT_REPORT_ID_FIELD from '@salesforce/schema/Visit_Report__c.Id';
import VISIT_REPORT_CONTACT_FIELD from '@salesforce/schema/Visit_Report__c.Contact__c';
import VISIT_REPORT_ACCOUNT_FIELD from '@salesforce/schema/Visit_Report__c.Account__c';
import INVOLVEMENT_OBJECT from "@salesforce/schema/Project_Relation__c";
import INVOLVEMENT_VISIT_REPORT_ID_FIELD from '@salesforce/schema/Project_Relation__c.Visit_Report__c';
import INVOLVEMENT_CONTACT_ID_FIELD from '@salesforce/schema/Project_Relation__c.Contact_Ref__c';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import searchAccounts from '@salesforce/apex/ShowroomVisitCreationHelper.searchAccounts';
import getCountryOptions from '@salesforce/apex/ShowroomVisitCreationHelper.getCountryOptions';
import getContactDetails from '@salesforce/apex/ShowroomVisitCreationHelper.getContactDetails';
import { handleException, showInfoToast, showSuccessToast } from 'c/utils';

export default class ShowroomContactDetails extends LightningElement {
    @api visitReportId;
    @api createExtraContact = false;
    @api firstContactLinked;
    selectedEntity; // {id, sObjectType, icon, title, subtitle}
    selectedAccount; // {id, sObjectType, icon, title, subtitle}
    selectedAddress = {};
    saving = false;

    @wire(getCountryOptions, {})
    wiredCountryOptions;

    @api
    validate() {
        if (this.isLeadSelected) {
            showInfoToast.call(this, 'Convert the lead first before proceeding.');
            return {
                isValid: false,
                errorMessage: ''
            };
        }

        if (!this.validateFields()) {
            showInfoToast.call(this, 'Fill in all contact fields before proceeding.');
            return{
                isValid: false,
                errorMessage: ''
            }
        }

        return {
            isValid: true,
        };
    }

    async connectedCallback() {
        await this.getContactDetails();
    }

    async getContactDetails() {
        try {
            const data = await getContactDetails({visitReportId: this.visitReportId});
            this.selectedEntity = data.selectedContact || data.selectedLead;
            this.selectedAccount = data.selectedAccount;
            this.selectedAddress = data.selectedAddress || {};
        } catch (e) {
            handleException.call(this, e);
        }
    }

    get countries() {
        return this.wiredCountryOptions.data || [];
    }

    get isContactSelected() {
        return (
            this.selectedEntity && this.selectedEntity.sObjectType === 'Contact'
        );
    }

    get isLeadSelected() {
        return (
            this.selectedEntity && this.selectedEntity.sObjectType === 'Lead'
        );
    }

    get contactId() {
        return this.isContactSelected ? this.selectedEntity.id : null;
    }

    get saveButtonLabel() {
        if (this.isContactSelected) {
            return 'Update contact';
        } else if (this.isLeadSelected) {
            return 'Convert lead';
        }
        return 'Create new contact';
    }

    async handleContactSearch(event) {
        const lookupElement = event.target;
        const { searchTerm } = event.detail;
        try {
            const results = await searchContactAndLeads({
                searchTerm
            });
            lookupElement.setSearchResults(results);
        } catch (error) {
            handleException.call(this, error);
        }
    }

    async handleContactLookupChange(event) {
        const selection = event.target.getSelection();
        this.selectedEntity = selection[0];
        this.selectedAccount = null;
        this.selectedAddress = {};

        if (this.contactId) {
            await this.linkVisitReportAndContact();
            await this.getContactDetails();           
        }
    }

    async handleAccountSearch(event) {
        const lookupElement = event.target;
        const { searchTerm } = event.detail;
        try {
            const results = await searchAccounts({
                searchTerm
            });
            lookupElement.setSearchResults(results);
        } catch (error) {
            handleException.call(this, error);
        }
    }

    async handleAccountLookupChange(event) {
        const selection = event.target.getSelection();
        this.selectedAccount = selection[0];
    }

    async handleCreateExtraContactChange(event) {
        this.createExtraContact = event.target.checked;
    }

    handleSubmit(event) {
        event.preventDefault();
        this.saving = true;

        const fields = event.detail.fields;
        fields.AccountId = this.selectedAccount.id;
        const address = this.template.querySelector('lightning-input-address');
        fields.MailingCity = address.city;
        fields.MailingStreet = address.street;
        fields.MailingPostalCode = address.postalCode;
        fields.MailingCountryCode = address.country;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    async handleSaveSuccess(event) {
        this.saving = false;
        showSuccessToast.call(this, 'Contact has been saved');
        if(!this.firstContactLinked){
            await this.linkVisitReportAndContact();
        }
        await this.createInvolvement();
        await this.getContactDetails();
    }

    handleError() {
        this.saving = false;
    }

    async linkVisitReportAndContact() {
        try {
            const fields = {};
            fields[VISIT_REPORT_ID_FIELD.fieldApiName] = this.visitReportId;
            fields[VISIT_REPORT_CONTACT_FIELD.fieldApiName] = this.contactId;
            await updateRecord({ fields });
        } catch (e) {
            handleException.call(this, error);
        }
    }

    async createInvolvement(){
        try {
            const fields={};
            fields[INVOLVEMENT_VISIT_REPORT_ID_FIELD.fieldApiName] = this.visitReportId;
            fields[INVOLVEMENT_CONTACT_ID_FIELD.fieldApiName] = this.contactId;

            const recordInput = { apiName: INVOLVEMENT_OBJECT.objectApiName, fields };
            await createRecord(recordInput);
        } catch (e){
            handleException.call(this, error);
        }
    }

    async handleConvertLead() {
        window.open('/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId=' + this.selectedEntity.id, '_blank');
    }

    validateFields() {
        return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);
    }
}