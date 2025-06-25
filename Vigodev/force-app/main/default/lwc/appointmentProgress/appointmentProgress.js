import { LightningElement, api, track } from 'lwc';
import ContactDetails from "@salesforce/label/c.pbzProgressStepContactDetails"
import Tool from "@salesforce/label/c.pbzProgressStepTool"
import Location from "@salesforce/label/c.pbzProgressStepLocation"
import Timing from "@salesforce/label/c.pbzProgressStepTiming"
import AdditionalInfo from "@salesforce/label/c.pbzProgressStepAdditionalInformation"
import Overview from "@salesforce/label/c.pbzProgressStepOverview"

export default class AppointmentProgress extends LightningElement {

    @api currentstep = "1"
    @api pathType = "path"
    @api showDefaultProgress = false;

    label = {
        ContactDetails: ContactDetails,
        Tool: Tool,
        Location: Location,
        Timing: Timing,
        AdditionalInfo: AdditionalInfo,
        Overview: Overview
    }


    connectedCallback(){
        let width = window.innerWidth;
        console.log('width is ' +width)
        this.setPathVariant(width);
        this.showDefaultProgress = true
    }

    setPathVariant(width){
        if(width < 768){
            this.pathType = 'base'
        }else{
            this.pathType = 'path'
        }
    }

    @api
    complete() {
        if (parseInt(this.currentstep) < 6) {
            this.currentstep = String(parseInt(this.currentstep) + 1);
        }
    }

    @api
    previous() {
        if (this.currentstep > 1) {
            this.currentstep = String(parseInt(this.currentstep) - 1);
            
        }
    }
}