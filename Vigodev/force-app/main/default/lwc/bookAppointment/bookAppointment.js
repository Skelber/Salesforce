import { LightningElement } from 'lwc';

export default class BookAppointment extends LightningElement {


    handleNext() {
        this.template.querySelector("c-appointment-progress").complete();
    }
    
    handlePrevious() {
        this.template.querySelector("c-appointment-progress").previous();
    }
    
}