import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PREFERRED_EDUCATION_DOMAIN_FIELD from '@salesforce/schema/Preferred_Education__c.Preferred_Education_Domain__c';

export default class MyComponent extends LightningElement {
    @track preferredEducation;
    defaultRecordTypeId; 

    const
     columns = [
        { label: 'Education', fieldName: 'label' },
        { label: 'Value', fieldName: 'value' }
    ];

    get defaultRecordTypeId(){
        return this.preferredEducationObjectMetadata.data.defaultRecordTypeId;
}

    
    @wire(getPicklistValues, { recordTypeId: '01I7E000002PfJp', fieldApiName: PREFERRED_EDUCATION_DOMAIN_FIELD})

    picklistValues({ error, data }) {
        if (data) {
            const picklistValues = picklistValues;
            this.preferredEducation = picklistValues.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
            console.log("This is the data" + data);
        } else if (error) {
            console.error(error);
            console.log(data)
        }
    }
}

