import { LightningElement, track, api, wire } from 'lwc';
import locale from '@salesforce/i18n/locale';
import Next from "@salesforce/label/c.pbzButtonNext"
import Previous from "@salesforce/label/c.pbzButtonPrevious"
import CancelAppointment from "@salesforce/label/c.pbzButonCancelAppointment"
import EditAppointment from "@salesforce/label/c.pbzButtonEditAppointment"
import ConfirmChange from "@salesforce/label/c.pbzButtonConfirmChange"
import CancelSuccess from "@salesforce/label/c.pbzTextCancellationSuccess"
import Error from "@salesforce/label/c.pbzButtonConfirmChange"
import CreateSuccess from "@salesforce/label/c.pbzTextAppointmentCreationSuccess"
import UpdateSuccess from "@salesforce/label/c.pbzTextUpdateSuccessfull"
import BookAnAppointment from "@salesforce/label/c.pbzButtonBookAppointment"
import ChangeNotConfirmed from "@salesforce/label/c.pbzTextChangeNotConfirmed"
import AppointmentHasPassed from "@salesforce/label/c.pbzTextAppointmentHasPassed"
import AppointmentNotfound from "@salesforce/label/c.pbzTextAppointmentNotFound"
import DoubleBooking from "@salesforce/label/c.pbzDoubleBooking"
import saveLeadObject from '@salesforce/apex/WorktypeSelection.saveLeadObject';
import updateServiceAppointment from '@salesforce/apex/AppointmentCreation.updateServiceAppointmentObject';
import cancelServiceAppointment from '@salesforce/apex/AppointmentCreation.cancelServiceAppointmentObject';
import getServiceAppointment from '@salesforce/apex/WorktypeSelection.getAllInformation';
import getServiceAppointmentInvitation from '@salesforce/apex/WorktypeSelection.getInviteInformation';
import saveServiceAppointmentObject from '@salesforce/apex/AppointmentCreation.saveServiceAppointmentObject';
import uploadFile from '@salesforce/apex/FileUpload.uploadFile';
import { CurrentPageReference } from 'lightning/navigation';
import notFoundIcon from "@salesforce/resourceUrl/notFound2";

export default class BookAppointment extends LightningElement {

