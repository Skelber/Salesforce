import { LightningElement } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Notifications extends LightningElement {

    toastHandler(){
     this.showToast("Success!!", "Account Creation passed", "success")
    }
    toastHandlerTwo(){
        this.showToast("Error!!", "Account Creation Failed", "error")
    }
    toastHandlerThree(){
     this.showToast("Warning!!", "Account Creation warning", "warning")
    }
    toastHandlerFour(){
     this.showToast("info!!", "Account Creation info", "info")
    }

    showToast(title, message, variant){
        const event =  new ShowToastEvent({
            title,
            message,
            variant
        })
        this.dispatchEvent(event)
    }

}