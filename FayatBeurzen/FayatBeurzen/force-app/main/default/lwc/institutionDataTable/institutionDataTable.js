import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PREFERRED_EDUCATION_INSTITUTION_FIELD from '@salesforce/schema/Preferred_Education__c.Preferred_Education_Institution__c';
import PREFERRED_EDUCATION_DOMAIN_FIELD from '@salesforce/schema/Preferred_Education__c.Preferred_Education_Domain__c';
import PREFERRED_EDUCATION_OBJECT from '@salesforce/schema/Preferred_Education__c';
import { getFieldValue, getRecord} from 'lightning/uiRecordApi';

const fields = [PREFERRED_EDUCATION_DOMAIN_FIELD, PREFERRED_EDUCATION_INSTITUTION_FIELD]
export default class MyComponent extends LightningElement {
    @track preferredInstitution;
    @track preferredDomain
    @api institutionOptions
    @api recordId;
    @track domainvalue

    const
     columns = [
        { label: 'Kennisinstellingen', fieldName: 'label' }
    ];


    
    @wire(getObjectInfo, {objectApiName: PREFERRED_EDUCATION_OBJECT})
    objectInfo;

    get initialdomainvalue(){
        if(this.Domain){
            return getFieldValue(this.Domain, PREFERRED_EDUCATION_DOMAIN_FIELD)
        }
    }

    
    
    @wire(getPicklistValues, {recordTypeId: "012000000000000AAA", fieldApiName : PREFERRED_EDUCATION_DOMAIN_FIELD})
    preferredDmainValues({ error, data }) {
        console.log('Data '+ JSON.stringify(data));
        if (data) {
            this.preferredDomain = data.values;
        } else if (error) {

        }
    }
    

//"012000000000000AAA" refers to the default recordtype 
    
    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: PREFERRED_EDUCATION_INSTITUTION_FIELD})
    wiredPicklistValues({ error, data }) {
        console.log('Data '+ JSON.stringify(data));
        if (data) {
            this.preferredInstitutionData = data;
        } else if (error) {

        }
    }

        //The get record is used retrieving the picklistvalues below
    @wire(getRecord, {recordId: '$recordId', fields})
    wiredDomain({error, data}) {
        if(data) {
            this.Domain = data;
            if(this.preferredInstitutionData.controllerValues[this.initialdomainvalue]){
                let key = this.preferredInstitutionData.controllerValues[this.initialdomainvalue];
                this.institutionOptions = this.preferredInstitutionData.values.filter(opt => opt.validFor.includes(key));
            }
            
        }
    }

        handleDomainChange(event){
        let key = this.preferredInstitutionData.controllerValues[event.target.value];
        this.institutionOptions = this.preferredInstitutionData.values.filter(opt => opt.validFor.includes(key));
        }


}

