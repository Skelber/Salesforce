import { LightningElement, wire } from 'lwc';
import SAMPLEMC from "@salesforce/messageChannel/SampleMessageChannel__c"
import {MessageContext, publish} from 'lightning/messageService'
export default class LmsComponentA extends LightningElement {

    inputvalue;
    @wire(MessageContext)
    context

    inputHandler(event) {
        this.inputvalue = event.target.value
    }

    publishMessage(){
        const message={
            lmsData:{
                value:this.inputvalue
            }
        }
        publish(this.context, SAMPLEMC, message)
    }
}