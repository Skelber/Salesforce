import { LightningElement, api } from 'lwc';
import ModalTitle from "@salesforce/label/c.pbzScreen4ModalTitle"
import ModalDisclaimer from "@salesforce/label/c.pbzScreen4ModalDisclaimer"
import BackToWebsite from "@salesforce/label/c.pbzTextBackToWebsite"
import successIcon from "@salesforce/resourceUrl/success";
import errorIcon from "@salesforce/resourceUrl/error";

export default class TaskModal extends LightningElement {
    @api selectedDays;
    @api timeValue;
    @api response;
    isSuccess = false;
    label = {
        ModalTitle,
        ModalDisclaimer,
        BackToWebsite
    }

    successIcon = successIcon
    errorIcon = errorIcon

    connectedCallback(){
        this.isSuccess = this.response.type == 'success'? true : false;
        this.selectedDays = JSON.stringify([...this.selectedDays])
    }
    close() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}