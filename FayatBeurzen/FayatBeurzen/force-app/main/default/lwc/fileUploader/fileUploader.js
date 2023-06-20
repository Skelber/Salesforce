import { LightningElement, api } from 'lwc';
import saveFiles from '@salesforce/apex/FileUploaderController.saveFiles';

export default class FileUploader extends LightningElement {
    @api recordId;

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        saveFiles({ recordId: this.recordId, fileVersions: uploadedFiles })
            .then(() => {
                // Handle successful upload
            })
            .catch((error) => {
                // Handle upload error
            });
    }
}
