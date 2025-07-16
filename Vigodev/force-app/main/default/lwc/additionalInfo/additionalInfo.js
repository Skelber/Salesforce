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

    // handleFileChange(event) {
    //     const newFiles = event.detail.files || [];
    //     this._files = [...this._files, ...newFiles];
    //     this.fileName = this._files.map(file => file.name).join(', ');
    //     this.passToParent();
    // }

    handleFileChange(event) {
        const newFiles = Array.from(event.target.files);
        const newProcessedFiles = [];
        let completed = 0;
      
        newFiles.forEach(file => {
          const reader = new FileReader();
      
          reader.onload = () => {
            const base64WithPrefix = reader.result;
            const base64 = base64WithPrefix.split(',')[1];
      
            newProcessedFiles.push({
              name: file.name,
              base64: base64
            });
      
            completed++;
      
            if (completed === newFiles.length) {
              const combined = [...this._files, ...newProcessedFiles];      
              const deduped = combined.filter(
                (f, index, self) =>
                  index === self.findIndex(t => t.name === f.name)
              );
      
              this._files = deduped;
              this.fileName = this._files.map(f => f.name).join(', ');
              this.passToParent();
            }
          };
      
          reader.readAsDataURL(file);
        });
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