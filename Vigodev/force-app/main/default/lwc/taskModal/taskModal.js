import { LightningElement, api } from 'lwc';
import ModalTitle from "@salesforce/label/c.pbzScreen4ModalTitle"
import ModalDisclaimer from "@salesforce/label/c.pbzScreen4ModalDisclaimer"
import BackToWebsite from "@salesforce/label/c.pbzTextBackToWebsite"

export default class TaskModal extends LightningElement {
    @api selectedDays;
    @api timeValue;

    label = {
        ModalTitle,
        ModalDisclaimer,
        BackToWebsite
    }

    connectedCallback(){
        this.selectedDays = JSON.stringify([...this.selectedDays])
    }
    close() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}