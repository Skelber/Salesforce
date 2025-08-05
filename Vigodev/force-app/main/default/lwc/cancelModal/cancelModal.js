import { LightningElement, wire, api } from 'lwc';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import CANCELLATION_FIELD from "@salesforce/schema/ServiceAppointment.Cancellation_Reason__c";



export default class CancelModal extends LightningElement {

    cancelValues;
    cancelReason;
    showOtherReason = false;
    otherReason = ''
    disableCancelButton = false;

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: CANCELLATION_FIELD })
    picklistValues({error, data}){
        if (data) {
            console.log(JSON.stringify(data))
            this.cancelValues = data.values;
        }
    };

    connectedCallback(){
        this.disableCancelButton = true;
    }

    handleCancelChange(event) {
        this.cancelReason = event.detail.value;
        this.showOtherReason = this.cancelReason === "Other";
        if(this.cancelReason === "Other") {
            const textarea = this.template.querySelector('.cancelTextarea');
            if (textarea) {
              textarea.innerHTML = this.otherReason
            }
        }
        this.checkbuttonState()
    }

    handleOtherReasonChange(event) {
        this.otherReason = event.target.value;
        this.checkbuttonState()
    }

    checkbuttonState() {
        if (!this.cancelReason || (this.cancelReason === "Other" && this.otherReason == '')) {
            this.disableCancelButton = true;
        } else {
            this.disableCancelButton = false;
        }
    }
     @api
        cancelAppointment() {
            this.dispatchEvent(new CustomEvent('appointmentcancellation', {
                detail: {
                    cancelReason: this.cancelReason,
                    cancelDescription: this.otherReason
                },
                bubbles: true,
                composed: true
            }));
        }

    close() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}