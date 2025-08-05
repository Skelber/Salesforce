import { LightningElement, track, api, wire } from 'lwc';
import locale from '@salesforce/i18n/locale';
import Next from "@salesforce/label/c.pbzButtonNext"
import Previous from "@salesforce/label/c.pbzButtonPrevious"
import BookAnAppointment from "@salesforce/label/c.pbzButtonBookAppointment"
import saveLeadObject from '@salesforce/apex/WorktypeSelection.saveLeadObject';
import updateServiceAppointment from '@salesforce/apex/AppointmentCreation.updateServiceAppointmentObject';
import cancelServiceAppointment from '@salesforce/apex/AppointmentCreation.cancelServiceAppointmentObject';
import getServiceAppointment from '@salesforce/apex/WorktypeSelection.getAllInformation';
import saveServiceAppointmentObject from '@salesforce/apex/AppointmentCreation.saveServiceAppointmentObject';
import uploadFile from '@salesforce/apex/FileUpload.uploadFile';
import { CurrentPageReference } from 'lightning/navigation';

export default class BookAppointment extends LightningElement {

    @api currentStep;
    accountId;
    serviceAppointmentId;
    showDefaultProgress = false;
    showNextButton = false;
    showChangeButton = false;
    showScreenOne;
    showScreenTwo;
    showScreenThree;
    showScreenFour;
    showScreenFive;
    showScreenSix;
    showModal = false;
    showCancelModal = false;
    showSpinner = false;
    showGetInfoSpinner = false;
    screenOneComplete;
    screenTwoComplete;
    screenThreeComplete;
    screenFourComplete;
    screenFiveComplete;
    disableNextButton;
    disableButtons = false;
    userLocale = locale;
    cancelReason;
    cancelDescription;
    @track receivedContact;
    @track receivedWorktype;
    originalStarttime;
    originalResourceId;
    selectedBusinessUnitId
    selectedProductGroupId
    selectedProductSubGroupId;
    selectedAppointmentTypeId;
    @track receivedLocation = {
        recordAdress: {
            street: '',
            city: '',
            postalCode: ''
        }
    };
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
        rrNr: '',
        email: '',
    }

    serviceAppointmentToUpdate = {
        saId: '',
        startTime :'',
        duration : '',
        AssignedResourceId: '',
        resourceId: ''
    }

    serviceAppointmentToCancel = {
        saId: '',
        cancelPicklist: '',
        cancelText: '',
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

    connectedCallback() {
        // this.currentStep = "1"
        // this.showScreenOne = true;
        // this.showDefaultProgress = true;
        // this.showNextButton = true;
        
        // if (!this.currentStep) {
        //     this.currentStep = "1";
        //     this.handleScreenChange();
        // }
        this.setToStepOne();
    }
    
    
    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (pageRef?.state?.c__accountId && pageRef?.state?.c__serviceAppointmentId) {
            this.accountId = pageRef.state.c__accountId;
            this.serviceAppointmentId = pageRef.state.c__serviceAppointmentId;
            this.serviceAppointmentToUpdate.saId = pageRef.state.c__serviceAppointmentId;
            this.serviceAppointmentToCancel.saId = pageRef.state.c__serviceAppointmentId;
            console.log('pagerefs ' + this.accountId + ' ' + this.serviceAppointmentId)
            this.showGetInfoSpinner = true;
            this.showDefaultProgress = false;
            this.getServiceAppointmentInfo();
        } else {
            console.log('setting step one')
            this.setToStepOne();
        }
    }

    getServiceAppointmentInfo() {
        console.log('account Id: ' + this.accountId + ' service appointment Id: ' + this.serviceAppointmentId )
        // setTimeout(() => {
        getServiceAppointment({ 
            parentId: this.accountId, 
            SAId: this.serviceAppointmentId
        }) .then(result => {
                console.log(JSON.stringify(result));
                this.notBookedViaWebsite = true;
                this.serviceAppointmentToUpdate.AssignedResourceId = result.appInfo.assignedResourceId;
                if(!this.receivedContact) this.receivedContact = {};
                this.receivedContact.yourName = result.yourName;
                this.receivedContact.bookedForName = result.bookedForName;
                this.receivedContact.email = result.yourEmail
                this.receivedContact.phone = result.yourPhone
                this.receivedContact.relationToPatientLabel = result.Relation;
                this.receivedContact.bookedForSomeoneElse = result.bookedForName ? true : false;
                if (!this.receiveAdditionalInfo) this.receiveAdditionalInfo = {};
                this.receivedAdditionalInfo.comment = result.appInfo.remarks;
                if (!this.serviceAppointment) this.serviceAppointment = {};
                this.serviceAppointment.resourceId = result.appInfo.resourceId;
                if (!this.receivedLocation) this.receivedLocation = {};
                if (!this.receivedLocation.recordAdress) this.receivedLocation.recordAddress = {};
                this.receivedLocation.recordName = result.location.locName;
                this.receivedLocation.recordId = result.location.locId;
                this.receivedLocation.recordAdress.street = result.location.locAddress.street;
                this.receivedLocation.recordAdress.city = result.location.locAddress.city;
                this.receivedLocation.recordAdress.postalCode = result.location.locAddress.postalCode;
                if (!this.receivedSlot) this.receivedSlot = {};
                this.receivedSlot.slot = result.appInfo.startTime;
                this.receivedSlot.resourceId = result.appInfo.resourceId;
                this.receivedSlot.resourceName = result.appInfo.resourceName;
                this.originalStarttime = result.appInfo.startTime;
                this.originalResourceId = result.appInfo.resourceId;
                if(!this.receivedWorktype) this.receivedWorktype = {};
                this.receivedWorktype.RecordId = result.tool.toolId;
                this.receivedWorktype.Bookable = true;
                this.receivedWorktype.EstimatedDuration = result.tool.EstimatedDuration;
                this.serviceAppointmentToUpdate.duration = result.tool.EstimatedDuration;
                this.receivedWorktype.ProdSubGroupTranslation = result.tool.toolSubGrName;
                this.receivedWorktype.AppTypeTranslation = result.tool.toolAppName;
                this.receivedWorktype.ProdSubGroupTranslationFR = result.tool.toolSubGrNameFR;
                this.receivedWorktype.AppTypeTranslationFR = result.tool.toolAppNameFR;
                this.showScreenSix = true;
                this.currentStep = "6";
                this.handleScreenChange();
            }).catch(error => {
                    console.log('getServiceAppointmentinfo Error ' + error)
                })
                this.showGetInfoSpinner = false;
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

    setToStepOne() {
        this.currentStep = "1";
        this.showScreenOne = true;
        this.showScreenTwo = false;
        this.showScreenThree = false;
        this.showScreenFour = false;
        this.showScreenFive = false;
        this.showScreenSix = false;
        this.showDefaultProgress = true;
        this.showNextButton = true;
        this.handleScreenChange();
    }


    handleNext() {
        if(this.notBookedViaWebsite) {
            this.currentStep = "6"
            this.showScreenFour = false;
            this.showScreenSix = true
        } else {
            const appointmentProgress = this.template.querySelector('c-appointment-progress');
            appointmentProgress.complete();
            this.currentStep = appointmentProgress.currentstep;
        }
        this.handleScreenChange();
    }
    
    handlePrevious() {
        const appointmentProgress = this.template.querySelector("c-appointment-progress");
        appointmentProgress.previous();
        this.currentStep = appointmentProgress.currentstep;
        this.handleScreenChange()
    }

    handleCancellation(event){
        this.showCancelModal = true;
    }

    handleAppointmentEdit(){
        this.currentStep == "4"
        this.showScreenFour = true;
        this.showScreenSix = false;
    }

    compareSlots(){
        if (this.receivedSlot.startTime != this.originalStarttime || this.receivedSlot.resourceId != this.originalResourceId) {
            this.showChangeButton = true;
        } else {
            this.showChangeButton = false;
        }
    }

    receiveContact(event) {
        this.receivedContact = event.detail;
        this.serviceAppointment.RSZ = event.detail.RSZ
        this.serviceAppointment.email = event.detail.bookedForSomeoneElse ? event.detail.bookedForEmail : event.detail.email;
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
        this.serviceAppointment.workTypeId = this.receivedWorktype.RecordId;
        this.serviceAppointment.duration = this.receivedWorktype.EstimatedDuration;
        this.enableNextButton();
    
        setTimeout(() => {
            this.handleNext();
        }, 500);
    }

    receiveLocation(event){
        this.receivedLocation = event.detail
        console.log(JSON.stringify(this.receivedLocation))
        this.serviceAppointment.locationId = this.receivedLocation.recordId,
        this.enableNextButton();
        setTimeout(() => {
            this.handleNext();
        }, 500);
    }

    receiveSlotDetails(event){
        this.receivedSlot = event.detail
        console.log(JSON.stringify(this.receivedSlot))
        this.serviceAppointment.startTime = new Date(event.detail.slot);
        this.serviceAppointment.resourceId = event.detail.resourceId;
        this.serviceAppointmentToUpdate.startTime = new Date(event.detail.slot);
        this.serviceAppointmentToUpdate.resourceId = event.detail.resourceId;
        this.enableNextButton()
        this.compareSlots();
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
      }

      receiveCancellation(event) {

      }

     handleSubmit() {
            this.showSpinner = true;
            this.disableButtons = true;

            saveLeadObject({
                lead: JSON.stringify(this.receivedContact)
            }).then(result => {
                this.serviceAppointment.leadId = result
                saveServiceAppointmentObject({
                    serviceappointment: JSON.stringify(this.serviceAppointment)
                }).then(SAResult => {
                    this.receivedAdditionalInfo.files.forEach(file => {
                        uploadFile({
                          base64: file.base64,
                          filename: file.name,
                          recordId: SAResult
                        })
                        .then((result) => {})
                      });
                    this.showSpinner = false;
                    this.response.type = 'success';
                    this.response.message = 'Request succesfully created';
                    this.showModal = true;
                }).catch(error => {
                    this.showSpinner = false;
                    this.response.type = 'error';
                    this.response.message = 'Something went wrong, please try again';
                    this.showModal = true;
                })
            }).catch(error => {
                this.response.type = 'error';
                this.response.message = 'Something went wrong, please try again';
                this.showModal = true;
            })
     }

     handleAppointmentUpdate() {
        console.log(JSON.stringify(this.serviceAppointmentToUpdate))
         updateServiceAppointment({
             serviceappointment: JSON.stringify(this.serviceAppointmentToUpdate)
        }).then(result => {
            console.log(result)
            this.response.type = 'success';
            this.response.message = 'Request succesfully updated';
            this.showModal = true;
        }).catch(error => {
            console.log(error)
            this.response.type = 'error';
            this.response.message = 'Something went wrong, please try again';
            this.showModal = true;
        })
     }

     handleAppointmentCancellation(event) {
         this.showCancelModal = false;
         this.showSpinner = true
         this.serviceAppointmentToCancel.cancelPicklist = event.detail.cancelReason;
         this.serviceAppointmentToCancel.cancelText = event.detail.cancelDescription;
         cancelServiceAppointment({
             serviceappointment: JSON.stringify(this.serviceAppointmentToCancel)
            }).then(result => {
                this.response.type = 'success';
                this.response.message = 'Request succesfully cancelled';
                this.showSpinner = false
                this.showModal = true;
            }). catch(error => {
                this.response.type = 'error';
                this.response.message = 'Something went wrong, please try again';
                this.showSpinner = false;
                this.showModal = true
            })
     }

    handleModalClose() {
        this.showModal = false;
        this.showCancelModal = false;
    }
    
}