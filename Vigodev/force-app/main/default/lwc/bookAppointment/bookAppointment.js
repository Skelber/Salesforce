import { LightningElement, track, api, wire } from 'lwc';
import locale from '@salesforce/i18n/locale';
import Next from "@salesforce/label/c.pbzButtonNext"
import Previous from "@salesforce/label/c.pbzButtonPrevious"
import BookAnAppointment from "@salesforce/label/c.pbzButtonBookAppointment"
import saveLead from '@salesforce/apex/WorktypeSelection.saveLead';
import saveLeadObject from '@salesforce/apex/WorktypeSelection.saveLeadObject';
import saveServiceAppointment from '@salesforce/apex/AppointmentCreation.saveServiceAppointment';
import saveServiceAppointmentObject from '@salesforce/apex/AppointmentCreation.saveServiceAppointmentObject';
import uploadFile from '@salesforce/apex/FileUpload.uploadFile';
import { CurrentPageReference } from 'lightning/navigation';

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
    showSpinner = false;
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
    serviceAppointment = {
        leadId: '',
        locationId: '',
        startTime: '',
        duration: '',
        resourceId: '',
        workTypeId: '',
        description: '',
        rrNr: ''

    }

    label = {
        Next: Next,
        Previous: Previous,
        BookAnAppointment: BookAnAppointment
    }

    @track response = {
        type: '',
        message: ''
    }

    @wire(CurrentPageReference)
    currentPageReference;

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

    receiveContact(event) {
        this.receivedContact = event.detail;
        this.serviceAppointment.RSZ = event.detail.RSZ
    }

    validateScreenOne(event) {
        this.screenOneComplete = event.detail.contactInfoComplete;
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
        this.serviceAppointment.workTypeId = event.detail.workTypeId;
        this.serviceAppointment.duration = this.receivedWorktype.EstimatedDuration;
    
        this.enableNextButton();
    
        setTimeout(() => {
            this.handleNext();
        }, 500);
    }

    receiveLocation(event){
        this.receivedLocation = event.detail
        this.serviceAppointment.locationId = this.receivedLocation.recordId,
        this.enableNextButton();
        setTimeout(() => {
            this.handleNext();
        }, 500);
    }

    receiveSlotDetails(event){
        this.receivedSlot = event.detail
        this.serviceAppointment.startTime = new Date(event.detail.slot);
        this.serviceAppointment.resourceId = event.detail.resourceId;
        this.enableNextButton()
    }

    receiveAdditionalInfo(event) {
        if (!this.receivedAdditionalInfo) {
          this.receivedAdditionalInfo = {
            comment: '',
            files: []
          };
        }
      
        this.receivedAdditionalInfo.comment = event.detail.comment;
        this.receivedAdditionalInfo.files = event.detail.files;
        this.serviceAppointment.description = event.detail.comment;
      
        // console.log('Received files:', this.receivedAdditionalInfo.files.map(f => f.name).join(', '));
      }

     handleSubmit() {
            this.showSpinner = true;
            this.disableButtons = true;
            // saveLead({
            //     firstName: this.receivedContact.firstName,
            //     lastName: this.receivedContact.lastName,
            //     email: this.receivedContact.email,
            //     phone: this.receivedContact.phone,
            //     rrNr: this.receivedContact.RSZ,
            //     noRrNr : this.receivedContact.hasNoRSZ,
            //     endUserBirthdate: this.receivedContact.birthdate,
            //     street: this.receivedContact.street,
            //     postalcode: this.receivedContact.postalCode,
            //     city: this.receivedContact.city,
            //     // country: this.receivedContact.country,
            //     country: 'Belgium',
            //     onBehalveOf: this.receivedContact.bookedForSelf,
            //     relationship: this.receivedContact.relationToPatient,
            //     yourFirstName:this.receivedContact.bookedForFirstName,
            //     yourLastName:this.receivedContact.bookedForLastName,
            //     yourEmail: 'test123@test.be',
            //     yourPhone:'041234567'

            saveLeadObject({
                lead: JSON.stringify(this.receivedContact)
            }).then(result => {
                console.log('savelead response ' + result)
                this.serviceAppointment.leadId = result
                // saveServiceAppointment({
                //     leadid: result,
                //     locationId: this.receivedLocation.recordId,
                //     startTime: new Date(this.receivedSlot.slot),
                //     duration: this.receivedWorktype.EstimatedDuration,
                //     resourceId: this.receivedSlot.resourceId,
                //     workTypeId: this.receivedWorktype.RecordId,
                //     description: this.receivedAdditionalInfo.comment,
                //     rrNr: this.receivedContact.RSZ
                saveServiceAppointmentObject({
                    serviceappointment: JSON.stringify(this.serviceAppointment)
                }).then(SAResult => {
                    this.receivedAdditionalInfo.files.forEach(file => {
                        uploadFile({
                          base64: file.base64,
                          filename: file.name,
                          recordId: SAResult
                        })
                        .then(() => console.log(`Uploaded ${file.name}`))
                        .catch(error => console.error('file error' + JSON.stringify(error)));
                      });
                    this.showSpinner = false;
                    console.log('savSA response ' + SAResult)
                    this.response.type = 'success';
                    this.response.message = 'Request succesfully created';
                    this.showModal = true;
                }).catch(error => {
                    this.showSpinner = false;
                    console.log('SAerror' + JSON.stringify(error))
                    this.response.type = 'error';
                    this.response.message = 'Something went wrong, please try again';
                    this.showModal = true;
                })
            }).catch(error => {
                console.log('error' + JSON.stringify(error))
                this.response.type = 'error';
                this.response.message = 'Something went wrong, please try again';
                this.showModal = true;
            })
     }

    handleModalClose() {
        this.showModal = false;
    }
    
}