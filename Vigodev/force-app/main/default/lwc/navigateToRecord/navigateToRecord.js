import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavigateToRecord extends LightningElement {
    @api recordId
    @api objectApiName

connectedCallback() {

    location.replace('/'+this.recordId);
    
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //         attributes: {
        //             recordId: this.recordId,
        //             // objectApiName: this.objectApiName,
        //             actionName: 'view'
        //             },
        //         });
 
    }
}