import { LightningElement, api, track } from 'lwc';
import ModalTitle from "@salesforce/label/c.pbzScreen4ModalTitle"
import ModalDisclaimer from "@salesforce/label/c.pbzScreen4ModalDisclaimer"
import BackToWebsite from "@salesforce/label/c.pbzTextBackToWebsite"
import RedirectToSite from "@salesforce/label/c.pbzTextRedirectToWebsite"
import successIcon from "@salesforce/resourceUrl/success";
import errorIcon from "@salesforce/resourceUrl/error";

export default class TaskModal extends LightningElement {
    @api selectedDays;
    @api timeValue;
    @api response;
    @track counter = 5;
    isSuccess = false;
    label = {
        ModalTitle,
        ModalDisclaimer,
        BackToWebsite,
        RedirectToSite
    }

    successIcon = successIcon
    errorIcon = errorIcon

    connectedCallback(){
        this.isSuccess = this.response.type == 'success'? true : false;
        const countDown = setInterval(() => {
            if (this.counter > 0) {
                this.counter = this.counter - 1;
            } else {
                clearInterval(countDown);
                location.replace("https://www.vigogroup.eu/")
            }
        }, 1000);
    }
    close() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}