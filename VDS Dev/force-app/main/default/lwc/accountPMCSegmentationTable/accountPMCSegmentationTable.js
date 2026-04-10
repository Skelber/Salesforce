import { LightningElement, api, track } from 'lwc';
import getAccountPMCSegmentations from '@salesforce/apex/AccountPMCSegmentationTableController.getAccountPMCSegmentations';
import getParameterValues from '@salesforce/apex/AccountPMCSegmentationTableController.getParameterValues';
import getSegmentValues from '@salesforce/apex/AccountPMCSegmentationTableController.getSegmentValues';
import saveSegmentations from '@salesforce/apex/AccountPMCSegmentationTableController.saveSegmentations';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOCAL from '@salesforce/i18n/locale'

export default class AccountPMCSegmentationTable extends LightningElement {
    @api recordId;
    @track segmentations = [];
    allParameterValues = [];
    changedRows = new Set();
    @track disableSavebutton = false;
    sumInterest
    sumPotential
    segment
    @track showSpinner = false;

    connectedCallback() {
        this.loadData();
    }

    async loadData() {
        try {
            const [segmentations, parameterValues, segment] = await Promise.all([
                getAccountPMCSegmentations({ recordId: this.recordId }),
                getParameterValues(),
                getSegmentValues({ recordId: this.recordId})
            ]);

            this.allParameterValues = parameterValues;
            this.sumInterest = segment.sumInterest;
            this.sumPotential = segment.sumPotential
            this.segment = segment.segment

            this.segmentations = segmentations.map((row, index) => ({
                ...row,
                SegmentationParameterName: row.Segmentation_Parameter__r?.Name,
                SegmentationParameterValue: row.Parameter_Value__c,
                picklistOptions: this.getFilteredOptions(row.Segmentation_Parameter__c),
                LastModifiedDisplay: row.LastModifiedDate 
                    ? new Date(row.LastModifiedDate).toLocaleDateString(LOCAL)
                    : '',
                rowNumber: index + 1
            }));
        } catch (error) {
            console.error('Error loading data:', error);
        }
    }

    getFilteredOptions(segParamId) {
        return this.allParameterValues
            .filter(v => v.Segmentation_Parameter__c === segParamId)
            .map(v => ({ label: v.Name, value: v.Id }));
    }

    handleValueChange(event) {
        const recordId = event.target.dataset.id;
        const newValueId = event.detail.value;
    
        const selectedValue = this.allParameterValues.find(v => v.Id === newValueId);
    
        this.segmentations = this.segmentations.map(row => {
            if (row.Id === recordId) {
                this.changedRows.add(recordId);
                this.disableSavebutton = this.changedRows.length > 0 ? false : true;
    
                // let weightedScore = null;
                // if (row.Segmentation_Parameter__r?.Weight_Parameter__c != null && selectedValue?.Score_10__c != null) {
                //     weightedScore = row.Segmentation_Parameter__r.Weight_Parameter__c * selectedValue.Score_10__c;
                // }
    
                return {
                    ...row,
                    SegmentationParameterValue: newValueId,
                    // Weighted_Score__c: weightedScore
                };
            }
            return row;
        });
    }

    handleSave() {
        this.showSpinner = true;
        const segmentationsToSave = this.segmentations
        .filter(row => this.changedRows.has(row.Id))
        .map(row => ({
            Id: row.Id,
            Parameter_Value__c: row.SegmentationParameterValue,
            // Weighted_Score__c: row.Weighted_Score__c
        }));

        if (segmentationsToSave.length === 0) {
            this.showToast('Info', 'No changes to save', 'info');
            this.showSpinner = false;
            return;
        }

        saveSegmentations({ segmentationsToSave })
            .then(() => {
                this.showToast('Success', 'Segmentations saved successfully', 'success');
                this.changedRows.clear();
                this.showSpinner = false;
                window.location.reload();
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || error.message, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}