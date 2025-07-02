import { LightningElement, api, track } from 'lwc';

export default class AdditionalInfo extends LightningElement {

    additionalInfo = {
        comment: null,
        file: null
    }

    @track fileName = []

    // disconnectedCallback(){
    //     this.passToParent();
    // }

    connectedCallback(){
        this.additionalInfo.comment = localStorage.getItem('comment') || ''; 

    }

    handleCommentChange(event){
        const value = event.target.value
        this.additionalInfo.comment = event.target.value;
        localStorage.setItem('comment', value);
        this.passToParent();
    }

    // handleFileChange(event) {
    //     const file = event.target.files[0];
    //     if (!this.additionalInfo) {
    //         this.additionalInfo = {};
    //     }
    
    //     this.additionalInfo.file = file;
    //     console.log('Selected file name:', file?.name);
    
    //     this.passToParent();
    // }


    handleFileChange(event) {
        const uploadedFiles = event.detail.files;
    
        if (!this.additionalInfo) {
            this.additionalInfo = {};
        }
        this.additionalInfo.file = uploadedFiles;
    
        this.fileName = uploadedFiles.map(file => file.name);
    
        console.log('Uploaded files:', [...this.fileName]);
    
        this.passToParent();
    }
    
    @api passToParent() {
        this.dispatchEvent(new CustomEvent('additionalinfodetails', {
            detail: {
                comment: this.additionalInfo.comment,
                files: this.additionalInfo.file 
            },
            bubbles: true,
            composed: true
        }));
    }
}