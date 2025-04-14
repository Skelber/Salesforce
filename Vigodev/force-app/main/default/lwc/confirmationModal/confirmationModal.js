import {  api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { getRecord} from "lightning/uiRecordApi";
import { createMessageContext, releaseMessageContext, publish, MessageContext } from 'lightning/messageService';
import serviceAppointmentChannel from '@salesforce/messageChannel/serviceAppointment__c';



export default class ConfirmationModal extends LightningModal {
     @api Start;
     @api End;
     @api ServiceResource;
     @api ServiceResource2;
     @api accountName;
     @api locationName;
     @api userId;
     @api resourceId;
    @api businessUnit;
    @api productGroup;
    @api productSubGroup;
    @api appointmentType;
    description;
    @api workTypeName;
    @api displayStartDate;
    @api displayEndDate;
    @api multiRsourceBooking;
    @api primaryServiceResourceName;
    @api secondaryServiceResourceName;
    @api PatientLABEL
    @api ServiceProviderLABEL
    @api ServiceLocationLABEL
    @api WorkTypeLABEL
    @api StartTimeLABEL
    @api EndTimeLABEL
    @api ButtonLabelLABEL
    @api DescriptionLABEL

    @wire(MessageContext)
    messageContext;





    handleDescription(event){
        this.description = event.target.value;
    }

    handleOkay() {
        const serviceAppointment = {
            start:this.Start,
            end:this.End,
            resourceId:this.resourceId,
            description:this.description
        };
        publish(this.messageContext, serviceAppointmentChannel, serviceAppointment);
        this.close();
    }

    disconnectedCallback() {
        releaseMessageContext(this.context);
    }
}