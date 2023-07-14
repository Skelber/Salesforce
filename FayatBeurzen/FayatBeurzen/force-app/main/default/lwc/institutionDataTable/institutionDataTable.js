import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PREFERRED_EDUCATION_OBJECT from '@salesforce/schema/Preferred_education__c';
import PREFERRED_EDUCATION_DOMAIN_FIELD from '@salesforce/schema/Preferred_education__c.Preferred_Education_Domain__c';

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

    
    @wire(getObjectInfo, { objectApiName:PREFERRED_EDUCATION_OBJECT, recordId:'a1m7E000001llHuQAI' ,  recordTypeid: '$defaultRecordTypeId', fieldApiName: PREFERRED_EDUCATION_DOMAIN_FIELD })

    objectInfo({ error, data }) {
        if (data) {
            const picklistValues = data.fields.Preferred_education__c.Preferred_Education_Domain__c.picklistValues;
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

