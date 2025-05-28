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

        @api passToParent() {
            const additionalInfo = new CustomEvent('additionalinfodetails',{
                detail: {
                    ...this.additionalInfo,
                    bubbles: true,
                    composed: true
                }
            });
            this.dispatchEvent(additionalInfo);
        }
}