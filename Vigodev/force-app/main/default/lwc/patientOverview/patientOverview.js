import FirstName from '@salesforce/schema/Contact.FirstName';
import { LightningElement, api } from 'lwc';

export default class PatientOverview extends LightningElement {
    @api contact= {
        FirstName: null,
        LastName: null,
        Email: null,
        Phone: null,
        RSZ: null,
        Street: null,
        City: null,
        Country: null,
        PostalCode: null,
    }

    connectedCallback(){
        console.log(JSON.stringify(this.contact));
    }
}