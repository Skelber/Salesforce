import { LightningElement, track, api } from 'lwc';
import BackToWebsite from "@salesforce/label/c.pbzTextBackToWebsite"
import RedirectToSite from "@salesforce/label/c.pbzTextRedirectToWebsite"
import ModalTitle from "@salesforce/label/c.pbzScreen6ModalTitle"
import successIcon from "@salesforce/resourceUrl/success";
import errorIcon from "@salesforce/resourceUrl/error";

export default class SuccessModal extends LightningElement {

    label = {
        BackToWebsite,
        RedirectToSite,
        ModalTitle
    }
    isSuccess = false
    @track counter = 5;
    @api response;
    successIcon = successIcon
    errorIcon = errorIcon

    connectedCallback() {
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