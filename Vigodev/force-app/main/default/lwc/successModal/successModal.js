import { LightningElement } from 'lwc';
import BackToWebsite from "@salesforce/label/c.pbzTextBackToWebsite"
import RedirectToSite from "@salesforce/label/c.pbzTextRedirectToWebsite"
import ModalTitle from "@salesforce/label/c.pbzScreen6ModalTitle"

export default class SuccessModal extends LightningElement {

    label = {
        BackToWebsite,
        RedirectToSite,
        ModalTitle
    }

    close() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}