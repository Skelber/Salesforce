import { LightningElement, api } from 'lwc';

export default class AdditionalInfo extends LightningElement {

    additionalInfo = {
        comment: null,
        file: null
    }

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

    handleFileChange(event){
        const file = event.target.files[0];
        this.additionalInfo.file = file;
        console.log('additional info file ' + this.additionalInfo.file)
        this.passToParent();
    }

    @api passToParent() {
        const additionalInfo = new CustomEvent('additionalinfodetails', {
            detail: {
                comment: this.additionalInfo.comment,
                file: this.additionalInfo.file
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(additionalInfo);
    }
}