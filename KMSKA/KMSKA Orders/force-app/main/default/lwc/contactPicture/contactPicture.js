import { LightningElement , api, wire} from 'lwc';
import { getRecord, getFieldValue, updateRecord, deleteRecord } from 'lightning/uiRecordApi';

import CONTACT_ID_FIELD from '@salesforce/schema/Contact.Id';
import IMG_FIELD from '@salesforce/schema/Contact.Contact_Picture__c';
import CONTENTDOC_FIELD from '@salesforce/schema/Contact.ContentDocumentId__c';
import IMAGE_URL_FIELD from '@salesforce/schema/ContentDocument.LatestPublishedVersion.VersionDataUrl';

const fields = [CONTENTDOC_FIELD]

export default class ContactPicture extends LightningElement {
    @api recordId;
    @api contentDocumentId;
    showUploadComponent = false;

    @wire(getRecord, {recordId: "$recordId", fields})
    contact;

    get contentDocId(){
        return getFieldValue(this.contact.data, CONTENTDOC_FIELD)
    }

    @wire(getRecord, {recordId: "$contentDocId", fields: [IMAGE_URL_FIELD] })
    contentDocImage;

    get imageUrl() {
        return getFieldValue(this.contentDocImage.data, IMAGE_URL_FIELD);
    }

    get acceptedFormats() {
        return ['.png', '.jpg', '.jpeg']
    }

    showFileUpload(){
        this.showUploadComponent = !this.showUploadComponent;
    }

    handleUploadFinished(event) {
        this.showUploadComponent = false;
        const fields = {};

        fields[CONTENTDOC_FIELD.fieldApiName] = event.detail.files[0].documentId;
        fields[CONTACT_ID_FIELD.fieldApiName] = this.recordId;
        fields[IMG_FIELD.fieldApiName] = this.imageUrl;

        const recordInput = {
            fields: fields
        };

        updateRecord(recordInput).then((record) => {
            console.log(record);
        })
    }
}