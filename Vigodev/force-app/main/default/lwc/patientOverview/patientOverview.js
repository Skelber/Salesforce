import { LightningElement, api } from 'lwc';
import ScreenSixTitle from "@salesforce/label/c.pbzScreenSixTitle"
import ContactDetails from "@salesforce/label/c.pbzProgressStepContactDetails"
import Tool from "@salesforce/label/c.pbzProgressStepTool"
import Location from "@salesforce/label/c.pbzProgressStepLocation"
import Timing from "@salesforce/label/c.pbzProgressStepTiming"
import AdditionalInfo from "@salesforce/label/c.pbzProgressStepAdditionalInformation"
import YourEmail from "@salesforce/label/c.pbzInputYourEmail"
import YourPhone from "@salesforce/label/c.pbzInputYourPhone"
import RelationToUser from "@salesforce/label/c.pbzInputRelationToUser"
import Phone from "@salesforce/label/c.pbzInputPhone"
import PatientName from "@salesforce/label/c.pbzInputNamePatient"
import PatientEmail from "@salesforce/label/c.pbzInputEmailPatient"
import Documents from "@salesforce/label/c.pbzTextDocuments"
import Remarks from "@salesforce/label/c.pbzTextRemarks"

export default class PatientOverview extends LightningElement {
    @api contact= {}
    @api additionalinfo={}
    @api worktype = {}
    @api location = {}
    @api timeslot = {}
    @api showFile = false
    previewUrl;

    label = {
        ScreenSixTitle,
        ContactDetails,
        Tool,
        Location,
        Timing,
        AdditionalInfo,
        YourEmail,
        YourPhone,
        RelationToUser,
        Phone,
        PatientName,
        PatientEmail,
        Documents,
        Remarks
    }

    connectedCallback(){
        if(this.additionalinfo?.files) {
            this.showFile = true
        } else {
            this.showFile = false
        }

    }


get fileNames() {
    if (this.additionalinfo?.files) {
        return this.additionalinfo.files.map(file => file.name);
    }
    return [];
}

    // get isPdf() {
    //     return this.additionalinfo?.file?.type === 'application/pdf';
    //   }
      
    //   get isImage() {
    //     return this.additionalinfo?.file?.type.startsWith('image/');
    //   }

    // renderedCallback() {
    //     if (this.additionalinfo?.file) {
    //         console.log('📄 [PatientOverview] File name (rendered):', this.additionalinfo.file.name);
    //     }

    //     if (this.additionalinfo?.file && !this.previewUrl) {
    //         this.previewUrl = URL.createObjectURL(this.additionalinfo.file);
    //         console.log('📄 Preview URL created:', this.previewUrl);
    //       }
    // }
    
    @api jumpToScreen(event){
        const screenChange = new CustomEvent('screenchange',{
            detail: {
                screen: event.currentTarget.dataset.id,
                 bubbles: true,
                 composed: true
            }
        });
        this.dispatchEvent(screenChange);
    }
}