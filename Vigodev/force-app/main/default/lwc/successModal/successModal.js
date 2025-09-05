import { LightningElement, track, api } from 'lwc';
import BackToWebsite from "@salesforce/label/c.pbzTextBackToWebsite"
import RedirectToSite from "@salesforce/label/c.pbzTextRedirectToWebsite"
import ModalTitle from "@salesforce/label/c.pbzScreen6ModalTitle"
import Redirect from "@salesforce/label/c.pbzTextRedirect"
import successIcon from "@salesforce/resourceUrl/success";
import errorIcon from "@salesforce/resourceUrl/error";
import LANG from '@salesforce/i18n/lang';

export default class SuccessModal extends LightningElement {

    label = {
        BackToWebsite,
        RedirectToSite,
        ModalTitle,
        Redirect
    }
    LANG = LANG
    isSuccess = false
    @track counter = 5;
    @api response;
    @api serviceAppointmentNumber;
    @api doubleBooked = false;
    successIcon = successIcon
    errorIcon = errorIcon

    connectedCallback() {
        this.isSuccess = this.response.type == 'success'? true : false;
        if(this.isSuccess) {
            const countDown = setInterval(() => {
                if (this.counter > 0) {
                    this.counter = this.counter - 1;
                } else {
                    clearInterval(countDown);
                    if (this.LANG == 'fr') {
                        location.replace("https://www.vigogroup.eu/fr/")
                    } else {
                        location.replace("https://www.vigogroup.eu/")
                    }
                }
            }, 1000);
        }
    }

    close() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}