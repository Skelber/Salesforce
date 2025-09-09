import { LightningElement, track, api } from 'lwc';
import BackToWebsite from "@salesforce/label/c.pbzTextBackToWebsite"
import RedirectToSite from "@salesforce/label/c.pbzTextRedirectToWebsite"
import ModalTitle from "@salesforce/label/c.pbzScreen6ModalTitle"
import Redirect from "@salesforce/label/c.pbzTextRedirect"
import appointmentNumber from "@salesforce/label/c.pbzTextAppointmentNumber"
import successIcon from "@salesforce/resourceUrl/success";
import errorIcon from "@salesforce/resourceUrl/error";
import LANG from '@salesforce/i18n/lang';

export default class SuccessModal extends LightningElement {

    label = {
        BackToWebsite,
        RedirectToSite,
        ModalTitle,
        Redirect,
        appointmentNumber,
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
    }

    close() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}