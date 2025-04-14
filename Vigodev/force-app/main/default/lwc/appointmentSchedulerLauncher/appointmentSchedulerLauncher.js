import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

export default class AppointmentSchedulerLauncher extends NavigationMixin(LightningElement) {

    wireRecordId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log('currentPageReference ', currentPageReference);
            this.wireRecordId = currentPageReference.state.recordId;
        }
    }

     connectedCallback() {
        Promise.resolve()
        .then(() => {
        this[NavigationMixin.GenerateUrl]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__appointmentScheduler'
                },
                state: {
                    c__recordId: this.wireRecordId
                }
        }).then(url => {
            window.open(url, "_blank");
             this.dispatchEvent(new CloseActionScreenEvent());
        })
        })
    }
}
