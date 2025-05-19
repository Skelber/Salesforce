import FirstName from '@salesforce/schema/Contact.FirstName';
import { LightningElement, api } from 'lwc';

export default class PatientOverview extends LightningElement {
    @api jumpToScreen(event){
        console.log('jumping to screen ' + event.target.value)
        const screenChange = new CustomEvent('screenchange',{
            detail: {
                screen: event.target.value,
                 bubbles: true,
                 composed: true
            }
        });
        this.dispatchEvent(screenChange);
    }

    @api contact= {
        firstName: null,
        lastName: null,
        email: null,
        phone: null,
        RSZ: null,
        street: null,
        city: null,
        country: null,
        postalCode: null,
    }

}