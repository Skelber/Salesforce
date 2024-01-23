import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'

export default class NavigateToRecord extends NavigationMixin(LightningElement) {
    @api recordId
    @api runInLightningContext = false

     connectedCallback() {

        if (this.runInLightningContext == true) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        actionName: 'view'
                     },
                 });
                } else {
                    location.replace('/'+this.recordId);
                }
    }

}