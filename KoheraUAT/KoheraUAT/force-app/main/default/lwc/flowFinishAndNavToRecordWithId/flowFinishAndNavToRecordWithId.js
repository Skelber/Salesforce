import { api, LightningElement } from 'lwc';
import {
    FlowNavigationFinishEvent
} from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';

export default class FlowFinishAndNavToRecordWithId extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api action;

    connectedCallback() {
        this.closeFlow();
        this.navigateToRecord();
    }

    closeFlow() {
        this.dispatchEvent(new FlowNavigationFinishEvent());
    }

    navigateToRecord(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                actionName: this.action,
                recordId: this.recordId,
                objectApiName: this.objectApiName
            }
        });
    }


}