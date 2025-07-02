import { LightningElement, api } from 'lwc';

export default class TaskModal extends LightningElement {
    @api selectedDays;
    @api timeValue;

    connectedCallback(){
        this.selectedDays = JSON.stringify([...this.selectedDays])
    }
    close() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}