    @api currentStep;
    accountId;
    serviceAppointmentId;
    serviceAppointmentNumber;
    orderlineId;
    phase
    serviceResourceId;
    showDefaultProgress = false;
    showNextButton = false;
    showChangeButton = false;
    attachmentsUploaded = false
    appointmentHasError = false;
    appointmentHasPassed = false;
    noMatchingAppointment = false;
    doubleBooked = false;
    appointmentByInvitation = false;
    notFoundIcon = notFoundIcon;
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
        BookAnAppointment: BookAnAppointment,
        CancelAppointment: CancelAppointment,
        EditAppointment: EditAppointment,
        ConfirmChange: ConfirmChange,
        CancelSuccess: CancelSuccess,
        UpdateSuccess: UpdateSuccess,
        Error: Error,
        CreateSuccess: CreateSuccess,
        ChangeNotConfirmed: ChangeNotConfirmed,
        AppointmentHasPassed: AppointmentHasPassed,
        AppointmentNotfound: AppointmentNotfound,
        DoubleBooking: DoubleBooking
    }

    @track response = {
        type: '',
        message: ''
    }

    connectedCallback() {
        // this.setToStepOne();
    }
    
    
    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (pageRef?.state?.c__accountId && pageRef?.state?.c__serviceAppointmentId) {
            this.showGetInfoSpinner = true;
            this.showDefaultProgress = false;
            this.accountId = pageRef.state.c__accountId;
            this.serviceAppointmentId = pageRef.state.c__serviceAppointmentId;
            this.serviceAppointmentToUpdate.saId = pageRef.state.c__serviceAppointmentId;
            this.serviceAppointmentToCancel.saId = pageRef.state.c__serviceAppointmentId;
            this.getServiceAppointmentInfo();
        } else if (pageRef?.state?.c__accountId && pageRef?.state?.c__orderline && pageRef?.state?.c__CPO && pageRef?.state?.c__LocationId) {
            this.showGetInfoSpinner = true;
            this.accountId = pageRef.state.c__accountId;
            this.orderLineId = pageRef.state.c__orderline;
            this.serviceAppointment.resourceId  = pageRef.state.c__CPO;
            this.serviceAppointment.locationId = pageRef.state.c__LocationId;
            this.serviceResourceId = pageRef.state.c__CPO;
            this.getServiceAppointmentInviationInfo()
        }
        else {
            this.setToStepOne();
        }
    }

    getServiceAppointmentInfo() {
        // setTimeout(() => {
        getServiceAppointment({ 
            parentId: this.accountId, 
            SAId: this.serviceAppointmentId
        }) .then(result => {
            console.log(JSON.stringify(result));
                this.notBookedViaWebsite = true;
                this.appointmentHasPassed   = result?.matchInPast ?? false;
                this.noMatchingAppointment  = result?.noMatch ?? false;
                this.appointmentHasError = this.appointmentHasPassed || this.noMatchingAppointment ? true : false;
                this.attachmentsUploaded = result.appInfo.attachments;
                this.serviceAppointmentToUpdate.AssignedResourceId = result.appInfo.assignedResourceId;
                if(!this.receivedContact) this.receivedContact = {};
                this.receivedContact.yourName = result.yourName;
                this.receivedContact.bookedForName = result.bookedForName;
                this.receivedContact.email = result.yourEmail
                this.receivedContact.phone = result.yourPhone
                this.receivedContact.relationToPatientLabel = result.Relation;
                // this.receivedContact.bookedForSomeoneElse = result.bookedForName == 'null null'  ? false : true;
                this.receivedContact.bookedForSomeoneElse = result.bookedForName && result.bookedForName !== 'null null';
                this.bookedForSomeoneElse = result.bookedForName == 'null null' ? true : false;
                if (!this.receivedAdditionalInfo) this.receivedAdditionalInfo = {};
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
                this.receivedWorktype.ProdSubGroupTranslationNL = result.tool.toolSubGrNameNL;
                this.receivedWorktype.AppTypeTranslationNL = result.tool.toolAppNameNL;
                this.showScreenSix = true;
                this.currentStep = "6";
                this.handleScreenChange();
                console.log('Bookedforvalue: ' + this.bookedForSomeoneElse)
            }).catch(error => {
                })
                this.showGetInfoSpinner = false;
    }

    getServiceAppointmentInviationInfo(){
        console.log('getting invitation')
        getServiceAppointmentInvitation({
            AccountId: this.accountId,
            OrderLineId: this.orderLineId,
            ServiceResourceId: this.serviceAppointment.resourceId,
            ServiceLocationId: this.serviceAppointment.locationId,
        }).then(result => {
            console.log(JSON.stringify(result));
            this.appointmentByInvitation = true;
            this.showGetInfoSpinner = false;
            if(!this.receivedContact) this.receivedContact = {};
            if (!this.receivedLocation) this.receivedLocation = {};
            if(!this.receivedWorktype) this.receivedWorktype = {};
            this.notBookedViaWebsite = false
            this.receivedContact.bookedForSomeoneElse = false
            this.receivedContact.yourName = result.firstName + ' ' + result.lastName;
            this.receivedContact.email = result.email;
            this.receivedContact.phone = result.phone;
            if(result.location) {
                this.receivedLocation.recordName = result.location.locName;
                this.receivedLocation.recordId = result.location.locId;
                this.serviceAppointment.locationId = result.location.locId;
                this.receivedLocation.recordAdress.street = result.location.locAddress.street;
                this.receivedLocation.recordAdress.city = result.location.locAddress.city;
                this.receivedLocation.recordAdress.postalCode = result.location.locAddress.postalCode;
            }
            this.receivedWorktype.Bookable = true;
            if(result.tool) {
            this.receivedWorktype.RecordId = result.tool.toolId;
            this.serviceAppointment.workTypeId = result.tool.toolId;
                this.receivedWorktype.EstimatedDuration = result.tool.EstimatedDuration;
                this.serviceAppointment.duration = result.tool.EstimatedDuration;
                this.serviceAppointmentToUpdate.duration = result.tool.EstimatedDuration;
                this.receivedWorktype.ProdSubGroupTranslation = result.tool.toolSubGrName;
                this.receivedWorktype.AppTypeTranslation = result.tool.toolAppName;
                this.receivedWorktype.ProdSubGroupTranslationFR = result.tool.toolSubGrNameFR;
                this.receivedWorktype.AppTypeTranslationFR = result.tool.toolAppNameFR;
                this.receivedWorktype.ProdSubGroupTranslationNL = result.tool.toolSubGrNameNL;
                this.receivedWorktype.AppTypeTranslationNL = result.tool.toolAppNameNL;
            }
            this.serviceResourceId = result.validServiceResourceId ? this.serviceAppointment.resourceId : null

            if(this.receivedLocation.recordId) {
                this.showScreenFour = true;
                this.currentStep = "4"
            } else {
                this.showScreenThree = true;
                this.currentStep = "3"
            }
            this.handleScreenChange()
        }).catch(error => {
        })
        console.log('invitation complete')
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
            this.currentStep == "3" && this.serviceAppointment.locationId || 
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
        this.showGetInfoSpinner = false;
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
        this.serviceAppointment.rrNr = event.detail.RSZ
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

            if(this.appointmentByInvitation) {
                this.serviceAppointment.leadId = this.accountId;
                saveServiceAppointmentObject({
                    serviceappointment: JSON.stringify(this.serviceAppointment)
                }).then(SAResult => {
                    let parsedResult = JSON.parse(SAResult);
                    this.serviceAppointmentNumber = parsedResult.saName;
                    this.receivedAdditionalInfo.files.forEach(file => {
                        uploadFile({
                          base64: file.base64,
                          filename: file.name,
                          recordId: parsedResult.saId
                        })
                        .then((result) => {})
                      });
                    this.showSpinner = false;
                    this.response.type = 'success';
                    this.response.message = this.label.CreateSuccess;
                    this.showModal = true;
                }).catch(error => {
                    this.showSpinner = false;
                    this.response.type = 'error';
                    this.response.message = this.label.Error;
                    this.showModal = true;
                })
            } else {
                saveLeadObject({
                    lead: JSON.stringify(this.receivedContact)
                }).then(result => {
                    this.serviceAppointment.leadId = result
                    saveServiceAppointmentObject({
                        serviceappointment: JSON.stringify(this.serviceAppointment)
                    }).then(SAResult => {
                        let parsedResult = JSON.parse(SAResult);
                        if(parsedResult.doubleBooked){
                            this.doubleBooked = true;
                            this.showSpinner = false;
                            this.response.type = 'error';
                            this.response.message = this.label.DoubleBooking;
                            this.showModal = true;
                            setTimeout(() => {
                                this.currentStep = "4";
                                this.showScreenFour = true;
                                this.handleScreenChange();
                                this.showModal = false;
                                this.disableButtons = false;
                            }, 4000);
                        } else {
                            this.serviceAppointmentNumber = parsedResult.saName;
                            this.receivedAdditionalInfo.files.forEach(file => {
                                uploadFile({
                                    base64: file.base64,
                                    filename: file.name,
                                    recordId: parsedResult.saId
                                })
                                .then((result) => {})
                            });
                            this.showSpinner = false;
                            this.response.type = 'success';
                            this.response.message = this.label.CreateSuccess;
                            this.showModal = true;
                        }
                    }).catch(error => {
                        this.showSpinner = false;
                        this.response.type = 'error';
                        this.response.message = this.label.Error;
                        this.showModal = true;
                    })
                }).catch(error => {
                    this.response.type = 'error';
                    this.response.message = this.label.Error;
                    this.showModal = true;
                })
            }
        }

     handleAppointmentUpdate() {
        this.showSpinner = true
         updateServiceAppointment({
             serviceappointment: JSON.stringify(this.serviceAppointmentToUpdate)
        }).then(result => {
            this.response.type = 'success';
            this.response.message = this.label.UpdateSuccess
            this.showSpinner = false
            this.showModal = true;
        }).catch(error => {
            this.response.type = 'error';
            this.response.message = this.label.Error;
            this.showSpinner = false
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
                this.response.message = this.label.CancelSuccess;
                this.showSpinner = false
                this.showModal = true;
            }). catch(error => {
                this.response.type = 'error';
                this.response.message = this.label.Error;
                this.showSpinner = false;
                this.showModal = true
            })
     }

    handleModalClose() {
        this.showModal = false;
        this.showCancelModal = false;
    }
    
}