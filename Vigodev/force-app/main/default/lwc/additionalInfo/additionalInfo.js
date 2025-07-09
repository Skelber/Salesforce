import { LightningElement, api, track } from 'lwc';
import ScreenFiveTitle from "@salesforce/label/c.pbzScreenFiveTitle";
import Prescription from "@salesforce/label/c.pbzTextPrescription";
import AdditionalInfoText from "@salesforce/label/c.pbzLabelWhatDoWeNeedToKnow";

export default class AdditionalInfo extends LightningElement {
    @track fileName = '';
    @track comment = '';

    label = {
        ScreenFiveTitle,
        Prescription,
        AdditionalInfoText
    };

    @api
    set additionalInfo(value) {
        if (value) {
            this.comment = value.comment || '';
            this._files = value.files || [];
            this.fileName = this._files.map(file => file.name).join(', ');
        }
    }

    get additionalInfo() {
        return {
            comment: this.comment,
            files: this._files || []
        };
    }

   @track _files = [];

    handleCommentChange(event) {
        this.comment = event.target.value;
        this.passToParent();
    }

    handleFileChange(event) {
        this._files = event.detail.files || [];
        this.fileName = this._files.map(file => file.name).join(', ');
        this.passToParent();
    }

    handleRemoveFile(event) {
        const fileNameToDelete = event.currentTarget.dataset.filename;
        this._files = this._files.filter(file => file.name !== fileNameToDelete);
        this.fileName = this._files.map(file => file.name).join(', ');
        this.passToParent();
    }

    @api
    passToParent() {
        this.dispatchEvent(new CustomEvent('additionalinfodetails', {
            detail: {
                comment: this.comment,
                files: this._files
            },
            bubbles: true,
            composed: true
        }));
    }
}