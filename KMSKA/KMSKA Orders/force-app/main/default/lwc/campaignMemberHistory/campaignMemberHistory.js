import { LightningElement, api, track } from 'lwc';
import getCampaignMemberHistoryByCampaignMember from '@salesforce/apex/CampaignMemberHistoryController.getCampaignMemberHistoryByCampaignMember';

export default class CampaignMemberHistory extends LightningElement {
    @api recordId;

    columns = [
        { label: 'Nieuwe status', fieldName: 'New_Value__c' },
        { label: 'Vorige status', fieldName: 'Old_Value__c' },
        { label: 'Aangepast door', fieldName: 'Modified_By__c' },
        { label: 'Datum van wijziging', fieldName: 'CreatedDate', type: 'date', typeAttributes: {
            year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit'
        }}
    ];

    @track rows = [];
    sortedBy = 'CreatedDate';
    sortedDirection = 'desc';
    isLoading = false;
    error;

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        if (!this.recordId) {
            this.rows = [];
            return;
        }
        this.isLoading = true;
        getCampaignMemberHistoryByCampaignMember({ campaignMemberId: this.recordId })
            .then(result => {
                // The Apex already orders by CreatedDate DESC.
                // Assign directly; lightning-datatable will render as-is.
                this.rows = result || [];
                this.error = undefined;
            })
            .catch(err => {
                this.error = err;
                this.rows = [];
                // Keep logs minimal; no sensitive info
                // console.error(err);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}
