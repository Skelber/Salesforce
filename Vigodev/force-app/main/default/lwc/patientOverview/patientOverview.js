import FirstName from '@salesforce/schema/Contact.FirstName';
import { LightningElement, api } from 'lwc';

export default class PatientOverview extends LightningElement {
    @api contact= {}
    @api additionalinfo={}
    @api worktype = {}
    @api location = {}
    @api timeslot = {}
    @api showFile = false
    previewUrl;

    connectedCallback(){
        if(this.additionalinfo?.files) {
            this.showFile = true
        } else {
            this.showFile = false
        }

    }


get fileNames() {
    if (this.additionalinfo?.files) {
        return this.additionalinfo.files.map(file => file.name);
    }
    return [];
}

    // get isPdf() {
    //     return this.additionalinfo?.file?.type === 'application/pdf';
    //   }
      
    //   get isImage() {
    //     return this.additionalinfo?.file?.type.startsWith('image/');
    //   }

    // renderedCallback() {
    //     if (this.additionalinfo?.file) {
    //         console.log('📄 [PatientOverview] File name (rendered):', this.additionalinfo.file.name);
    //     }

    //     if (this.additionalinfo?.file && !this.previewUrl) {
    //         this.previewUrl = URL.createObjectURL(this.additionalinfo.file);
    //         console.log('📄 Preview URL created:', this.previewUrl);
    //       }
    // }
    
    @api jumpToScreen(event){
        const screenChange = new CustomEvent('screenchange',{
            detail: {
                screen: event.currentTarget.dataset.id,
                 bubbles: true,
                 composed: true
            }
        });
        this.dispatchEvent(screenChange);
    }
}