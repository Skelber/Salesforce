import { LightningElement, track, api } from 'lwc';
import locale from '@salesforce/i18n/locale';
import Next from "@salesforce/label/c.pbzButtonNext"
import Previous from "@salesforce/label/c.pbzButtonPrevious"
import BookAnAppointment from "@salesforce/label/c.pbzButtonBookAppointment"

export default class BookAppointment extends LightningElement {

    @api currentStep;
    showDefaultProgress = false;
    showNextButton = false;
    showScreenOne;
    showScreenTwo;
    showScreenThree;
    showScreenFour;
    showScreenFive;
    showScreenSix;
    showModal = false;
    screenOneComplete;
    screenTwoComplete;
    screenThreeComplete;
    screenFourComplete;
    screenFiveComplete;
    disableNextButton;
    disableButtons = false;
    userLocale = locale;
    @track receivedContact;
    @track receivedWorktype;
    selectedBusinessUnitId
    selectedProductGroupId
    selectedProductSubGroupId;
    selectedAppointmentTypeId;
    @track receivedLocation;
    @track receivedSlot;
    @track receivedAdditionalInfo = {
        comment: '',
        files: []
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
        this.showNextButton = true;
    }

    receiveScreenChange(event) {
        this.currentStep = event.detail.screen;
        const appointmentProgress = this.template.querySelector('c-appointment-progress');
        appointmentProgress.currentstep = event.detail.screen;
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

        if(this.currentStep =="4"){
            this.showNextButton = this.receivedWorktype.Bookable ? true : false;
        } else {
            this.showNextButton = true
        }

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

    handleSubmit() {
        this.showModal = true;
        this.disableButtons = true;
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
        this.showDefaultProgress = this.receivedWorktype.Bookable ? true : false;
        this.selectedBusinessUnitId = businessUnitId;
        this.selectedProductGroupId = productGroupId;
        this.selectedProductSubGroupId = productSubGroupId;
        this.selectedAppointmentTypeId = appointmentTypeId;
    
        this.enableNextButton();
    
        setTimeout(() => {
            this.handleNext();
        }, 500);
    }

    receiveLocation(event){
        this.receivedLocation = event.detail
        this.enableNextButton();
        setTimeout(() => {
            this.handleNext();
        }, 500);
    }

    receiveSlotDetails(event){
        this.receivedSlot = event.detail
        this.enableNextButton()
    }
    

    receiveAdditionalInfo(event) {
        this.receivedAdditionalInfo.comment = event.detail.comment;
        this.receivedAdditionalInfo.files = event.detail.files;
        console.log('Received files:', this.receivedAdditionalInfo.files.map(f => f.name).join(', '));
    }

    handleModalClose() {
        this.showModal = false;
    }
    
}