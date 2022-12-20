import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import SurveyInvitation from '@Salesforce/schema/SurveyInvitation.InvitationLink__c'

export default class RedirectComponent extends NavigationMixin(LightningElement) {

 navigateToWeb = () => {
    this[NavigationMixin.Navigate]({
        type:"standard__webPage",
        attributes:{
            url:{SurveyInvitation}
        }
    })
 }
}