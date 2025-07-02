import { LightningElement, track, api } from 'lwc';
import locale from '@salesforce/i18n/locale';
import Next from "@salesforce/label/c.pbzButtonNext"
import Previous from "@salesforce/label/c.pbzButtonPrevious"
import BookAnAppointment from "@salesforce/label/c.pbzButtonBookAppointment"

export default class BookAppointment extends LightningElement {

    currentStep;
    showDefaultProgress = false;
    showScreenOne;
    showScreenTwo;
    showScreenThree;
    showScreenFour;
    showScreenFive;
    showScreenSix;
    screenOneComplete;
    screenTwoComplete;
    screenThreeComplete;
    screenFourComplete;
    screenFiveComplete;
    disableNextButton;
    userLocale = locale;
    @track receivedContact;
    @track receivedWorktype;
    selectedBusinessUnitId
    selectedProductGroupId
    selectedProductSubGroupId;
    selectedAppointmentTypeId;
    @track receivedLocation;
    @track receivedSlot;
    @track receivedAdditionalInfo ={
        comment:null,
        files:null
    };

    label = {
        Next: Next,
        Previous: Previous,
        BookAnAppointment: BookAnAppointment
    }

    connectedCallback() {
        this.currentStep = "1"
        this.showScreenOne = true;
        this.showDefaultProgress = true;
    }

    receiveScreenChange(event) {
        this.currentStep = event.detail.screen;
        this.handleScreenChange();
    }

    handleScreenChange() {
        this.currentStep == "1" ? this.showScreenOne = true : this.showScreenOne = false;
        this.currentStep == "2" ? this.showScreenTwo = true : this.showScreenTwo = false;
        this.currentStep == "3" ? this.showScreenThree = true : this.showScreenThree = false;
        this.currentStep == "4" ? this.showScreenFour = true : this.showScreenFour = false;
        this.currentStep == "5" ? this.showScreenFive = true : this.showScreenFive = false;
        this.currentStep == "6" ? this.showScreenSix = true : this.showScreenSix = false;
        this.enableNextButton();
    }

    enableNextButton() {
        if(this.currentStep == "1" && this.screenOneComplete == true || 
            this.currentStep == "2" && this.receivedWorktype !=null || 
            this.currentStep == "3" && this.receivedLocation || 
            this.currentStep == "4" && this.receivedSlot ||
            this.currentStep == "5" ||
            this.currentStep == "6"
        ) {
            this.disableNextButton = false;
        } else {
            this.disableNextButton = true;
        }
        console.log('buttonstate: ' + this.disableNextButton)

    }


    handleNext() {
        const appointmentProgress = this.template.querySelector('c-appointment-progress');
        appointmentProgress.complete();
        this.currentStep = appointmentProgress.currentstep;
        this.handleScreenChange();
    }
    
    handlePrevious() {
        const appointmentProgress = this.template.querySelector("c-appointment-progress");
        appointmentProgress.previous();
        this.currentStep = appointmentProgress.currentstep;
        this.handleScreenChange()
    }

    receiveContact(event) {
        this.receivedContact = event.detail;
        console.log(JSON.stringify(this.receivedContact))
    }

    validateScreenOne(event) {
        this.screenOneComplete = event.detail.contactInfoComplete;
        console.log('screen one complete: ' + JSON.stringify(this.screenOneComplete))
        this.enableNextButton()
    }

    receiveWorktypeDetails(event) {
        const {
            workType,
            businessUnitId,
            productGroupId,
            productSubGroupId,
            appointmentTypeId
        } = event.detail;
    
        this.receivedWorktype = workType;
    
        // Store the business unit and other IDs for later use or rehydration
        this.selectedBusinessUnitId = businessUnitId;
        this.selectedProductGroupId = productGroupId;
        this.selectedProductSubGroupId = productSubGroupId;
        this.selectedAppointmentTypeId = appointmentTypeId;
    
        console.log('Received worktype:', JSON.stringify(workType));
        console.log('Selected BU ID:', businessUnitId);
    
        if (workType?.Bookable === false) {
            this.showDefaultProgress = false;
        } else {
            this.showDefaultProgress = true;
        }
    
        this.enableNextButton();
    
        setTimeout(() => {
            this.handleNext();
        }, 500);
    }

    receiveLocation(event){
        console.log('receiving location')
        this.receivedLocation = event.detail
        console.log('received location: ' + JSON.stringify(this.receivedLocation))
        this.enableNextButton();
        // this.currentStep = "4";
        setTimeout(() => {
            this.handleNext();
        }, 500);
    }

    receiveSlotDetails(event){
        this.receivedSlot = event.detail
        console.log('selected slot: ' + JSON.stringify(this.receivedSlot))
        this.enableNextButton()
    }
    

    receiveAdditionalInfo(event) {
        this.receivedAdditionalInfo.comment = event.detail.comment;
        this.receivedAdditionalInfo.files = event.detail.files; // array of file metadata
        console.log('Received files:', this.receivedAdditionalInfo.files.map(f => f.name).join(', '));
    }
    
}