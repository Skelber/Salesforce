import { LightningElement, api, track } from 'lwc';
import avatar from "@salesforce/resourceUrl/avatar";

export default class SelectServiceResource extends LightningElement {
    @api notBookableViaWebsite = false;
    avatar = avatar;

    @track amButtonActive = false;
    pmButtonActive = false;
    @track amButtonVariant = "brand";
    @track pmButtonVariant = "brand";

    connectedCallback() {
        this.amButtonActive = true;
        this.pmButtonActive = true;
    }

    handleAMButtonClick() {
        this.amButtonActive = !this.amButtonActive;

        if (this.amButtonActive) {
            this.amButtonVariant = "brand";
        } else {
            this.amButtonVariant = "neutral";
        }
    }
    handlePMButtonClick() {
        this.pmButtonActive = !this.pmButtonActive;

        if (this.pmButtonActive) {
            this.pmButtonVariant = "brand";
        } else {
            this.pmButtonVariant = "neutral";
        }
    }

    // connectedCallback(){
    //     this.notBookableViaWebsite = true;
    // }


}