import { LightningElement, track, api } from 'lwc';
import locale from '@salesforce/i18n/locale';

export default class BookAppointment extends LightningElement {

    currentStep;
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
    @track receivedLocation;
    @track receivedAdditionalInfo;

    connectedCallback() {
        this.currentStep = "1"
        this.showScreenOne = true;
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
            this.currentStep == "4" ||
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

    receiveWorktypeDetails(event){
        this.receivedWorktype = event.detail
        console.log('received worktype: ' + JSON.stringify(this.receivedWorktype))
        this.enableNextButton()
    }

    receiveLocation(event){
        console.log('receiving location')
        this.receivedLocation = event.detail
        console.log('received location: ' + JSON.stringify(this.receivedLocation))
        this.enableNextButton();
    }

    receiveAdditionalInfo(event) {
        this.receiveAdditionalInfo = event.detail
        console.log('received info: ' + JSON.stringify(this.receiveAdditionalInfo))
    }
    
}