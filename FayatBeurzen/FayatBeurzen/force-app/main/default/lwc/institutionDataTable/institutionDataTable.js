import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PREFERRED_EDUCATION_INSTITUTION_FIELD from '@salesforce/schema/Preferred_Education__c.Preferred_Education_Institution__c';
import PREFERRED_EDUCATION_DOMAIN_FIELD from '@salesforce/schema/Preferred_Education__c.Preferred_Education_Domain__c';
import PREFERRED_EDUCATION_OBJECT from '@salesforce/schema/Preferred_Education__c';

export default class MyComponent extends LightningElement {
    @api recordId;
    @track preferredInstitution;
    @track preferredDomain
    educationList;
    @track institutionOptions

    const
     columns = [
        { label: 'Education', fieldName: 'label' }
    ];


    @wire(getObjectInfo, {objectApiName: PREFERRED_EDUCATION_OBJECT})
    objectInfo;

    @wire(getPicklistValues, {recordTypeId: "012000000000000AAA", fieldApiName : PREFERRED_EDUCATION_DOMAIN_FIELD})
    preferredDmainValues({ error, data }) {
        console.log('Data '+ JSON.stringify(data));
        if (data) {
            this.preferredDomain = data.values;
        } else if (error) {

        }
    }
    
    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: PREFERRED_EDUCATION_INSTITUTION_FIELD})
    wiredPicklistValues({ error, data }) {
        console.log('Data '+ JSON.stringify(data));
        if (data) {
            this.preferredInstitutionData = data;
        } else if (error) {

        }
    }

    handleDomainChange(event){
        let key = this.preferredInstitutionData.controllerValues[event.target.value];
        this.institutionOptions = this.preferredInstitutionData.values.filter(opt => opt.validFor.includes(key));
    }
    
}

