import { LightningElement } from 'lwc';

export default class BookAppointment extends LightningElement {

    currentStep;
    showScreenOne;
    showScreenTwo;
    showScreenThree;
    showScreenFour;

    connectedCallback() {
        this.currentStep = "1"
        this.showScreenOne = true;
    }

    handleScreenChange() {
        this.currentStep == "1" ? this.showScreenOne = true : this.showScreenOne = false;
        this.currentStep == "2" ? this.showScreenTwo = true : this.showScreenTwo = false;
        this.currentStep == "3" ? this.showScreenThree = true : this.showScreenThree = false;
        this.currentStep == "4" ? this.showScreenFour = true : this.showScreenFour = false;
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
    
}