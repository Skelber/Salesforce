import { LightningElement, api } from 'lwc';
import LANG from '@salesforce/i18n/lang';
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
import YourName from "@salesforce/label/c.pbzYourName"
import PatientName from "@salesforce/label/c.pbzInputNamePatient"
import PatientEmail from "@salesforce/label/c.pbzInputEmailPatient"
import Documents from "@salesforce/label/c.pbzTextDocuments"
import Remarks from "@salesforce/label/c.pbzTextRemarks"
import FilesUploaded from "@salesforce/label/c.pbzTextFilesHaveBeenUploaded"
import Other from "@salesforce/label/c.pbzOtherPicklistLabel"
import Parent from "@salesforce/label/c.pbzParentPicklistLabel"
import Guardian from "@salesforce/label/c.pbzGuardianPicklistLabel"
import FamilyMember from "@salesforce/label/c.pbzFamilyMemberPicklistlabel"

export default class PatientOverview extends LightningElement {
    LANG = LANG
    displayEnglish = false;
    displayFrench = false;
    displayDutch = false;
    @api contact= {}
    @api additionalinfo={}
    @api worktype = {}
    @api location = {}
    @api timeslot = {}
    @api showFile = false
    @api notBookedViaWebsite = false;
    @api attachmentsUploaded = false;
    previewUrl;
    name;
    bookedForName;
    lastName;
    email;
    phone;

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
        YourName,
        PatientName,
        PatientEmail,
        Documents,
        Remarks,
        FilesUploaded,
        Other,
        Parent,
        Guardian,
        FamilyMember,
    }

    get options() {
        return [
            { label: this.label.Parent, value: 'Parent' },
            { label: this.label.FamilyMember, value: 'Family member' },
            { label: this.label.Guardian, value: 'Guardian' },
            { label: this.label.Other, value: 'Other' },
        ];
    }

    get relationToPatientLabel() {
        if (!this.contact?.relationToPatient) return null;
        const selectedOption = this.options.find(
            opt => opt.value === this.contact.relationToPatient
        );
        return selectedOption?.label || null;
    }

    connectedCallback(){
        console.log('contact: ' + JSON.stringify(this.contact))
     
        if(this.additionalinfo?.files) {
            this.showFile = true
        } else {
            this.showFile = false
        }
        if(this.notBookedViaWebsite) {
            // this.name = this.contact.bookedForName
            this.name = this.contact.bookedForSomeoneElse ? this.contact.bookedForName : this.contact.yourName
            this.bookedForName = this.contact.yourName
            this.email = this.contact.email
            this.phone = this.contact.phone
            
        } else {
            this.name = this.contact.bookedForSomeoneElse ? this.contact.bookedForFirstName + ' ' + this.contact.bookedForLastName : this.contact.firstName + ' ' + this.contact.lastName
            this.bookedForName = this.contact.bookedForSomeoneElse ? this.contact.firstName  + ' ' + this.contact.lastName : this.contact.bookedForFirstName + ' ' + this.contact.bookedForLastName
            this.email = this.contact.bookedForSomeoneElse ? this.contact.bookedForEmail : this.contact.email
            this.phone = this.contact.bookedForSomeoneElse ? this.contact.bookedForPhone : this.contact.phone
        }
        this.setLang();
    }

    setLang() {
        if (this.LANG == 'en-US') {
          this.displayEnglish = true
        } else if (this.LANG == 'fr') {
          this.displayFrench = true
        } else {
          this.displayDutch = true
        }
      }


get fileNames() {
    if (this.additionalinfo?.files) {
        return this.additionalinfo.files.map(file => file.name).join(', ');
    }
    return [];
}

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