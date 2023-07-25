import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PREFERRED_EDUCATION_DOMAIN_FIELD from '@salesforce/schema/Preferred_Education__c.Preferred_Education_Institution__c';
import PREFERRED_EDUCATION_OBJECT from '@salesforce/schema/Preferred_Education__c';
import { getFieldValue } from 'lightning/uiRecordApi';

export default class MyComponent extends LightningElement {
    @api recordId;
    @track preferredEducation;
    educationList;

    const
     columns = [
        { label: 'Education', fieldName: 'label' }
    ];


    @wire(getObjectInfo, {objectApiName: PREFERRED_EDUCATION_OBJECT})
    objectInfo;

    
    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: PREFERRED_EDUCATION_DOMAIN_FIELD})
    wiredPicklistValues({ error, data }) {
        console.log('Data '+ JSON.stringify(data));
        if (data) {
            console.log('TRUE');
            this.preferredEducation = data.values;
            /*this.preferredEducation = picklistValues.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));*/
            //console.log("This is the data" + data);
        } else if (error) {
            //console.error(error);
            //console.log(data)
        }
    }
    
    /*@wire(getPicklistValues, {recordTypeId: '01I7E000002PfJp', fieldApiName: PREFERRED_EDUCATION_DOMAIN_FIELD})
    wiredPicklistValues({ error, data }) {
        console.log('Data '+ data);
        console.log('------');
        console.log(error);
        if (data) {
            this.preferredEducation = picklistValues.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
            //console.log("This is the data" + data);
        } else if (error) {
            //console.error(error);
            //console.log(data)
        }
    }*/
    // picklistValues;


}

