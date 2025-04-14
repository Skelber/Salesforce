import { LightningElement } from 'lwc';

export default class DatePicker extends LightningElement {
    currentDate;

    connectedCallback(){
        this.currentDate = new Date()
    }
}