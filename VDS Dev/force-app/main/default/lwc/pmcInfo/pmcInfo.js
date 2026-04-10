/**
 * Created by Tom Vanhouche on 22/04/2024.
 */

import { api, LightningElement, wire } from 'lwc';
import getPMCInfo from '@salesforce/apex/PMCInfoController.getPMCInfo';
import { NavigationMixin } from 'lightning/navigation';
import viewPMC from '@salesforce/label/c.View_PMC';

export default class PmcInfo extends NavigationMixin(LightningElement) {
    @api recordId;
    pmcList = [];

    labels = {
        viewPMC
    };

    @wire(getPMCInfo, { accountId: '$recordId' })
    wiredPMCs({ error, data }) {
        console.log(error, data);
        if (data) {
            this.pmcList = data;
        }
    }

    get hasPMCs() {
        return this.pmcList.length;
    }

    viewPMC(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'PMC__c',
                actionName: 'view'
            }
        });
    }
}