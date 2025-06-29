import FirstName from '@salesforce/schema/Contact.FirstName';
import { LightningElement, api } from 'lwc';

export default class PatientOverview extends LightningElement {
    @api contact= {}
    @api additionalinfo={}
    @api worktype = {}
    @api location = {}
    @api showFile = false

    connectedCallback(){
        if(this.contact.file != null) {
            this.showFile = true
        } else {
            this.showFile = false
        }
    }
    
    @api jumpToScreen(event){
        const screenChange = new CustomEvent('screenchange',{
            detail: {
                screen: event.currentTarget.dataset.id,
                 bubbles: true,
                 composed: true
            }
        });
        this.dispatchEvent(screenChange);
    }
}